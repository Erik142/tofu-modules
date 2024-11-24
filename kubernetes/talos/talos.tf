resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "control_plane" {
  cluster_name     = var.talos_cluster_name
  cluster_endpoint = var.talos_cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = var.talos_version
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.talos_cluster_name
  cluster_endpoint = var.talos_cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = var.talos_version
}

data "talos_client_configuration" "this" {
  cluster_name         = var.talos_cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for x in var.talos_control_plane_nodes : x.hostname]
  nodes = flatten([
    [for x in var.talos_control_plane_nodes : x.hostname],
    [for x in var.talos_worker_nodes : x.hostname]
  ])
}

resource "talos_machine_configuration_apply" "control_plane" {
  count                       = length(var.talos_control_plane_nodes)
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_plane.machine_configuration
  node                        = format("control-plane-%02d", count.index + 1)
  endpoint                    = var.talos_control_plane_nodes[count.index].hostname
  config_patches = [
    templatefile("${path.module}/templates/install-disk-and-hostname.yaml.tmpl", {
      hostname     = format("control-plane-%02d", count.index + 1)
      install_disk = var.talos_control_plane_nodes[count.index].install_disk
    }),
    templatefile("${path.module}/templates/node-role-label.yaml.tmpl", {
      role = "control-plane"
    }),
    file("${path.module}/files/no-default-cni.yaml"),
    file("${path.module}/files/dns-servers.yaml"),
    yamlencode({
      cluster = {
        inlineManifests = [
          {
            name = "cilium"
            contents = join("---\n", [
              data.helm_template.cilium.manifest,
              "# Source cilium.tf\n${local.cilium_external_lb_manifest}",
            ])
          },
        ],
      },
    })
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  count                       = length(var.talos_worker_nodes)
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = format("worker-%02d", count.index + 1)
  endpoint                    = var.talos_worker_nodes[count.index].hostname
  config_patches = [
    templatefile("${path.module}/templates/install-disk-and-hostname.yaml.tmpl", {
      hostname     = format("worker-%02d", count.index + 1)
      install_disk = var.talos_worker_nodes[count.index].install_disk
    }),
    templatefile("${path.module}/templates/node-role-label.yaml.tmpl", {
      role = "worker"
    }),
    file("${path.module}/files/dns-servers.yaml"),
    file("${path.module}/files/mayastor-machine-config.yaml"),
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.control_plane, talos_machine_configuration_apply.worker]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.talos_control_plane_nodes[0].hostname
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.talos_control_plane_nodes[0].hostname
}
