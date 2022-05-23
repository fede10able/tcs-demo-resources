

resource "aws_api_gateway_rest_api" "ride" {
    name        = "api-${random_string.uniq.result}"
}

resource "aws_api_gateway_authorizer" "ride" {
    name                   = "api-auth-${random_string.uniq.result}"
    rest_api_id            = aws_api_gateway_rest_api.ride.id

    type = "COGNITO_USER_POOLS"
    provider_arns = [
        aws_cognito_user_pool.pool.arn
    ]

}

module "sless_app_ride" {
    source = "./modules/create-api-gateway-resource"

    rest_api_id = aws_api_gateway_rest_api.ride.id
    parent_id   = aws_api_gateway_rest_api.ride.root_resource_id
    path_part   = var.resource_ride

    enable_cors = true
}

resource "time_sleep" "wait_30_before_deployment" {

  create_duration = "30s"

  depends_on = [
    module.sless_app_ride,
    
  ]

}

resource "aws_api_gateway_deployment" "ride" {
    rest_api_id = aws_api_gateway_rest_api.ride.id

    triggers = {
        redeployment = sha1(jsonencode(aws_api_gateway_rest_api.ride.body))
        redeployment = timestamp()
    }

    lifecycle {
        create_before_destroy = true
    }

    # depends_on = [
    #   time_sleep.wait_30_before_deployment
    # ]
}

output "stage_invoke_url" {
    value = aws_api_gateway_stage.prod.invoke_url
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.ride.id
  rest_api_id   = aws_api_gateway_rest_api.ride.id
  stage_name    = var.stage_name
}



## compare-yourself POST -> Lambda compare-yourself-post
resource "aws_api_gateway_method" "sless_app_ride_post" {
    rest_api_id = aws_api_gateway_rest_api.ride.id
    resource_id = module.sless_app_ride.aws_api_gateway_resource.id

    http_method   = "POST"

    authorization = "COGNITO_USER_POOLS"
    authorizer_id = aws_api_gateway_authorizer.ride.id
}

resource "aws_api_gateway_integration" "sless_app_ride_post" {
    rest_api_id = aws_api_gateway_rest_api.ride.id
    resource_id = module.sless_app_ride.aws_api_gateway_resource.id
    http_method = aws_api_gateway_method.sless_app_ride_post.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = aws_lambda_function.lambda["RequestUnicorn"].invoke_arn
}
resource "aws_lambda_permission" "sless_app_ride_post" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda["RequestUnicorn"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ride.execution_arn}/*/*/*"
}

# ## Enable CORS for POST -> Lambda compare-yourself-post
resource "aws_api_gateway_method_response" "ride_post_200" {
    rest_api_id = aws_api_gateway_rest_api.ride.id
    resource_id = module.sless_app_ride.aws_api_gateway_resource.id
    http_method = aws_api_gateway_method.sless_app_ride_post.http_method
    status_code = "200"
    
    response_models = {
        "application/json" = "Empty",
    }

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = false,
        "method.response.header.Access-Control-Allow-Origin" = false
    }

}
resource "aws_api_gateway_integration_response" "ride_post_200_response" {
    rest_api_id = aws_api_gateway_rest_api.ride.id
    resource_id = module.sless_app_ride.aws_api_gateway_resource.id
    http_method = aws_api_gateway_method.sless_app_ride_post.http_method
    status_code = aws_api_gateway_method_response.ride_post_200.status_code

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
    depends_on = [
        module.sless_app_ride,
        aws_api_gateway_integration.sless_app_ride_post
    ]
}
