resource "aws_security_group" "web_server" {
  name_prefix = "web-${random_string.lab_id.result}"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["10.0.0.0/24"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name     = "Web server"
    "Lab-ID" = random_string.lab_id.result
  }


}

resource "aws_security_group" "db" {
  name_prefix = "DB-${random_string.lab_id.result}"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    security_groups = [aws_security_group.web_server.id]

  }
  tags = {
    Name     = "DB"
    "Lab-ID" = random_string.lab_id.result
  }
}

resource "aws_security_group" "lb" {
  name_prefix = "LB-${random_string.lab_id.result}"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]

  }

  egress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [aws_security_group.web_server.id]

  }

  tags = {
    Name     = "DB"
    "Lab-ID" = random_string.lab_id.result
  }
}