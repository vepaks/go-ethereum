output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = aws_eks_cluster.main.name
}

output "load_balancer_hostname" {
  description = "Hostname of the LoadBalancer service"
  value       = kubernetes_service.go_ethereum.status.0.load_balancer.0.ingress.0.hostname
} 