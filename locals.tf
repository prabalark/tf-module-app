locals {
  asg_tags = merge(var.tags, { Name="${var.name}-${var.env}"} )
  dynamic_asg_tags = [for k ,v in local.asg_tags : tomap({ key =k , value =v })]

  dns_name = "${var.name}-${var.env}.${var.domain_name}"
  # in router53 : only for frontend we dnt require starting frnt.dev -> dev.de72..
  # remaining cata.dev.de72 etc for this in rootmodule kept condition
  # otherwise give variable in main.tfvars give names
}