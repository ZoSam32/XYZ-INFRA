#!/bin/bash

RESOURCE_GROUP_AKS=rg-poc-eus-xyz_app
RESOURCE_GROUP_METRICS=rg-poc-eus-xyz_app-metrics

az group delete -g $RESOURCE_GROUP_AKS -y --no-wait 

az group delete -g $RESOURCE_GROUP_METRICS -y --no-wait 