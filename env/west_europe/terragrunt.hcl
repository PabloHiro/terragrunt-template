generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
    subscription_id = "${local.environment_vars.subscription}"
    tenant_id = "${local.environment_vars.tenant}"
    skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers
    features {}
}
EOF
}

remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    resource_group_name  = local.environment_vars.resource_group
    storage_account_name = local.environment_vars.storage_account
    container_name       = local.environment_vars.container_name
    key                  = "${path_relative_to_include()}/terraform.tfstate"
    subscription_id      = local.environment_vars.subscription
    tenant_id            = local.environment_vars.tenant
  }
}

locals {
  secret_vars      = try(yamldecode(sops_decrypt_file("${find_in_parent_folders("secrets.yaml")}")), {})
  environment_vars = yamldecode(file("${find_in_parent_folders("environment.yaml")}"))
  region_vars      = yamldecode(file("${find_in_parent_folders("region.yaml", find_in_parent_folders("environment.yaml"))}"))
  module_vars      = yamldecode(file("${find_in_parent_folders("module.yaml", find_in_parent_folders("environment.yaml"))}"))
  resource_vars    = yamldecode(file(fileexists("${path_relative_to_include()}/resource.yaml") ? "${path_relative_to_include()}/resource.yaml" : find_in_parent_folders("environment.yaml")))
}

# Build inputs based on the environment, region, module, and resource variables.
# IMPORTANT: Deep merging is not possible with Terraform, so we have to do a shallow merge here. If a variable is redefined in a lower level, it will overwrite the value from the higher level.
# IMPORTANT: Deep merge is only performed for the "tags" field
# `Try` is used to handle the case when a .yaml file exists but is empty at a certain level. In those cases, yamldecode returns null and the lookup function would fail.
inputs =  merge(
  local.secret_vars,
  local.environment_vars,
  local.region_vars,
  local.module_vars,
  local.resource_vars,
  {
    tags = merge(
      try(lookup(local.environment_vars, "tags", {}), {}),
      try(lookup(local.region_vars, "tags", {}), {}),
      try(lookup(local.module_vars, "tags", {}), {}),
      try(lookup(local.resource_vars, "tags", {}), {}),
    )
  }
)