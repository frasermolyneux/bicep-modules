# Development Workflows

## Pipelines
- `devops-secure-scanning` runs weekly (Thu 02:00 UTC) and on PRs to main using the `ado-pipeline-templates` security scanning job.
- `release-to-production` runs on main and weekly (Thu 03:00 UTC). Stage `Build` runs `bicep-lint-code` against `modules/`. Stage `Deploy` loops through each module folder and calls `Publish-BicepModuleToAcr.ps1` against ACR `acrty7og2i6qpv3s` using service connection `spn-bicep-modules-production`.

## Local changes
- Edit `modules/<name>/main.bicep` and bump `modules/<name>/metadata.json` version before publishing.
- Validate locally with `az bicep build --file modules/<name>/main.bicep` (or `bicep build`).
- Optional manual publish (requires `az login` and rights to the registry):
  ```powershell
  pwsh ./.azure-pipelines/scripts/Publish-BicepModuleToAcr.ps1 `
    -moduleName keyvault `
    -modulesRootPath ./modules `
    -acrName acrty7og2i6qpv3s `
    -previewRelease $true
  ```
  Set `-previewRelease $false` to mirror main-branch behavior, which also pushes `V{major}.x`, `V{major}.{minor}.x`, and `latest` tags when creating a new version.
- The publish script only pushes a new version when the tag does not already exist; reruns skip existing tags with a warning.
