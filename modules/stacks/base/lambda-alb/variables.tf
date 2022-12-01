/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# Tags for the infrastructure
variable "tags" {
  type = map
}

# The application's name
variable "app" {}

# The environment that is being built
variable "environment" {}

# The port the load balancer will listen on
variable "lb_port" {
  default = "80"
}

# The load balancer protocol
variable "lb_protocol" {
  default = "HTTP"
}

variable "db_password" {
 type = string
}

variable "porkbun_config" {
  type = map(string)
  default = {
    api_key = "",
    secret_key = ""
  }
}

variable "dns_ip" {
  description = "IP address of Master DNS-Server"
}
variable "dns_key" {
  description = "name of the DNS-Key to user"
}
variable "dns_key_secret" {
  description = "base 64 encoded string"
}

variable "TF_VAR_porkbun_secret_key" {
  type = string
  default = ""
}

variable "TF_VAR_porkbun_api_key" {
  type = string
  default = ""
}

variable "TF_VAR_cloudflare_zone_id" {
  type = string
  default = ""
}

variable "TF_VAR_cloudflare_account_id" {
  type = string
  default = ""
}

variable "TF_VAR_cloudflare_api_token" {
  type = string
  default = ""
}

variable "TF_VAR_cloudflare_api_key" {
  type = string
  default = ""
}

variable "TF_VAR_cloudflare_email" {
  type = string
  default = ""
}

variable "CLOUDFLARE_API_TOKEN" {
  type = string
  sensitive = true
  default = ""
}

variable "subdomain" {
  type = string
  default = ""
}

# Network configuration

# The VPC to use for the Fargate cluster
variable "vpc_id" {}

# The private subnets, minimum of 2, that are a part of the VPC(s)
variable "private_subnets" {}

# The public subnets, minimum of 2, that are a part of the VPC(s)
variable "public_subnets" {}

# The lambda runtime
variable "lambda_runtime" {
  default = "nodejs16.x"
}

# The lambda handler
variable "lambda_handler" {
  default = "index.handler"
}

# The lambda timeout
variable "lambda_timeout" {
  default = "30"
}

# The SAML role to use for adding users to the ECR policy
variable "saml_role" {
  default = "ecr_role"
}
