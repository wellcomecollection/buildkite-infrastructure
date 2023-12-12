resource "aws_cloudformation_stack" "buildkite" {
  name = var.name

  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]

  parameters = merge(
    {
      MinSize = var.min_workers
      MaxSize = var.max_workers

      BuildkiteQueue = var.queue_name

      # We've occasionally seen cases where Buildkite is unable to start new
      # workers, because the Spot Price gets too high.
      #
      # Allow Spot bids up to 10% above the On-Demand price; any more than that
      # and we should investigate using a mix of On-Demand instances also.

      InstanceTypes    = var.instance_type
      InstanceRoleName = var.ci_agent_role_name

      RootVolumeSize = parseint(replace(var.disk_size, " GB", ""), 10)

      # If we don't disable this setting, we get this error when trying to
      # run Docker containers on the instances:
      #
      #     docker: Error response from daemon: cannot share the host's
      #     network namespace when user namespaces are enabled.
      #
      EnableDockerUserNamespaceRemap = false
    },
    var.extra_parameters,
    local.common_parameters
  )

  template_url = "http://s3.amazonaws.com/${var.elastic_ci_stack_templates_bucket}/stack_templates/${var.elastic_ci_stack_version}.yml"
}