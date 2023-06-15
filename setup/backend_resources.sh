#!/bin/bash

RESOURCE_GROUP_NAME=acr-sample-test
REGISTRY_NAME=xyzappsamplezzz
STORAGE_ACCOUNT_NAME=tfstate$RANDOM
CONTAINER_NAME=tfstate

# Creates the isolated resource group
az group create --name $RESOURCE_GROUP_NAME --location eastus

# Creates the ACR instance for the contianer image
az acr create --resource-group $RESOURCE_GROUP_NAME --name $REGISTRY_NAME --sku Basic

# Creates the storage account for the Terraform state file
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Creates the storage container for the Terraform state file
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME