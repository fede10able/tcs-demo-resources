
output "aws_api_gateway_resource" {
    value = aws_api_gateway_resource.resource
}

output "cors_enabled" {
    value = var.enable_cors
}