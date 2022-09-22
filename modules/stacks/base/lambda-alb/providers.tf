
terraform {
  required_providers {
    porkbun = {
      source = "cullenmcdermott/porkbun"
      version = "0.1.0"
    }
  }
}

provider "porkbun" {
  api_key = local.porkbun_config["api_key"]
  secret_key = local.porkbun_config["secret_key"]
  # Configuration options
}


provider "aws" { region = "eu-west-2" }