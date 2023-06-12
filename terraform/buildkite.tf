locals {
  # This is a collection of settings that should be the same for every
  # instance of our Buildkite stack.
  common_parameters = {
    AgentsPerInstance = 1

    BuildkiteAgentTokenParameterStorePath = "/aws/reference/secretsmanager/builds/buildkite_agent_key"

    InstanceCreationTimeout = "PT5M"

    VpcId           = local.ci_vpc_id
    Subnets         = join(",", local.ci_vpc_private_subnets)
    SecurityGroupId = aws_security_group.buildkite.id

    CostAllocationTagName  = "aws:createdBy"
    CostAllocationTagValue = "buildkite-elasticstack"

    # This tells Buildkite to fetch secrets from our S3 bucket, which
    # includes the agent hook and SSH key.
    EnableSecretsPlugin = true

    SecretsBucket = aws_s3_bucket.buildkite_secrets.id

    BuildkiteAgentRelease        = "stable"
    BuildkiteAgentTimestampLines = false

    RootVolumeName = "/dev/xvda"
    RootVolumeType = "gp2"

    # We don't have to terminate an agent after a job completes.  We have
    # an agent hook (see buildkite_agent_hook.sh) which tries to clean up
    # any state left over from previous jobs, so each instance will be "fresh",
    # but already have a local cache of Docker images and Scala libraries.
    BuildkiteTerminateInstanceAfterJob = false
  }

  # This is the price of On-Demand EC2 Instances, which can be obtained
  # from https://aws.amazon.com/ec2/pricing/on-demand/
  on_demand_ec2_pricing = {
    "r5.large"   = 0.125
    "c5.2xlarge" = 0.34
    "t3.nano"    = 0.0052
  }

  # We've occasionally seen cases where Buildkite is unable to start new
  # workers, because the Spot Price gets too high.
  #
  # Allow Spot bids up to 10% above the On-Demand price; any more than that
  # and we should investigate using a mix of On-Demand instances also.
  instance_information = {
    for name, price in local.on_demand_ec2_pricing :
    name => {
      InstanceType = name
      SpotPrice    = price * 1.1
    }
  }
}

resource "aws_cloudformation_stack" "buildkite" {
  name = "buildkite-elasticstack"

  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]

  parameters = merge(
    local.instance_information["r5.large"],
    {
      MinSize = 0
      MaxSize = 20

      BuildkiteQueue = "default"

      # This setting tells Buildkite that:
      #
      #   - it should turn off an instance if it's idle for 10 minutes (=600s)
      #   - it should pre-emptively start instances for jobs that are behind
      #     a 'wait' step
      #
      # This is a new feature we got when we updated to v5.7.2 of the
      # CloudFormation template (22 November 2021).  I'm enabling it to see
      # if it makes a difference in Scala repos where we do one autoformat step
      # and then fan out to the main build.
      #
      ScaleOutForWaitingJobs = true
      ScaleInIdlePeriod      = 600

      InstanceRoleName = local.ci_agent_role_name

      # Before a job starts, Buildkite will do a disk health check for
      # free space.  We used to have this set at 25GB, but on days with
      # lots of builds (and so lots of long-lived agents) we started to
      # see errors from this health check:
      #
      #     Not enough disk space free, cutoff is 5242880 🚨
      #     Disk health checks failed
      #
      # If you see this error again, consider increasing this limit.
      RootVolumeSize = 30

      # If we don't disable this setting, we get this error when trying to
      # run Docker containers on the instances:
      #
      #     docker: Error response from daemon: cannot share the host's
      #     network namespace when user namespaces are enabled.
      #
      EnableDockerUserNamespaceRemap = false
    },
    local.common_parameters
  )

  template_body = file("${path.module}/buildkite-v5.16.1.yml")
}

# This is a separate pool of Buildkite instances specifically meant
# for high-CPU, Scala tasks.  They use more expensive instances with
# more compute power to make those tasks go faster.
#
# You can target this queue by adding the following lines to the
# Buildkite steps:
#
#      agents:
#        queue: "scala"
#
resource "aws_cloudformation_stack" "buildkite_scala" {
  name = "buildkite-elasticstack-scala"

  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]

  parameters = merge(
    local.instance_information["c5.2xlarge"],
    {
      BuildkiteQueue = "scala"

      MinSize = 0
      MaxSize = 60

      # This setting would tell Buildkite to scale out for steps behind wait
      # steps.
      #
      # We don't enable it for nano instances because these are often waiting
      # behind long-running tasks in the large queue (e.g. build and publish
      # a Docker image, then deploy it from a nano instance) and the pre-emptively
      # scaled instances would likely time out before they were used.
      #
      ScaleOutForWaitingJobs = false

      # If we don't disable this setting, we get this error when trying to
      # run Docker containers on the instances:
      #
      #     docker: Error response from daemon: cannot share the host's
      #     network namespace when user namespaces are enabled.
      #
      EnableDockerUserNamespaceRemap = false

      InstanceRoleName = local.ci_scala_agent_role_name

      # Before a job starts, Buildkite will do a disk health check for
      # free space.  We used to have this set at 25GB, but on days with
      # lots of builds (and so lots of long-lived agents) we started to
      # see errors from this health check:
      #
      #     Not enough disk space free, cutoff is 5242880 🚨
      #     Disk health checks failed
      #
      # If you see this error again, consider increasing this limit.
      RootVolumeSize = 30
    },
    local.common_parameters
  )

  template_body = file("${path.module}/buildkite-v5.16.1.yml")
}

# This is a separate pool of Buildkite instances specifically meant
# for long-running, low-compute tasks.
#
# e.g. waiting for a blue-green deployment of new services
#
# I picked the name "nano" because they're a catchall group for any sort
# of small task, rather than for a specific purpose.
#
# You can target this queue by adding the following lines to the
# Buildkite steps:
#
#      agents:
#        queue: "nano"
#
resource "aws_cloudformation_stack" "buildkite_nano" {
  name = "buildkite-elasticstack-nano"

  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]

  parameters = merge(
    local.instance_information["t3.nano"],
    {
      BuildkiteQueue = "nano"

      MinSize = 0
      MaxSize = 10

      # This setting would tell Buildkite to scale out for steps behind wait
      # steps.
      #
      # We don't enable it for nano instances because these are often waiting
      # behind long-running tasks in the large queue (e.g. build and publish
      # a Docker image, then deploy it from a nano instance) and the pre-emptively
      # scaled instances would likely time out before they were used.
      #
      ScaleOutForWaitingJobs = false

      InstanceRoleName = local.ci_nano_agent_role_name

      RootVolumeSize = 10
    },
    local.common_parameters
  )

  template_body = file("${path.module}/buildkite-v5.16.1.yml")
}
