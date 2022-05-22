
data "aws_caller_identity" "current" {}

variable "instance_type" { type = string }
variable "default_aws_region" { type = string }

variable "default_tags" { type = map }

locals {
    default_tags = merge(
        var.default_tags , 
        {
            userid =  data.aws_caller_identity.current.user_id
        }
    )
}