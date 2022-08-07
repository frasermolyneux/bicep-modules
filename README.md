# Bicep Modules

[![Build Status](https://dev.azure.com/frasermolyneux/Personal-Public/_apis/build/status/bicep-modules.OnePipeline?repoName=frasermolyneux%2Fbicep-modules&branchName=main)](https://dev.azure.com/frasermolyneux/Personal-Public/_build/latest?definitionId=175&repoName=frasermolyneux%2Fbicep-modules&branchName=main)

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

---

## Pipelines

The `one-pipeline` is within the `.azure-pipelines` folder and output is visible on the [frasermolyneux/Personal-Public](https://dev.azure.com/frasermolyneux/Personal-Public/_build?definitionId=175) Azure DevOps project.

---

## Contributing

Please read the [contributing](CONTRIBUTING.md) guidance; this is a learning and development project.

---

## Security

Please read the [security](SECURITY.md) guidance; I am always open to security feedback through email or opening an issue.
