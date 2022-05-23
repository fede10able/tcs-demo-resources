
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

    root_block_device {
        encrypted = false
        volume_size = 20
        volume_type = "standard"
        tags = local.default_tags
    }

    subnet_id = random_shuffle.web_subnet.result[0]

    tags = merge(local.default_tags,
        {
            Name = "${replace(local.user_mail,"@","-")}-${random_string.bucket_suffix.result}"
        }
    )

    # key_name = aws_key_pair.kp.key_name

    vpc_security_group_ids = [aws_security_group.web_sg.id]
}

resource "random_shuffle" "web_subnet" {
    input        = jsondecode(data.aws_ssm_parameter.demo_vpc_private_subnets.value)
    result_count = 1
}

resource "aws_security_group" "web_sg" {
  name        = "${replace(local.user_mail,"@","-")}-${random_string.bucket_suffix.result}"
  vpc_id      = data.aws_ssm_parameter.demo_vpc_id.value

    ingress {
        description      = "Incoming SSH"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = [ "0.0.0.0/0" ]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = merge(local.default_tags,
        {
            Name = "${replace(local.user_mail,"@","-")}-${random_string.bucket_suffix.result}"
        }
    )
}