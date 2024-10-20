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
variable "app_port" {}

variable "listener_arn" {}
variable "listener_priority" {}
variable "dns_name" {}

variable "domain_name" {}
variable "domain_id" {}
#variable "lb_dns_name" {}