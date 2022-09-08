include {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    vpc_id = "dummy-id"
    publicsubnets = ["not an ip2", "not an ip"]
    privatesubnets = ["not an ip1", "not an ip2"]
  }
  mock_outputs_allowed_terraform_commands = ["validate"]
}

inputs = {
  vpc = dependency.network.outputs.vpc_id
  private_subnets = dependency.network.outputs.privatesubnets
  public_subnets = dependency.network.outputs.publicsubnets
  environment = "dev"
  secrets_saml_users = ["ekrata.gm@gmail.com"]
  saml_role = "default"
  tags = {}
  app = "data-api-scraper"
}