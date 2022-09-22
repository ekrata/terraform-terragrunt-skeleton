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
  update {
    server = "192.168.1.1"
  }
}
