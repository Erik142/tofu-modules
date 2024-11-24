variable "xenorchestra_hostname" {
  type = string
}

variable "xenorchestra_username" {
  type = string
}

variable "xenorchestra_password" {
  type      = string
  sensitive = true
}

variable "xenorchestra_insecure" {
  type    = bool
  default = true
}

variable "xenorchestra_pool_name" {
  type = string
}

variable "xenorchestra_network_name" {
  type = string
}

variable "xenorchestra_network_cidr" {
  type = string
}

variable "xenorchestra_sr_name" {
  type = string
}

variable "xenorchestra_iso_sr_name" {
  type = string
}

variable "talos_control_plane_node_count" {
  type = number
}

variable "talos_worker_node_count" {
  type = number
}

variable "talos_iso_arch" {
  type    = string
  default = "amd64"
}

variable "talos_iso_version" {
  type = string
}

variable "talos_iso_schematic_id" {
  type = string
}
