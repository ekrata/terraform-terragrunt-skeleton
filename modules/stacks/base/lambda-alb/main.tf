# The AWS region to use for the dev environment's infrastructure.
variable "region" {
  default = "eu-west-2"
}

# The AWS Profile to use
variable "aws_profile" {
  default = "default"
  
}

provider "aws" {
  region  = "${var.region}"
}

data "aws_caller_identity" "current" {}

locals {
  ns      = "${var.app}-${var.environment}"
  subnets = "${split(",", var.internal == true ? var.private_subnets : var.public_subnets)}"
}

provider "dns" {
  update {
    server        = "${var.dns_ip}"
    key_name      = "${var.dns_key}"
    key_algorithm = "hmac-md5"
    key_secret    = "${var.dns_key_secret}"
  }
    # update {
    #   server                  = "${var.domain}"
    #   transport = "tcp"
    #   timeout = 20
    # }
}

terraform {
  required_providers {
    aws = {
      version = ">= 1.53.0"
    }
  }
}