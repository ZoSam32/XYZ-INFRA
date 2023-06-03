locals {
  workspace_path = "${path.module}/workspaces/${terraform.workspace}.yaml"
  defaults       = file("./config.yaml")
  workspace      = fileexists(local.workspace_path) ? file(local.workspace_path) : yamlencode({})
  settings = merge(
    yamldecode(local.defaults),
    yamldecode(local.workspace)
  )
}

# variable "client_secret" {
#   description = "What is the password for the service principal account"
# }
# terraform {
#   backend "azurerm" {
#     container_name = "tstate"
#     key            = "xyz/terraform.tfstate"
#   }
# }

provider "azurerm" {
#   subscription_id = local.settings.subscription_id
#   client_id       = local.settings.spn_id
#   client_secret   = var.client_secret
#   tenant_id       = "e05b1f1d-4425-476a-8b6d-cf9e17a51da7"
  features {}
}

resource "azurerm_resource_group" "xyz" {
    name = "rg-xyz-${local.settings.environment}-${local.settings.az_region}-${local.settings.service}"
    location = local.settings.location
    tags = local.settings.tags
}

resource "azurerm_kubernetes_cluster" "xyz" {
    name = "aks-xyz-${local.settings.environment}-${local.settings.az_region}-${local.settings.service}"
    location = azurerm_resource_group.xyz.location
    resource_group_name = azurerm_resource_group.xyz.name
    dns_prefix = "xyzpoc"

    default_node_pool {
      name = "default"
      node_count = 2
      vm_size = "Standard_B2s"
    }

    identity {
      type = "SystemAssigned"
    }

    tags = local.settings.tags
}


data "azurerm_container_registry" "xyz" {
  name = "xyzappsample"
  resource_group_name = "acr-sample"
}

resource "azurerm_role_assignment" "acr" {
    principal_id = azurerm_kubernetes_cluster.xyz.kubelet_identity[0].object_id
    role_definition_name = "AcrPull"
    scope = data.azurerm_container_registry.xyz.id
}