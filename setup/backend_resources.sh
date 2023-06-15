#!/bin/bash

RESOURCE_GROUP_NAME=acr-sample-test
REGISTRY_NAME=xyzappsamplezzz
STORAGE_ACCOUNT_NAME=tfstate$RANDOM
CONTAINER_NAME=tfstate

az group create --name $RESOURCE_GROUP_NAME --location eastus

az acr create --resource-group $RESOURCE_GROUP_NAME --name $REGISTRY_NAME --sku Basic

az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME