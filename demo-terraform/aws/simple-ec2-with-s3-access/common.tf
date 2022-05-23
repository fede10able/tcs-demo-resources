locals {
    ## Account definitions
    ssm_param_config_demo_region = "/config/demo/region"
    ssm_param_config_demo_ec2_allowed_regions = "/config/demo/ec2-allowed-regions"
    ssm_param_config_demo_ec2_allowed_instance_types = "/config/demo/ec2-allowed-instance-types"
    ssm_param_config_demo_notification_emails = "/config/budget/notification-emails"

    ## VPC parameters
    ssm_param_shared_vpc_base = "/shared/vpc"
    ssm_param_shared_vpc_id = "id"
    ssm_param_shared_vpc_public_subnets = "public_subnets"
    ssm_param_shared_vpc_private_subnets = "private_subnets"

    ssm_param_shared_setup_tenable_cs_role_arn = "/shared/setup-tenable-cs/role-arn"
    ssm_param_shared_setup_tenable_cs_external_id = "/shared/setup-tenable-cs/external-id"


    ## Secrets
    ssm_param_secrets_setup_tenable_cs_tenable_account_id = "/secrets/setup-tenable.cs/tenable-account-id"
}