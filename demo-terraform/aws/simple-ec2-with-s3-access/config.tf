
data "aws_caller_identity" "current" {}

variable "instance_type" { type = string }
variable "default_aws_region" { type = string }

variable "default_tags" { type = map }

locals {
    user_id_split = split(":",data.aws_caller_identity.current.user_id)
    user_mail = local.user_id_split[length(local.user_id_split)-1]
    default_tags = merge(
        var.default_tags , 
        {
            userid =  data.aws_caller_identity.current.user_id
            email = local.user_mail
        }
    )
}