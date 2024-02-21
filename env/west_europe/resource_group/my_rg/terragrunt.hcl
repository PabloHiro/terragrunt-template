terraform {
  source = "git::https://github.com/PabloHiro/terraform-modules.git//azurerm_resource_group?ref=main"
}

include {
  path = find_in_parent_folders()
}
