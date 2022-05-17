
locals {
    log_name = "flows-${random_string.lab_id.result}"
    role_name = "role-${random_string.lab_id.result}"
    rolepol_name = "rolepol-${random_string.lab_id.result}"

}

resource "aws_flow_log" "gc_lab" {
    iam_role_arn    = aws_iam_role.vpc_flows_role.arn
    log_destination = aws_cloudwatch_log_group.vpc_flows.arn
    traffic_type = "ALL"
    log_format = var.vpc_flow_log_format
    vpc_id          = module.vpc.vpc_id
    max_aggregation_interval = 60
}

resource "aws_cloudwatch_log_group" "vpc_flows" {
  name = local.log_name
  retention_in_days = 7
}

resource "aws_iam_role" "vpc_flows_role" {
  name = local.role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

## Create the poly for the VPC Flow Service
data "aws_iam_policy_document" "vpc_flows_role_policy" {
  statement {
    sid = "VPCLogsGenerator"
    actions = [
        ## Not required because de log group is defined by terraform
        ##"logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
    ]
    resources = [
        "${aws_cloudwatch_log_group.vpc_flows.arn}:*",
        aws_cloudwatch_log_group.vpc_flows.arn
    ]
  }
}
resource "aws_iam_policy" "vpc_flows_role_policy" {
  name   = local.rolepol_name
  policy = data.aws_iam_policy_document.vpc_flows_role_policy.json
}

## Attach the policy to the role
resource "aws_iam_role_policy_attachment" "role_attach" {
  role       = aws_iam_role.vpc_flows_role.name
  policy_arn = aws_iam_policy.vpc_flows_role_policy.arn
}

