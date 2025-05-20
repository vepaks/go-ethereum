variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "go-ethereum-cluster"
}

variable "node_group_name" {
  description = "Name of the node group"
  type        = string
  default     = "main"
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "instance_types" {
  description = "Type of EC2 instances"
  type        = list(string)
  default     = ["t3.micro"]
} 