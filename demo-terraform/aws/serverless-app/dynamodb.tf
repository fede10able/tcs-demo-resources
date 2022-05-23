

## Dynamodb Table
resource "aws_dynamodb_table" "basic-dynamodb-table" {
    name = "${var.dynamodb_table_name}-${random_string.uniq.result}"
  
    # Under free tier
    billing_mode   = "PAY_PER_REQUEST"
  
    hash_key       = var.dynamodb_table_pkey

    attribute {
        name = var.dynamodb_table_pkey
        type = "S"
    }

    tags = local.project_tags
}

### DynDB data handling IAM policy
data "aws_iam_policy_document" "dyndb_data_handling_read" {
  statement {
    sid = "1"
    effect = "Allow"
    actions = [
        "dynamodb:GetItem",
        "dynamodb:Scan",
    ]

    resources = [
      aws_dynamodb_table.basic-dynamodb-table.arn
    ]
  }
}
resource "aws_iam_policy" "dyndb_data_handling_read" {
    name        = "dynbd-${var.dynamodb_table_name}-${random_string.uniq.result}-read"
    path        = local.iam_path

    policy = data.aws_iam_policy_document.dyndb_data_handling_read.json

    tags = local.project_tags
}

### DynDB data handling IAM policy
data "aws_iam_policy_document" "dyndb_data_handling_write" {
  statement {
    sid = "1"
    effect = "Allow"
    actions = [
        "dynamodb:PutItem",
    ]

    resources = [
      aws_dynamodb_table.basic-dynamodb-table.arn
    ]
  }
}
resource "aws_iam_policy" "dyndb_data_handling_write" {
    name        = "dynbd-${var.dynamodb_table_name}-${random_string.uniq.result}-write"
    path        = local.iam_path

    policy = data.aws_iam_policy_document.dyndb_data_handling_write.json

    tags = local.project_tags
}

### DynDB data handling IAM policy - delete
data "aws_iam_policy_document" "dyndb_data_handling_delete" {
  statement {
    sid = "1"
    effect = "Allow"
    actions = [
        "dynamodb:DeleteItem",
    ]

    resources = [
      aws_dynamodb_table.basic-dynamodb-table.arn
    ]
  }
}
resource "aws_iam_policy" "dyndb_data_handling_delete" {
    name        = "dynbd-${var.dynamodb_table_name}-${random_string.uniq.result}-delete"
    path        = local.iam_path

    policy = data.aws_iam_policy_document.dyndb_data_handling_delete.json

    tags = local.project_tags
}

## Attach IAM policy to lambda role
resource "aws_iam_role_policy_attachment" "dyndb_data_handling_read" {
    role = aws_iam_role.lambdas["RequestUnicorn"].name
    policy_arn = aws_iam_policy.dyndb_data_handling_read.arn
}
resource "aws_iam_role_policy_attachment" "dyndb_data_handling_delete" {
    role = aws_iam_role.lambdas["RequestUnicorn"].name
    policy_arn = aws_iam_policy.dyndb_data_handling_delete.arn
}
resource "aws_iam_role_policy_attachment" "dyndb_data_handling_write" {
    role = aws_iam_role.lambdas["RequestUnicorn"].name
    policy_arn = aws_iam_policy.dyndb_data_handling_write.arn
}