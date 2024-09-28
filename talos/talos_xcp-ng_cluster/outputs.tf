output "talos_control_planes" {
  value = flatten(values(xenorchestra_vm.talos_control_plane)[*].network[*])
}

output "talos_workers" {
  value = flatten(values(xenorchestra_vm.talos_worker)[*].network[*])
}
