output "talos_config" {
  description = "The generated Talos client configuration"
  sensitive   = true
  value       = data.talos_client_configuration.this.talos_config
}

output "talos_worker_machine_config" {
  description = "The generated Talos worker machine configuration"
  sensitive   = true
  value       = talos_machine_configuration_apply.worker[*].machine_configuration
}

output "kubectl_config" {
  description = "The kubectl config for the Talos cluster"
  sensitive   = true
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
}

output "kubernetes_client_configuration" {
  description = "The Kubernetes client configuration"
  sensitive   = true
  value       = talos_cluster_kubeconfig.this.kubernetes_client_configuration
}
