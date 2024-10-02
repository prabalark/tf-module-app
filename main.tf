#resource "aws_instance" "inst" {
#  ami           = data.aws_ami.ami.id
#  instance_type = var.instance_type
#  subnet_id     = var.subnet_id
#}

resource "aws_launch_template" "template" {
  name_prefix   = "${var.name}-${var.env}-alt"
  image_id      = data.aws_ami.ami.id
  instance_type = var.instance_type
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
}