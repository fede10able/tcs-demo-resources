
locals {
    ssh_key_name = "demo-key-${data.aws_caller_identity.current.user_id}"
}

# ## Generate a new key
# resource "tls_private_key" "ssh_key" {
#     algorithm = "ED25519"
# }
# ## Register the key in AWS
# resource "aws_key_pair" "kp" {
#     key_name   = "demo-key-${data.aws_caller_identity.current.user_id}"
#     public_key = tls_private_key.ssh_key.public_key_openssh
# }
# ## Write the key in artifacs folder
# resource "local_file" "ssk_key_pub" {
#     content  = tls_private_key.ssh_key.public_key_openssh
#     filename = "./artifacts/${local.ssh_key_name}.pub"
# }
# resource "local_file" "ssk_key_priv" {
#     content  = tls_private_key.ssh_key.private_key_openssh
#     filename = "./artifacts/${local.ssh_key_name}"
# }

## Search for an Ubuntu AMI in your region 
data "aws_ami" "ubuntu" {
    most_recent = true
    name_regex = "^.*ubuntu-focal-20.04-amd64-server-.*"    
    owners = [ "099720109477" ] ## Canonical

    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_instance" "web" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type

    tags = local.default_tags

    # key_name = aws_key_pair.kp.key_name
}
