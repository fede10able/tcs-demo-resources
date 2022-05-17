
## Orchestrator acccess will have an especific user for this lab
locals {
    user_name = "user-${random_string.lab_id.result}"
    policy_name = "pol-${random_string.lab_id.result}"

}


## Create the user
resource "aws_iam_user" "orch_user" {
    name = local.user_name

    tags = {
        Name = local.user_name
        "Lab-ID" = random_string.lab_id.result
        Description = "Guardicore Orchestrator User"
    }
}

## Create the access keys and print in the console
resource "aws_iam_access_key" "orch_user" {
    user = aws_iam_user.orch_user.name
}
output "user_access_key" { 
    value = "User Access ID/Secret: ${aws_iam_access_key.orch_user.id} / ${aws_iam_access_key.orch_user.secret}"
}

## create a policy that will be atached to the policy
data "aws_iam_policy_document" "orch_policy" {
    statement {
        sid = "Orchestrator"

        actions = [
            "ec2:Describe*",
            "rds:Describe*",
            "elasticfilesystem:Describe*",
            "ecs:List*",
            "ecs:Describe*",
            "lambda:GetFunction",
            "elasticloadbalancing:DescribeLoadBalancers"
        ]
        resources = [ "*" ]
    }
    statement {
        sid = "VPCLogs"
        actions = [
            "logs:Describe*",
            "logs:Get*",
            "logs:List*",
            "logs:FilterLogEvents"        
        ]
        resources = [
            "${aws_cloudwatch_log_group.vpc_flows.arn}:*"
        ]
    }
}

resource "aws_iam_policy" "orch_policy" {
    name   = local.policy_name
    policy = data.aws_iam_policy_document.orch_policy.json
}

resource "aws_iam_user_policy_attachment" "orch_policy" {
  user       = aws_iam_user.orch_user.name
  policy_arn = aws_iam_policy.orch_policy.arn
}