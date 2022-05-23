
resource "aws_api_gateway_resource" "resource" {
    rest_api_id = var.rest_api_id
    parent_id   = var.parent_id
    path_part   = var.path_part
}

## OPTION METHOD to enable CORS support
resource "aws_api_gateway_method" "resource_options" {
    count = var.enable_cors ? 1 : 0

    rest_api_id = var.rest_api_id
    resource_id = aws_api_gateway_resource.resource.id
    http_method   = "OPTIONS"
    authorization = "NONE"
}
resource "aws_api_gateway_method_response" "resource_options_200" {
    count = var.enable_cors ? 1 : 0

    rest_api_id = var.rest_api_id
    resource_id = aws_api_gateway_resource.resource.id
    http_method   = aws_api_gateway_method.resource_options[0].http_method
    
    status_code   = "200"
    response_models = {
        "application/json" = "Empty",

    }
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }

}
resource "aws_api_gateway_integration" "options_integration" {
    count = var.enable_cors ? 1 : 0

    rest_api_id = var.rest_api_id
    resource_id = aws_api_gateway_resource.resource.id
    http_method   = aws_api_gateway_method.resource_options[0].http_method
    type          = "MOCK"

    content_handling = "CONVERT_TO_TEXT"

    request_templates = {
        "application/json" = "{ \"statusCode\": 200 }"
    }

}
resource "aws_api_gateway_integration_response" "options_integration_response" {
    count = var.enable_cors ? 1 : 0

    rest_api_id = var.rest_api_id
    resource_id = aws_api_gateway_resource.resource.id
    http_method   = aws_api_gateway_method.resource_options[0].http_method
    status_code   = aws_api_gateway_method_response.resource_options_200[0].status_code

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = var.allow_header,
        "method.response.header.Access-Control-Allow-Methods" = var.allow_method
        "method.response.header.Access-Control-Allow-Origin" = var.allow_origin
    }
}