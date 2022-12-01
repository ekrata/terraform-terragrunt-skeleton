terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0.0"
    }
  }
}

provider "aws" {
   region = "eu-west-2"
 }


provider "dns" {
    delete {
      server                  = "${var.domain_controller}.${var.domain_name}"
      gssapi {
        realm                 = upper("${var.domain_name}")
        username              = var.username
        password              = var.password
      }
    }

    create {
      server                  = "${var.domain_controller}.${var.domain_name}"
      gssapi {
        realm                 = upper("${var.domain_name}")
        username              = var.username
        password              = var.password
      }
    }
    
    update {
      server                  = "${var.domain_controller}.${var.domain_name}"
      gssapi {
        realm                 = upper("${var.domain_name}")
        username              = var.username
        password              = var.password
      }
    }
}