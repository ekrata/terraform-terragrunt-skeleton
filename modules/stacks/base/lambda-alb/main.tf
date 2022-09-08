# The AWS region to use for the dev environment's infrastructure.
variable "region" {
  default = "eu-west-2"
}

# The AWS Profile to use
variable "aws_profile" {
  default = "default"
}

data "aws_caller_identity" "current" {}

locals {
  ns      = "${var.app}-${var.environment}"
  subnets = "${split(",", var.internal == true ? var.private_subnets : var.public_subnets)}"
}
