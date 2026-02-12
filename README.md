# Bicep Modules

[![Build and Test](https://github.com/frasermolyneux/bicep-modules/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/frasermolyneux/bicep-modules/actions/workflows/build-and-test.yml)
[![Code Quality](https://github.com/frasermolyneux/bicep-modules/actions/workflows/codequality.yml/badge.svg)](https://github.com/frasermolyneux/bicep-modules/actions/workflows/codequality.yml)
[![Copilot Setup Steps](https://github.com/frasermolyneux/bicep-modules/actions/workflows/copilot-setup-steps.yml/badge.svg)](https://github.com/frasermolyneux/bicep-modules/actions/workflows/copilot-setup-steps.yml)
[![Dependabot Auto-Merge](https://github.com/frasermolyneux/bicep-modules/actions/workflows/dependabot-automerge.yml/badge.svg)](https://github.com/frasermolyneux/bicep-modules/actions/workflows/dependabot-automerge.yml)
[![PR Verify](https://github.com/frasermolyneux/bicep-modules/actions/workflows/pr-verify.yml/badge.svg)](https://github.com/frasermolyneux/bicep-modules/actions/workflows/pr-verify.yml)

## Documentation

- [Overview](docs/overview.md) - Module layout, catalogue, and registry dependencies
- [Development Workflows](docs/development-workflows.md) - Pipelines, local validation, and publish guidance

## Overview

Reusable Azure Bicep modules for Integration Services workloads, published to `acrty7og2i6qpv3s` under `bicep/modules/{module}`. Modules ship with per-folder metadata for versioning and are linted/published through Azure DevOps using templates from `ado-pipeline-templates`. The registry itself is deployed by the `platform-strategic-services` project.

## Contributing

Please read the [contributing](CONTRIBUTING.md) guidance; this is a learning and development project.

## Security

Please read the [security](SECURITY.md) guidance; I am always open to security feedback through email or opening an issue.
