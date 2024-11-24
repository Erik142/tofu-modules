variable "talos_control_plane_nodes" {
  type = list(object({
    hostname     = string
    install_disk = string
  }))
}

variable "talos_worker_nodes" {
  type = list(object({
    hostname     = string
    install_disk = string
    data_disk    = string
  }))
}

variable "talos_cluster_endpoint" {
  type = string
}

variable "talos_cluster_name" {
  type = string
}

variable "talos_version" {
  type = string
}

variable "cluster_bgp_local_asn" {
  type        = number
  description = "The BGP ASN for the Kubernetes cluster"
}

variable "cluster_bgp_peer_asn" {
  type        = number
  description = "The BGP ASN for the remote peer"
}

variable "cluster_bgp_peer_address" {
  type        = string
  description = "The BGP peer IP address"
}

variable "cluster_bgp_auth_secret_ref" {
  type        = string
  description = "The name of the Kubernetes secret that holds the BGP authentication data"
}

variable "cilium_load_balancer_cidr" {
  type        = string
  description = "The CIDR to be used for Kubernetes LoadBalancer services"
}

