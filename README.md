# Bicep Modules

[![DevOps Secure Scanning](https://dev.azure.com/frasermolyneux/Personal-Public/_apis/build/status%2fbicep-modules.DevOpsSecureScanning?branchName=main)](https://dev.azure.com/frasermolyneux/Personal-Public/_build/latest?definitionId=209&branchName=main)
[![Pipeline Build](https://dev.azure.com/frasermolyneux/Personal-Public/_apis/build/status%2fbicep-modules.OnePipeline?repoName=frasermolyneux%2fbicep-modules&branchName=main&stageName=Build)](https://dev.azure.com/frasermolyneux/Personal-Public/_build/latest?definitionId=175&repoName=frasermolyneux%2fbicep-modules&branchName=main)
[![Pipeline Deploy](https://dev.azure.com/frasermolyneux/Personal-Public/_apis/build/status%2fbicep-modules.OnePipeline?repoName=frasermolyneux%2fbicep-modules&branchName=main&stageName=Deploy)](https://dev.azure.com/frasermolyneux/Personal-Public/_build/latest?definitionId=175&repoName=frasermolyneux%2fbicep-modules&branchName=main)

## Documentation
- [Overview](docs/overview.md) - Module layout, catalogue, and registry dependencies
- [Development Workflows](docs/development-workflows.md) - Pipelines, local validation, and publish guidance

## Overview
Reusable Azure Bicep modules for Integration Services workloads, published to `acrty7og2i6qpv3s` under `bicep/modules/{module}`. Modules ship with per-folder metadata for versioning and are linted/published through Azure DevOps using templates from `ado-pipeline-templates`. The registry itself is deployed by the `platform-strategic-services` project.

## Contributing

Please read the [contributing](CONTRIBUTING.md) guidance; this is a learning and development project.

## Security

Please read the [security](SECURITY.md) guidance; I am always open to security feedback through email or opening an issue.
