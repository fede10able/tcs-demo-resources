variable aws_default_region { type = string }

variable vpc_flow_log_format { type = string }

variable aws_key_pair_pub { type = string }


variable output_aws_flow_collect_env { type = string }
variable output_aws_orch_pass_env { type = string }

resource "random_string" "lab_id" {
  length  = 10
  special = false
}
