
locals {
    lambda_dirs = toset(distinct([ for f in fileset("${var.lambdas_folder}/" , "*/**" ) : split("/", f )[0] ]))
}

## Zip lambdas packages
data "archive_file" "lambda_package" {
    for_each = local.lambda_dirs

    type = "zip"
    source_dir = "${var.lambdas_folder}/${each.key}"
    output_path = "${var.packages_folder}/${each.key}.zip"
}

## Define generic role with minimun policies
resource "aws_iam_role" "lambdas" {
    for_each = local.lambda_dirs

    name = "lambda-${each.key}-${random_string.uniq.result}"

    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

    tags = local.project_tags

}

## Search basic policy for lambdas
data "aws_iam_policy" "basic_for_lambdas" {
    name = "AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "basic_for_lambdas" {
    for_each = aws_iam_role.lambdas

    role = each.value.name
    policy_arn = data.aws_iam_policy.basic_for_lambdas.arn
}

resource "aws_lambda_function" "lambda" {
    for_each = local.lambda_dirs

    function_name = "${each.key}-${random_string.uniq.result}"
    runtime = "nodejs14.x"

    filename = data.archive_file.lambda_package[each.key].output_path
    source_code_hash = data.archive_file.lambda_package[each.key].output_base64sha256

    role          = aws_iam_role.lambdas[each.key].arn
    handler       = var.lambda_handler

    memory_size = 128
    timeout = 10

    environment {
        variables = {
            DYNAMODB_TABLE_NAME = aws_dynamodb_table.basic-dynamodb-table.name
            DEFAULT_REGION = var.default_aws_region
        }
    }

    tags = local.project_tags

}