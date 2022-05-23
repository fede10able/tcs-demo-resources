

data "aws_ssm_parameter" "demo_vpc_id" {
    name = "/shared/vpc/vpc-demo-ses/id"
}

data "aws_ssm_parameter" "demo_vpc_public_subnets" {
    name = "/shared/vpc/vpc-demo-ses/public_subnets"
}

data "aws_ssm_parameter" "demo_vpc_private_subnets" {
    name = "/shared/vpc/vpc-demo-ses/private_subnets"
}