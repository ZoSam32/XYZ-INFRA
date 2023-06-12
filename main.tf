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
  subscription_id = local.settings.subscription_id
  client_id       = local.settings.client_id
  client_secret   = local.settings.client_secret
  tenant_id       = local.settings.tenant_id
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