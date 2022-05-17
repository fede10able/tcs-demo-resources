data "aws_availability_zones" "available" {}



module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.66.0"

  name                 = "aws-flow-demo-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24"]
  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_hostnames = true

  tags = {
    "Name" = "aws-flow-demo-vpc"
  }

  public_subnet_tags = {
    "web_server" = "1"
  }

  private_subnet_tags = {
    "rds.endpoint" = "1"
  }
}