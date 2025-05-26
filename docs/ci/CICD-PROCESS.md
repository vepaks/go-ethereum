# CI/CD Process Visual Guide

## Overview

This document provides visual representations of the CI/CD processes for the Go Ethereum project, including workflow diagrams, decision trees, and process flows.

## Docker Build Workflow

```mermaid
flowchart TD
    A[PR with CI:Build label] --> B{Merged to master or develop?}
    B -->|No| Z[No Action]
    B -->|Yes| C[Set environment variables]
    C --> D[Build geth image]
    C --> E[Build alltools image]
    D --> F[Push geth image to GHCR]
    E --> G[Push alltools image to GHCR]
    F --> H{Branch = master?}
    G --> H
    H -->|Yes| I[Tag as production]
    H -->|No| J[Tag as staging]
```

## DevNet Deployment Workflow

```mermaid
flowchart TD
    A[PR with CI:Deploy label] --> B{Merged to master or develop?}
    B -->|No| Z[No Action]
    B -->|Yes| C[Set environment variables]
    C --> D[Build devnet image]
    D --> E[Push devnet image to GHCR]
    E --> F[Start devnet container]
    F --> G[Wait for container health]
    G --> H[Deploy contracts]
    H --> I[Run tests]
    I --> J{Tests pass?}
    J -->|Yes| K[Mark as successful]
    J -->|No| L[Report failure]
```

## Image Inheritance Diagram

```mermaid
classDiagram
    class AlpineBase {
        +alpine:latest
    }
    class GethImage {
        +geth binary
    }
    class AllToolsImage {
        +all ethereum tools
    }
    class DevNetImage {
        +deployed contracts
        +test environment
    }
    AlpineBase <|-- GethImage
    AlpineBase <|-- AllToolsImage
    AllToolsImage <|-- DevNetImage
```

## Decision Process for CI/CD Triggers

```mermaid
flowchart TD
    A[New PR] --> B{Has CI:Build label?}
    B -->|Yes| C[Add to build queue]
    B -->|No| D{Has CI:Deploy label?}
    D -->|Yes| E[Add to deploy queue]
    D -->|No| F[Skip CI/CD]
    C --> G[PR merged?]
    E --> G
    G -->|Yes| H[Trigger workflow]
    G -->|No| I[No action]
```

## Environment Promotion Flow

```mermaid
flowchart LR
    A[Development] --> B[Staging]
    B --> C[Production]
    A -->|Hotfix| C
    
    subgraph Images
    A1[develop-latest] --> B1[stage-latest]
    B1 --> C1[master-latest]
    end
```

## Local Testing Process

```mermaid
flowchart TD
    A[Developer changes] --> B[Run local-test.sh]
    B --> C{Tests pass?}
    C -->|Yes| D[Push to GitHub]
    C -->|No| E[Fix issues]
    E --> B
    D --> F[Create PR with labels]
    F --> G[CI/CD pipeline runs]
    G --> H{Pipeline succeeds?}
    H -->|Yes| I[Merge PR]
    H -->|No| J[Address failures]
    J --> A
```

## Container Health Check Sequence

```mermaid
sequenceDiagram
    participant D as Docker
    participant C as Container
    participant H as Health Check
    participant E as Ethereum Node
    
    D->>C: Start container
    C->>E: Start Ethereum node
    loop Every 5s
        H->>E: eth_blockNumber request
        E-->>H: Response
        H->>D: Report status
    end
    D->>D: Mark as healthy/unhealthy
```

## Complete CI/CD Pipeline

```mermaid
flowchart TD
    A[Code Change] --> B[Local Testing]
    B --> C[Create PR]
    C --> D[Automated Tests]
    D --> E{PR Approved?}
    E -->|Yes| F[Merge to Branch]
    E -->|No| G[Address Feedback]
    G --> B
    F --> H{Which Branch?}
    H -->|develop| I[Build staging images]
    H -->|master| J[Build production images]
    I --> K[Deploy to staging]
    J --> L[Deploy to production]
    K --> M[Staging verification]
    M -->|Success| N[Promote to production]
    N --> L
```

## Docker Image Publication Process

```mermaid
flowchart LR
    A[Build Image] --> B[Run Tests]
    B --> C{Tests Pass?}
    C -->|Yes| D[Tag Image]
    C -->|No| E[Fix Issues]
    E --> A
    D --> F[Push to Registry]
    F --> G[Update References]
    G --> H[Clean Old Images]
```

## Reference Documentation

For more detailed information, refer to:
- [README.CI.md](../README.CI.md) - Complete CI/CD documentation
- [IMAGE-MANAGEMENT.md](IMAGE-MANAGEMENT.md) - Docker image management
- [GitHub Actions workflows](../.github/workflows/) - Workflow implementation