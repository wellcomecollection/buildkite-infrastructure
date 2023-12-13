locals {
  # This is a collection of settings that should be the same for every
  # instance of our Buildkite stack.
  common_parameters = {
    AgentsPerInstance = 1

    BuildkiteAgentTokenParameterStorePath = "/aws/reference/secretsmanager/builds/buildkite_agent_key"

    InstanceCreationTimeout = "PT5M"

    VpcId            = var.network_config["vpc_id"]
    Subnets          = join(",", var.network_config["subnets"])
    SecurityGroupIds = var.network_config["security_group_id"]

    SpotAllocationStrategy = "price-capacity-optimized"
    OnDemandPercentage     = 0

    CostAllocationTagName  = "aws:createdBy"
    CostAllocationTagValue = "buildkite-elasticstack"

    # This tells Buildkite to fetch secrets from our S3 bucket, which
    # includes the agent hook and SSH key.
    EnableSecretsPlugin = true

    SecretsBucket = var.secrets_bucket_id

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
  #
  # In theory there's a Terraform provider for this, but I couldn't get
  # it to work: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/pricing_product

}
