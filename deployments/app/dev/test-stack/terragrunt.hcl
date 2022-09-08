include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  domain = "ekrata.com"
  instance_type  = "m2.large"
}
