variable "name" {}
variable "env" {}

variable "vpc_id" {}
variable "allow_app_cidr" {}
variable "bastion_cidr" {}

variable "instance_type" {}
variable "subnets" {}

variable "desired_capacity" {}
variable "max_size" {}
variable "min_size" {}

variable "tags" {}