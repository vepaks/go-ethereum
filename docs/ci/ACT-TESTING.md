# Testing GitHub Actions Workflows Locally with Act

## Overview

This guide explains how to use [Act](https://github.com/nektos/act) to test GitHub Actions workflows locally before committing changes. Act is a tool that allows you to run your GitHub Actions locally using Docker.

## Prerequisites

- Docker installed and running
- Act installed (https://github.com/nektos/act#installation)
- Basic understanding of GitHub Actions workflows

## Getting Started

We've provided a helper script `act-test.sh` in the root directory that simplifies testing workflows with Act.

### Basic Usage

1. View available workflows:

```bash
./act-test.sh
```

2. Test the Docker build workflow:

```bash
./act-test.sh --workflow .github/workflows/docker-build.yml
```

3. Test the DevNet deployment workflow:

```bash
./act-test.sh --workflow .github/workflows/deploy-devnet.yml
```

### Advanced Options

The `act-test.sh` script supports several options:

- `--workflow FILE`: Specify the workflow file to test
- `--event EVENT`: Specify the GitHub event to simulate (default: pull_request)
- `--job JOB`: Run a specific job from the workflow
- `--verbose`: Show verbose output
- `--dry-run`: Show the commands that would be executed without running them

Examples:

```bash
# Test a specific job
./act-test.sh --workflow .github/workflows/deploy-devnet.yml --job test-devnet

# Test with push event instead of pull request
./act-test.sh --workflow .github/workflows/docker-build.yml --event push

# Just show what would be executed
./act-test.sh --workflow .github/workflows/docker-build.yml --dry-run
```

## Environment Variables and Secrets

Act uses `.env.act` file in the repository root to provide environment variables and secrets for the workflows. This file is already configured with test values, but you may need to modify it with real secrets for certain workflows to function properly.

## Test Events

The script creates simulated GitHub events in `.github/act/`:

- `pull_request.json`: Simulates a PR being merged to develop with CI:Build and CI:Deploy labels
- `push.json`: Simulates a push to the develop branch

You can edit these files to simulate different events.

## Workflow-Specific Notes

### Testing the Docker Build Workflow

When testing the Docker build workflow, Act will attempt to build Docker images and push them to a registry. To avoid pushing to the actual registry, use the `--dry-run` option:

```bash
./act-test.sh --workflow .github/workflows/docker-build.yml --dry-run
```

### Testing the DevNet Deployment Workflow

The DevNet workflow requires Docker-in-Docker capabilities. Make sure you have the proper permissions:

```bash
./act-test.sh --workflow .github/workflows/deploy-devnet.yml
```

## Troubleshooting

### Docker Socket Permissions

If you see errors related to Docker socket permissions, try running Act with sudo:

```bash
sudo ./act-test.sh --workflow .github/workflows/docker-build.yml
```

### Missing Dependencies

Act's default Docker images may not include all dependencies required by the workflows. In this case, you may see errors related to missing commands. You can use a more comprehensive image:

```bash
act -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest
```

This is already configured in the `.actrc` file.

### Skipped Steps

Some GitHub-specific steps (like setting up secrets) might be skipped by Act. This is normal and won't affect most tests.

## Interpreting Results

After running a workflow test, Act will provide a summary of which steps passed and which failed. Successful test runs will display:

```
✅ Workflow test completed successfully!
```

If you encounter failures, check the output for error messages that will help identify the issue.

## Additional Resources

- [Act GitHub Repository](https://github.com/nektos/act)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)