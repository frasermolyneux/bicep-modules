# Bicep Modules

| Stage                  | Status                                                                                                                                                                                                                                                                                                                                       |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DevOps Secure Scanning | [![Build Status](https://dev.azure.com/frasermolyneux/Personal-Public/_apis/build/status%2Fbicep-modules.DevOpsSecureScanning?branchName=main)](https://dev.azure.com/frasermolyneux/Personal-Public/_build/latest?definitionId=209&branchName=main)                                                                                         |
| Build                  | [![Build Status](https://dev.azure.com/frasermolyneux/Personal-Public/_apis/build/status%2Fbicep-modules.OnePipeline?repoName=frasermolyneux%2Fbicep-modules&branchName=main&stageName=Build)](https://dev.azure.com/frasermolyneux/Personal-Public/_build/latest?definitionId=175&repoName=frasermolyneux%2Fbicep-modules&branchName=main)  |
| Release to Production  | [![Build Status](https://dev.azure.com/frasermolyneux/Personal-Public/_apis/build/status%2Fbicep-modules.OnePipeline?repoName=frasermolyneux%2Fbicep-modules&branchName=main&stageName=Deploy)](https://dev.azure.com/frasermolyneux/Personal-Public/_build/latest?definitionId=175&repoName=frasermolyneux%2Fbicep-modules&branchName=main) |

---

## Overview

This repository contains common Bicep modules and associated Azure DevOps pipelines for the validation and deployment of them to an Azure Container Registry.

The Azure Container Registry is deployed by the `platform-strategic-services` project and therefore a dependency.

---

## Related Projects

* [frasermolyneux/platform-strategic-services](https://github.com/frasermolyneux/platform-strategic-services) - The Azure Container Registry is deployed by this project.
* [frasermolyneux/azure-landing-zones](https://github.com/frasermolyneux/azure-landing-zones) - The deploy service principal is managed by this project.

---

## Solution

The included Bicep modules have been extracted out of a series of projects that I have worked on through my learning and development. They are largely focused on Azure Integration Services such as API Management, Azure Functions, App Services and Key Vault.

### Versioning

Each module within the solution has a metadata `.json` file that is within the `metadata` folder. Currently this contains a JSON payload that simply has a version object containing `major`, `minor` and `revision` properties - there is the future potential to add additional metadata here such as tagging, author and description. For each module file there *must* be a metadata file and for a new version to be pushed the metadata file must be updated.

If the build is running from any branch other than `main` then a *-preview* suffix is added to the tag and the `.x` and `latest` tags will not be pushed.

As such, for a new version to be pushed the metadata file is required to be updated. There is no automation at present as it is not warranted.

---

## Pipelines

The `one-pipeline` is within the `.azure-pipelines` folder and output is visible on the [frasermolyneux/Personal-Public](https://dev.azure.com/frasermolyneux/Personal-Public/_build?definitionId=175) Azure DevOps project.

The [Publish-BicepModuleToAcr.ps1](/.azure-pipelines/scripts/Publish-BicepModuleToAcr.ps1) script is executed per module and uses the following rules to publish:

* Will only push a new version if the `major.minor.revision` tag does not already exist
* When pushing a new version will also push that version using the a `.x` and `latest` tag

---

## Contributing

Please read the [contributing](CONTRIBUTING.md) guidance; this is a learning and development project.

---

## Security

Please read the [security](SECURITY.md) guidance; I am always open to security feedback through email or opening an issue.
