# Terraform Infrastructure Documentation

This directory contains Terraform configurations for deploying a Go Ethereum node on Amazon EKS (Elastic Kubernetes Service). The infrastructure is designed to be scalable, secure, and production-ready.

## Directory Structure

```
terraform/
└── k8s/
    ├── main.tf           # Main infrastructure configuration
    ├── variables.tf      # Input variables definition
    ├── outputs.tf        # Output values
    ├── provider.tf       # Provider configurations
    └── .terraform/       # Terraform working directory (gitignored)
```

## Infrastructure Components

### 1. Network Infrastructure
- **VPC**: A dedicated VPC with CIDR block 10.0.0.0/16
- **Subnets**: Two subnets across different availability zones for high availability
- **DNS Support**: Enabled for both hostnames and DNS support

### 2. IAM Roles and Policies
- **EKS Cluster Role**: IAM role for the EKS cluster with necessary permissions
- **EKS Node Role**: IAM role for worker nodes with required policies:
  - AmazonEKSWorkerNodePolicy
  - AmazonEKS_CNI_Policy
  - AmazonEC2ContainerRegistryReadOnly

### 3. EKS Cluster
- **Cluster Configuration**:
  - Kubernetes version: 1.28
  - Custom cluster name (configurable)
  - VPC integration with configured subnets

### 4. Node Group
- **Scaling Configuration**:
  - Desired size: 2 nodes (configurable)
  - Minimum size: 1 node
  - Maximum size: 3 nodes
- **Instance Types**: t3.micro (configurable)

### 5. Kubernetes Resources
- **Deployment**:
  - Go Ethereum node deployment
  - Single replica (configurable)
  - Uses official ethereum/client-go:stable image
- **Service**:
  - LoadBalancer type
  - Exposes port 8545 (Ethereum JSON-RPC port)

## Configuration Variables

The following variables can be customized in `variables.tf`:

| Variable | Description | Default Value |
|----------|-------------|---------------|
| aws_region | AWS region to deploy resources | us-east-1 |
| cluster_name | Name of the EKS cluster | go-ethereum-cluster |
| node_group_name | Name of the node group | main |
| node_desired_size | Desired number of nodes | 2 |
| node_max_size | Maximum number of nodes | 3 |
| node_min_size | Minimum number of nodes | 1 |
| instance_types | Type of EC2 instances | ["t3.micro"] |

## Outputs

The following outputs are available after applying the configuration:

| Output | Description |
|--------|-------------|
| cluster_endpoint | EKS control plane endpoint |
| cluster_security_group_id | Security group ID attached to the EKS cluster |
| cluster_name | Name of the Kubernetes cluster |
| load_balancer_hostname | Hostname of the LoadBalancer service |

## Usage

1. Initialize Terraform:
   ```bash
   cd terraform/k8s
   terraform init
   ```

2. Review the planned changes:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. To destroy the infrastructure:
   ```bash
   terraform destroy
   ```

## Prerequisites

- AWS CLI configured with appropriate credentials
- kubectl installed
- Terraform v1.0.0 or later
- AWS provider version ~> 5.0
- Kubernetes provider version ~> 2.0

## Security Considerations

- The infrastructure uses IAM roles with least privilege principle
- Network security is managed through VPC and security groups
- EKS cluster is deployed in private subnets
- Worker nodes have minimal required permissions

## Maintenance

- Regularly update the Kubernetes version
- Monitor node group scaling
- Review and update security groups as needed
- Keep Terraform providers up to date

## Troubleshooting

1. If the cluster fails to create:
   - Check IAM permissions
   - Verify VPC and subnet configurations
   - Ensure all required policies are attached

2. If nodes fail to join:
   - Verify node IAM role permissions
   - Check security group configurations
   - Review node group configuration

3. If the Go Ethereum node is not accessible:
   - Verify LoadBalancer service status
   - Check pod status and logs
   - Ensure security groups allow traffic on port 8545 