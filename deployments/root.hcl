locals {
  root_deployments_dir       = get_parent_terragrunt_dir()
  relative_deployment_path   = path_relative_to_include()
  deployment_path_components = compact(split("/", local.relative_deployment_path))

  tier  = local.deployment_path_components[0]
  stack = reverse(local.deployment_path_components)[0]

  # Get a list of every possible tfvars path between root_deployments_directory
  # and the path of the deployment
  possible_config_locations = [
    for i in range(0, length(local.deployment_path_components) + 1) :
    join("/", concat(
      [local.root_deployments_dir],
      slice(local.deployment_path_components, 0, i),
      ["terraform.tfvars"]
    ))
  ]
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket   = "terraform-skeleton-state-ekrata"
    region   = "eu-west-2"
    encrypt  = true
    # role_arn = "arn:aws:iam::${get_aws_account_id()}:role/terraform/TerraformBackend"
    # role_arn = "arn:aws:iam::206508349906:role/terraform/TerraformBackend"

    key = "${dirname(local.relative_deployment_path)}/${local.stack}.tfstate"

    dynamodb_table            = "terraform-skeleton-state-locks-ekrata"
    accesslogging_bucket_name = "terraform-skeleton-state-logs-ekrata"
  }
}

# Default the stack each deployment deploys based on its directory structure
# Can be overridden by redefining this block in a child terragrunt.hcl
terraform {
  source = "${local.root_deployments_dir}/../modules/stacks/${local.tier}/${local.stack}///"
  extra_arguments "load_config_files" {
    commands           = get_terraform_commands_that_need_vars()
    optional_var_files = local.possible_config_locations
  }
}
