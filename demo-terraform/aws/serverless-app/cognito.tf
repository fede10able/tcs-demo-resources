
locals {
    cognito_user_pool_name = "user-pool-${random_string.uniq.result}"
}

## Creates User Pool
resource "aws_cognito_user_pool" "pool" {
    name = local.cognito_user_pool_name

    auto_verified_attributes  = [
            "email",
        ]

    admin_create_user_config {
        allow_admin_create_user_only = false
    }

    tags = local.project_tags
}

resource "aws_cognito_user_pool_client" "app_client" {
    name = var.cognito_app_name

    user_pool_id = aws_cognito_user_pool.pool.id
    generate_secret = false

    supported_identity_providers = [ "COGNITO" ]

    
}