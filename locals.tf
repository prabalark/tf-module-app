locals {
  asg_tags = merge(var.tags, { Name="${var.name}-${var.env}"} )
  dynamic_asg_tags = [for k ,v in local.asg_tags : tomap({ key =k , value =v })]

  dns_name = "${var.dns_name}.${var.domain_name}"
  # in router53 : only for frontend we dnt require starting frnt.dev -> dev.de72..
  # remaining cata.dev.de72 etc for this in rootmodule kept condition
  # otherwise give variable in main.tfvars give names

   parameters = concat(var.parameters, [var.name])
    resources  = [for parameter in local.parameters : "arn:aws:ssm:us-east-1:${data.aws_caller_identity.identity.account_id}:parameter/${var.env}.${parameter}.*"]
}
