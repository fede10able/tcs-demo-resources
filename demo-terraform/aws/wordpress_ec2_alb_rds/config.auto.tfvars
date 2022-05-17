aws_default_region = "us-east-1"

vpc_flow_log_format = "$${version} $${account-id} $${vpc-id} $${interface-id} $${type} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${tcp-flags} $${action} $${log-status}"

output_aws_flow_collect_env = "./output/aws-flow-collector/.env"
output_aws_orch_pass_env = "./output/aws-ext-orch/.env"

