data "aws_vpc_endpoint_service" "ecr_dkr" {
  service = "ecr.dkr"
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = local.ci_vpc_id
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.buildkite.id,
  ]

  subnet_ids = local.ci_vpc_private_subnets

  service_name = data.aws_vpc_endpoint_service.ecr_dkr.service_name

  private_dns_enabled = true

  tags = {
    Name = "buildkite-ecr_dkr-vpc_endpoint"
  }
}

data "aws_vpc_endpoint_service" "ecr_api" {
  service = "ecr.api"
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = local.ci_vpc_id
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.buildkite.id,
  ]

  subnet_ids = local.ci_vpc_private_subnets

  service_name = data.aws_vpc_endpoint_service.ecr_api.service_name

  private_dns_enabled = true

  tags = {
    Name = "buildkite-ecr_api-vpc_endpoint"
  }
}
