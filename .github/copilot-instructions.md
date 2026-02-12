# Copilot Instructions

## Project Overview

This repository is a catalogue of reusable Azure Bicep modules published to Azure Container Registry (ACR) `acrty7og2i6qpv3s` under `bicep/modules/{module}`. The registry is provisioned by the `platform-strategic-services` project.

## Repository Layout

- `modules/<name>/` — Each module contains `main.bicep` and `metadata.json` (with `version.major|minor|revision`). Publishing fails if either file is missing.
- `.azure-pipelines/` — Azure DevOps pipeline definitions and the publish script.
- `.github/workflows/` — GitHub Actions workflows for CI, code quality, and PR verification.
- `scripts/` — Utility scripts for app registration and role assignment.
- `docs/` — Project documentation ([overview.md](../docs/overview.md), [development-workflows.md](../docs/development-workflows.md)).

## Module Catalogue

`apiManagementLogger`, `apiManagementSubscription`, `appConfigurationStore`, `appInsights`, `frontDoorCNAME`, `frontDoorEndpoint`, `keyVault`, `keyVaultAccessPolicy`, `keyVaultRoleAssignment`, `keyVaultSecret`, `sqlDatabase`, `storageAccount`, `webTest`.

## Build and Validation

- **Local validation**: `az bicep build --file modules/<name>/main.bicep`
- **GitHub Actions**: `build-and-test.yml` validates all modules on feature/bugfix/hotfix branches; `pr-verify.yml` validates on PRs to main; `codequality.yml` runs SonarCloud scanning, DevOps secure scanning, and dependency review.
- **Azure DevOps**: `release-to-production.yml` lints and publishes modules to ACR via `spn-bicep-modules-production`.

## Versioning and Publishing

- Non-main builds publish `V{major}.{minor}.{revision}-preview` only.
- Main builds also push `V{major}.x`, `V{major}.{minor}.x`, and `latest` when the full version tag is new.
- The publish script (`Publish-BicepModuleToAcr.ps1`) skips publishing when a tag already exists.
- Manual publish example:
  ```powershell
  pwsh ./.azure-pipelines/scripts/Publish-BicepModuleToAcr.ps1 `
    -moduleName keyvault `
    -modulesRootPath ./modules `
    -acrName acrty7og2i6qpv3s `
    -previewRelease $true
  ```
  Requires `az login` and rights to the registry.

## Conventions

- Always update `metadata.json` when changing a module's `main.bicep`.
- Bicep files should pass `az bicep build` without errors before committing.
- Pipelines consume templates from the `ado-pipeline-templates` GitHub repo and require Azure CLI with Bicep installed.

## Dependencies

- Azure CLI with Bicep extension
- `ado-pipeline-templates` repository (for Azure DevOps pipeline templates)
- `frasermolyneux/actions` repository (for reusable GitHub Actions workflows)
