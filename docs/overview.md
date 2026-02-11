# Overview

This repository collects reusable Bicep modules for Azure resources and publishes them to the `acrty7og2i6qpv3s` container registry under the `bicep/modules/{module}` repositories. Modules were extracted from practical projects and focus on Integration Services workloads such as API Management, App Service, Functions, Key Vault, Storage, and Front Door.

## Module layout
- Each module lives in `modules/<name>/` with `main.bicep` and a `metadata.json` containing `version.major`, `version.minor`, and `version.revision`.
- When the release pipeline runs on non-main branches, tags get a `-preview` suffix and no `.x` or `latest` tags are pushed.
- On main, the `Publish-BicepModuleToAcr.ps1` script also pushes `V{major}.x`, `V{major}.{minor}.x`, and `latest` tags when a new full version is published.

## Module catalogue
- `apiManagementLogger` / `apiManagementSubscription` for APIM logging and subscription setup
- `appConfigurationStore` for App Configuration instances
- `appInsights` for Application Insights instances
- `frontDoorCNAME` and `frontDoorEndpoint` for Front Door DNS and endpoint plumbing
- `keyVault`, `keyVaultAccessPolicy`, `keyVaultRoleAssignment`, `keyVaultSecret` for Key Vault primitives
- `sqlDatabase` for SQL Database
- `storageAccount` for Storage Accounts
- `webTest` for Application Insights availability tests

## Dependencies
- The container registry used for publish lives in the `platform-strategic-services` project.
- Azure CLI with Bicep CLI installed is required locally; pipelines run via Azure DevOps using the `ado-pipeline-templates` repository.
