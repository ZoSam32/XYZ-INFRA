locals {
  workspace_path = "${path.module}/workspaces/${terraform.workspace}.yaml"
  defaults       = file("./config.yaml")
  workspace      = fileexists(local.workspace_path) ? file(local.workspace_path) : yamlencode({})
  settings = merge(
    yamldecode(local.defaults),
    yamldecode(local.workspace)
  )
}

terraform {
  backend "azurerm" {
    resource_group_name  = "acr-sample"
    storage_account_name = "tfstate7031"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  subscription_id = "a8b6779f-97c5-40d4-9992-eb8b5640a9bb"
  client_id       = "a8a01e55-5120-4ed5-9ced-e72b19d5603b"
  client_secret   = var.client_secret
  tenant_id       = "e05b1f1d-4425-476a-8b6d-cf9e17a51da7"
  features {}
}

resource "azurerm_resource_group" "xyz-metrics" {
  name     = "rg-${local.settings.environment}-${local.settings.az_region}-${local.settings.service}-metrics"
  location = local.settings.location
}

resource "azurerm_log_analytics_workspace" "xyz-metrics" {
  name                = "xyz-workspace"
  location            = local.settings.location
  resource_group_name = azurerm_resource_group.xyz-metrics.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "xyz-metrics" {
  solution_name         = "ContainerInsights"
  location              = local.settings.location
  resource_group_name   = azurerm_resource_group.xyz-metrics.name
  workspace_name        = azurerm_log_analytics_workspace.xyz-metrics.name
  workspace_resource_id = azurerm_log_analytics_workspace.xyz-metrics.id

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}


resource "azurerm_resource_group" "xyz" {
  name     = "rg-${local.settings.environment}-${local.settings.az_region}-${local.settings.service}"
  location = local.settings.location
  tags     = local.settings.tags
}

resource "azurerm_kubernetes_cluster" "xyz" {
  name                = "aks-xyz-${local.settings.environment}-${local.settings.az_region}-${local.settings.service}"
  location            = azurerm_resource_group.xyz.location
  resource_group_name = azurerm_resource_group.xyz.name
  dns_prefix          = "xyzpoc"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_B2s"
    zones      = [1, 2, 3]
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.xyz-metrics.id
  }

  tags = local.settings.tags
}


data "azurerm_container_registry" "xyz" {
  name                = "xyzappsample"
  resource_group_name = "acr-sample"
}

resource "azurerm_role_assignment" "acr" {
  principal_id         = azurerm_kubernetes_cluster.xyz.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = data.azurerm_container_registry.xyz.id
}