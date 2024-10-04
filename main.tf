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
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = var.allow_app_cidr # sunet_cidrs from internet
  }

  ingress {
    description = "ssh"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.bastion_cidr #terraform pri-ip address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.name}-${var.env}-asg"
  }
}

resource "aws_launch_template" "template" {
  name_prefix   = "${var.name}-${var.env}-alt"
  image_id      = data.aws_ami.ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.asg.id]
}

resource "aws_autoscaling_group" "asg" {
  name               = "${var.name}-${var.env}-asg"
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  vpc_zone_identifier = var.subnet_id

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each =
    content {
      key                 = tag.key
      propagate_at_launch = true
      value               = tag.value
    }
  }

}