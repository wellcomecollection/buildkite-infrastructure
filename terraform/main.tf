module "default" {
  source = "./stack"

  name       = "buildkite-elasticstack"
  queue_name = "default"

  ci_agent_role_name = local.ci_agent_role_name

  disk_size = "40 GB"

  max_workers = 20

  extra_parameters = {
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
    InstanceType           = "r5.large"
    SpotPrice              = local.on_demand_ec2_pricing["r5.large"] * 1.1
    SecurityGroupId        = local.network_config["security_group_id"]
  }

  elastic_ci_stack_templates_bucket = aws_s3_bucket.buildkite_config.bucket
  elastic_ci_stack_version          = "v5.16.1"

  network_config    = local.network_config
  secrets_bucket_id = aws_s3_bucket.buildkite_secrets.id
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
module "scala" {
  source = "./stack"

  name       = "buildkite-elasticstack-scala"
  queue_name = "scala"

  ci_agent_role_name = local.ci_scala_agent_role_name

  disk_size = "40 GB"

  max_workers = 60

  extra_parameters = {
    # This setting would tell Buildkite to scale out for steps behind wait
    # steps.
    #
    # We don't enable it for nano instances because these are often waiting
    # behind long-running tasks in the large queue (e.g. build and publish
    # a Docker image, then deploy it from a nano instance) and the pre-emptively
    # scaled instances would likely time out before they were used.
    #
    ScaleOutForWaitingJobs = false
    InstanceType           = "c5.2xlarge"
    SpotPrice              = local.on_demand_ec2_pricing["c5.2xlarge"] * 1.1
    SecurityGroupId        = local.network_config["security_group_id"]
  }

  elastic_ci_stack_templates_bucket = aws_s3_bucket.buildkite_config.bucket
  elastic_ci_stack_version          = "v5.16.1"

  network_config    = local.network_config
  secrets_bucket_id = aws_s3_bucket.buildkite_secrets.id
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
module "nano" {
  source = "./stack"

  name       = "buildkite-elasticstack-nano"
  queue_name = "nano"

  ci_agent_role_name = local.ci_nano_agent_role_name

  disk_size = "20 GB"

  max_workers = 10

  extra_parameters = {
    # This setting would tell Buildkite to scale out for steps behind wait
    # steps.
    #
    # We don't enable it for nano instances because these are often waiting
    # behind long-running tasks in the large queue (e.g. build and publish
    # a Docker image, then deploy it from a nano instance) and the pre-emptively
    # scaled instances would likely time out before they were used.
    #
    ScaleOutForWaitingJobs = false
    InstanceType           = "t3.nano"
    SpotPrice              = local.on_demand_ec2_pricing["t3.nano"] * 1.1
    SecurityGroupId        = local.network_config["security_group_id"]
  }

  elastic_ci_stack_templates_bucket = aws_s3_bucket.buildkite_config.bucket
  elastic_ci_stack_version          = "v5.16.1"

  network_config    = local.network_config
  secrets_bucket_id = aws_s3_bucket.buildkite_secrets.id
}

module "test-upgrade" {
  source = "./stack"

  name       = "buildkite-elasticstack-test-upgrade"
  queue_name = "test-upgrade"

  ci_agent_role_name = local.ci_test_upgrade_agent_role_name

  disk_size = "40 GB"

  max_workers = 60

  extra_parameters = {
    # This setting would tell Buildkite to scale out for steps behind wait
    # steps.
    #
    # We don't enable it for nano instances because these are often waiting
    # behind long-running tasks in the large queue (e.g. build and publish
    # a Docker image, then deploy it from a nano instance) and the pre-emptively
    # scaled instances would likely time out before they were used.
    #
    ScaleOutForWaitingJobs = false
    InstanceTypes          = "c5.2xlarge"
    SecurityGroupIds       = local.network_config["security_group_id"]
    SpotAllocationStrategy = "price-capacity-optimized"
    OnDemandPercentage     = 0
  }

  elastic_ci_stack_templates_bucket = aws_s3_bucket.buildkite_config.bucket
  elastic_ci_stack_version          = "v6.10.0"

  network_config    = local.network_config
  secrets_bucket_id = aws_s3_bucket.buildkite_secrets.id
}