variable "global_var" {
  default = "unset"
}

variable "tier_var" {
  default = "unset"
}

variable "env_var" {
  default = "unset"
}

variable "layer_var" {
  default = "unset"
}

variable "stack_var" {
  default = "unset"
}

variable "region" {
  type = list(string)
  default = ["eu-west-2"]
}

variable "domain" {
  type = string
  default = "ekrata.com"
}

variable "main_vpc_cidr" {
  type = string
  default = "10.0.0.0/24"
}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}