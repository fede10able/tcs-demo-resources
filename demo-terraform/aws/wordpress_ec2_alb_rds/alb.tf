locals {
    lb_name = "alb${random_string.lab_id.result}"
    tg_name = "tg${random_string.lab_id.result}"
}

resource "aws_lb" "web" {

    name = local.lb_name
    internal = false ## External LB

    load_balancer_type = "application"
    ip_address_type = "ipv4"
   
    security_groups = [ aws_security_group.lb.id ]  ## Front end security group
    subnets = module.vpc.public_subnets

    tags = {
        Name = local.lb_name
        "Lab-ID" = random_string.lab_id.result
    }
}

# For each target group, creates a target group and listener in the same port and protocol
resource "aws_lb_target_group" "tg" {

    name = local.tg_name
    port = 80
    protocol = "HTTP"
    vpc_id = module.vpc.vpc_id
    target_type = "instance"

    stickiness {
        type = "lb_cookie"
    }

    tags = {
        Name = local.tg_name
        LB = local.lb_name
        "Lab-ID" = random_string.lab_id.result
    }

}
resource "aws_lb_listener" "listener" {

    load_balancer_arn = aws_lb.web.arn
    port = 80
    protocol = "HTTP" 

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.tg.arn
    }
}
