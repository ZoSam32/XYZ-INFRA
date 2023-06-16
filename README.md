# XYZ Infrastructure
Hosting infrastructure for XYZ POC

## Overview

This repository contains the primary components for the XYZ public cloud POC. It will serve as the inital hosting footprint and application deployment. 

## Prerequisites 
- Azure Subscription: Sign up [here](https://azure.microsoft.com/en-us/free/search/?ef_id=_k_CjwKCAjwyqWkBhBMEiwAp2yUFkfcZdiUYoQZTwCBPdQnxxcolk5jolBbTYyJf2qoCrvp9DnhZFoHZRoCe-AQAvD_BwE_k_&OCID=AIDcmmfq865whp_SEM__k_CjwKCAjwyqWkBhBMEiwAp2yUFkfcZdiUYoQZTwCBPdQnxxcolk5jolBbTYyJf2qoCrvp9DnhZFoHZRoCe-AQAvD_BwE_k_&gad=1&gclid=CjwKCAjwyqWkBhBMEiwAp2yUFkfcZdiUYoQZTwCBPdQnxxcolk5jolBbTYyJf2qoCrvp9DnhZFoHZRoCe-AQAvD_BwE)
- Azure CLI: Install [here](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- Terraform: Install [here](https://developer.hashicorp.com/terraform/downloads)
- Docker: Install [here](https://docs.docker.com/engine/install/)

Configure the backend services via the `setup/backend_resources.sh` script. 

## Components
- Azure Blob Storage - Backend service for Terraform state file
- Azure Container Registry - Backend service for a private contianer registry
- Azure Kubernetes Serivce - A managed Kubernetes service for container orchestration
- Azure Log Analytics Service - A managed observability service for Azure resource monitoring

## Deploy POC
To deploy the solution, trigger the primary GitHub Action `Solution Deploy` via push to main

[![Terraform Plan & Apply](https://github.com/ZoSam32/XYZ-INFRA/actions/workflows/main.yaml/badge.svg?branch=main)](https://github.com/ZoSam32/XYZ-INFRA/actions/workflows/main.yaml)
