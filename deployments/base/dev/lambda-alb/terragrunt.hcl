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
  vpc_id = dependency.network.outputs.vpc_id
  private_subnets = dependency.network.outputs.privatesubnets
  public_subnets = dependency.network.outputs.publicsubnets
  TF_VAR_cloudflare_zone_id = get_env("TF_VAR_cloudflare_zone_id", "")
  TF_VAR_cloudflare_api_token = get_env("TF_VAR_cloudflare_api_token", "")
  TF_VAR_cloudflare_api_key = get_env("TF_VAR_cloudflare_api_key", "")
  TF_VAR_cloudflare_email = get_env("TF_VAR_cloudflare_email", "")
  porkbun_config = {
    api_key: get_env("TF_VAR_porkbun_api_key", "")
    secret_key: get_env("TF_VAR_porkbun_secret_key", "")
  }
  environment = "dev"
  secrets_saml_users = ["ekrata.gm@gmail.com"]
  saml_role = "default"
  tags = {}
  app = "data-api-scraper"
}