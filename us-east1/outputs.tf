output "cluster_ca_certificate" {
  value       = module.gke_cluster.cluster_ca_certificate
  description = "Base64 encoded public certificate that is the root of trust for the cluster"
}


output "client_certificate" {
  value       = module.gke_cluster.client_certificate
  description = "Base64 encoded public certificate that is the root of trust for the cluster"
}

output "client_key" {
  value       = module.gke_cluster.client_key
  description = "Base64 encoded public certificate that is the root of trust for the cluster"
  sensitive = true
}

output "gke_endpoint" {
  value       = module.gke_cluster.gke_endpoint
  description = "Kubernetes cluster API endpoint"
}
