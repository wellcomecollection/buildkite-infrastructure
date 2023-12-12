locals {
  s3_stack_templates_prefix                 = "stack_templates/"
  buildkite_stack_template_v5_16_1          = "${path.module}/buildkite-v5.16.1.yml"
  buildkite_stack_template_location_v6_10_0 = "${path.module}/buildkite-v6.10.0.yml"
}

resource "aws_s3_object" "buildkite_stack_template-v5_16_1" {
  bucket = aws_s3_bucket.buildkite_config.id
  key    = "${local.s3_stack_templates_prefix}v5.16.1.yml"
  source = local.buildkite_stack_template_v5_16_1
  etag   = filemd5(local.buildkite_stack_template_v5_16_1)
}

resource "aws_s3_object" "buildkite_stack_template-v6_10_0" {
  bucket = aws_s3_bucket.buildkite_config.id
  key    = "${local.s3_stack_templates_prefix}v6.10.0.yml"
  source = local.buildkite_stack_template_location_v6_10_0
  etag   = filemd5(local.buildkite_stack_template_location_v6_10_0)
}