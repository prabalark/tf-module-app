#resource "aws_instance" "inst" {
#  ami           = data.aws_ami.ami.id
#  instance_type = var.instance_type
#  subnet_id     = var.subnet_id
#}

resource "aws_security_group" "asg" {
  name        = "${var.name}-${var.env}-asg"
  description = "${var.name}-${var.env}-asg"
  vpc_id      = var.vpc_id

  ingress {
    description = "app"
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = var.allow_app_cidr # sunet_cidrs from internet
  }

  ingress {
    description = "ssh"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.bastion_cidr #terraform pri-ip address
  }

  ingress {
    description = "PROMETHEUS"
    protocol    = "tcp"
    from_port   = 9100
    to_port     = 9100
    cidr_blocks = var.monitor_cidr #terraform pri-ip address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags =merge(var.tags, { Name = "${var.name}-asg-${var.env}" })
}

resource "aws_launch_template" "template" {
  name_prefix   = "${var.name}-${var.env}-alt"
  image_id      = data.aws_ami.ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.asg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    name = var.name
    env  = var.env
  }))
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.name}-${var.env}-asg"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.subnets
  target_group_arns   = [aws_lb_target_group.main.arn]

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = local.asg_tags
    content {
      key                 = tag.key
      propagate_at_launch = true
      value               = tag.value
    }
  }

}

resource "aws_autoscaling_policy" "asg-cpu-rule" {
  name                   = "CPULoadDetect"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 20.0
  }
}
resource "aws_lb_target_group" "main" {
  name     = "${var.name}-${var.env}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  tags     = merge(var.tags, { Name = "${var.name}-alb-${var.env}" })
  deregistration_delay = 30

  health_check {
    enabled = true
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 5
    timeout = 4
    path = "/health"
  }
}

  # To listener adding rules ,
  # if we touch listener then forward to TG
resource "aws_lb_listener_rule" "rule" {
  listener_arn = var.listener_arn  # this we get from tf-module-loadbal output.tf
  priority     = var.listener_priority # web/app-server priority num will different

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {

    host_header {
      values = [local.dns_name]
    }
  }
}

resource "aws_route53_record" "main" {
  zone_id = var.domain_id   # Route53 : Hosted zone ID
  name    = local.dns_name #var.dns_name  # Route53 : record name
  records = [var.lb_dns_name] # DNS-name in Load balancers [ public & private ]
  type    = "CNAME"  # before we take A rec
  ttl     = 30
}