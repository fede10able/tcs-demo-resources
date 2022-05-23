
default_aws_region = "us-east-1"

## Default tags
default_tags = {
    project = "tcs-demo-envs"
    createdBy = "global-ses"
    environment = "demo"
}

## Resources paths
resource_ride = "ride"
resource_compare_yourself_type = "{type}"

## Lambda
lambdas_folder = "./lambdas"
packages_folder = "./packages"
lambda_handler = "function.handler"
stage_name = "prod"

## Models
models = {
    CompareData = <<-EOS
        {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "title": "CompareData",
            "type": "object",
            "properties": {
                "age": {"type": "integer"},
                "height": {"type": "integer"},
                "income": {"type": "integer"}
            },
            "required": ["age", "height", "income"]
        }
        EOS
    CompareDataArray = <<-EOS
        {
            "$schema": "http://json-schema.org/draft-04/schema#",
            "title": "CompareData",
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "age": {"type": "integer"},
                    "height": {"type": "integer"},
                    "income": {"type": "integer"}
                },
                "required": ["age", "height", "income"]
            }
        }
        EOS


}

## DyanmoDB Table
dynamodb_table_name = "Rides"
dynamodb_table_pkey = "RideId"

## Website 
website_folder = "./website"
config_js_template = "./templates/config.js.template"
config_js_output = "js/config.js"
## Cognito
cognito_app_name = "WildRydesWebApp"