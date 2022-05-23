
data "aws_caller_identity" "current" {}

variable "default_aws_region" { type = string }
variable "default_tags" { type = map }

## Resources paths
variable "resource_ride" { type = string }
variable "resource_compare_yourself_type" { type = string }

## Deployment
variable "stage_name" { type = string }

## Lambdas
variable "lambdas_folder" { type = string }
variable "packages_folder" { type = string }
variable "lambda_handler" { type = string }

## Models
variable "models" { type = map }

## DynamoDB table
variable "dynamodb_table_name" { type = string }
variable "dynamodb_table_pkey" { type = string }

## Website 
variable "website_folder" { type = string }
variable "config_js_template" { type = string }
variable "config_js_output" { type = string }

## Cognito
variable "cognito_app_name" { type = string }

locals {
    user_id_split = split(":",data.aws_caller_identity.current.user_id)
    user_mail = local.user_id_split[length(local.user_id_split)-1]
    project_tags = merge(
        var.default_tags , 
        {
            userid =  data.aws_caller_identity.current.user_id
            email = local.user_mail
        }
    )
    iam_path = "/"
}