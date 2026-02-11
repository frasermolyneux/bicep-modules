# Copilot Instructions

- **Purpose**: Catalog of reusable Azure Bicep modules published to ACR `acrty7og2i6qpv3s` under `bicep/modules/{module}`; registry is provisioned by the platform-strategic-services project.
- **Layout**: Each module lives in `modules/<name>/` with `main.bicep` plus `metadata.json` carrying `version.major|minor|revision`. Publishing fails if either file is missing.
- **Versioning behavior**: Non-main builds publish `V{major}.{minor}.{revision}-preview` only. Main builds also push `V{major}.x`, `V{major}.{minor}.x`, and `latest` when the full version tag is new.
- **Publish script**: [Publish-BicepModuleToAcr.ps1](../.azure-pipelines/scripts/Publish-BicepModuleToAcr.ps1) drives tagging; it skips publishing when the `V{major}.{minor}.{revision}` tag already exists. Repository prefix defaults to `bicep/modules`.
- **Pipelines**: [devops-secure-scanning](../.azure-pipelines/devops-secure-scanning.yml) runs weekly and on PRs to main using `jobs/devops-secure-scanning.yml` from the `ado-pipeline-templates` repo. [release-to-production](../.azure-pipelines/release-to-production.yml) builds with `bicep-lint-code` then loops modules to publish via service connection `spn-bicep-modules-production`; scheduled weekly and on main.
- **Local workflow**: Update `metadata.json` when changing `main.bicep`; validate with `az bicep build --file modules/<name>/main.bicep`. Manual publish example:
  ```powershell
  pwsh ./.azure-pipelines/scripts/Publish-BicepModuleToAcr.ps1 `
    -moduleName keyvault `
    -modulesRootPath ./modules `
    -acrName acrty7og2i6qpv3s `
    -previewRelease $true
  ```
  Requires `az login` and rights to the registry.
- **Module catalogue**: modules include `apiManagementLogger`, `apiManagementSubscription`, `appConfigurationStore`, `appInsights`, `frontDoorCNAME`, `frontDoorEndpoint`, `keyVault`, `keyVaultAccessPolicy`, `keyVaultRoleAssignment`, `keyVaultSecret`, `sqlDatabase`, `storageAccount`, `webTest`.
- **Dependencies**: Pipelines consume templates from the `ado-pipeline-templates` GitHub repo and require Azure CLI with Bicep installed.
- **Docs**: See [docs/overview.md](../docs/overview.md) and [docs/development-workflows.md](../docs/development-workflows.md) for module layout and pipeline details.
