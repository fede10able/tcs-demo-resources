

locals {

    template_aws_flow_coll = <<EOT
# GC_API_SERVER: Centra IP/URL Address. Used to push the connections.
GC_API_SERVER=
# GC_API_USER: Centra Management API user.
GC_API_USER=
# GC_API_PASSWORD: Centra Management API password.
GC_API_PASSWORD= 
# AWS_DEFAULT_REGION: AWS regios where the VPC is. 
AWS_DEFAULT_REGION=${var.aws_default_region}
# AWS_VPC_LOG_GROUP_NAME: Name of the loggroup were the VPC flowas are stored.
AWS_VPC_LOG_GROUP_NAME=${aws_cloudwatch_log_group.vpc_flows.name} 
# AWS_ACCESS_KEY_ID: AWS Access Key ID required to access the VPC Logs. See AWS IAM User definition.
AWS_ACCESS_KEY_ID=${aws_iam_access_key.orch_user.id}
# AWS_SECRET_ACCESS_KEY: AWS Secret Access Key required to access the VPC Logs.
AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.orch_user.secret}
# AWS_SESSION_TOKEN: (Optional) Session token in case that you are using STS roles. This is a temporary token, so used only for short time demos. For long time run, create a user with a permanent permissions. 
# AWS_SESSION_TOKEN

# Optional variables: 
# REFRESH_RATE: Seconds between each VPC collection run. The program try to adjust the sleep time between run based on the time consumed and this value. Default: 60 seconds
# REFRESH_RATE=60
# FLOW_BACKWARD_IMPORT: How much time to go back in time to collect past flows. Default 24hs.
# FLOW_BACKWARD_IMPORT=86400
EOT

    template_aws_orch_pass = <<EOT
AWS_DEFAULT_REGION=${var.aws_default_region}
# GC_INVENTORY_API_SERVER: Aggregator IP/URL Address with the Inventory API confgured. Used to push the assets.
GC_INVENTORY_API_SERVER=
# GC_INVENTORY_API_USER: Centra Inventory API user. 
GC_INVENTORY_API_USER=
# GC_INVENTORY_API_PASSWORD: Centra Inventory API password.
GC_INVENTORY_API_PASSWORD=
# GC_INVENTORY_API_TOKEN: Centra Inventory API token. 
# GC_INVENTORY_API_TOKEN=

# AWS_ACCESS_KEY_ID: AWS Access Key ID required to access the VPC Logs. See AWS IAM User definition.
AWS_ACCESS_KEY_ID=${aws_iam_access_key.orch_user.id}
# AWS_SECRET_ACCESS_KEY: AWS Secret Access Key required to access the VPC Logs.
AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.orch_user.secret}

Optional variables: 
# REFRESH_RATE: Seconds between each VPC collection run. The program try to adjust the sleep time between 
#               run based on the time consumed and this value. Default: 300 seconds
REFRESH_RATE=300
# ENABLED_COLLECTORS: Collector to run. There is one collector per asset type. 
#                     Can add more than one in a comma separated list. Default "*".
#                     Avalable options are: AWS_RDS,AWS_EFS,AWS_ECS,AWS_LAMBDA,AWS_ELB
ENABLED_COLLECTORS=AWS_RDS,AWS_ELB
EOT

}

resource "local_file" "aws_coll_env_file" {
    content = local.template_aws_flow_coll
    filename = var.output_aws_flow_collect_env
}

resource "local_file" "aws_orch_env_file" {
    content = local.template_aws_orch_pass
    filename = var.output_aws_orch_pass_env
}

