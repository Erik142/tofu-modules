data "xenorchestra_pool" "pool" {
  name_label = var.xenorchestra_pool_name
}

data "xenorchestra_template" "template" {
  name_label = local.xenorchestra_template_name_label
}

data "xenorchestra_network" "net" {
  name_label = var.xenorchestra_network_name
}

data "xenorchestra_sr" "storage" {
  name_label = var.xenorchestra_sr_name
}

data "xenorchestra_sr" "linux_iso" {
  name_label = var.xenorchestra_iso_sr_name
}

/*
 * Locals
 */
locals {
  talos_iso_local_file_path        = "${path.module}/iso/talos-${var.talos_iso_version}-${var.talos_iso_arch}.iso"
  talos_server_url                 = "https://factory.talos.dev/image"
  xenorchestra_template_name_label = "AlmaLinux 9"
}

/*
 * Resources
 */
resource "null_resource" "talos_iso_file" {
  triggers = {
    on_version_change   = "${var.talos_iso_version}"
    on_arch_change      = "${var.talos_iso_arch}"
    on_schematic_change = "${var.talos_iso_schematic_id}"
    on_url_change       = "${local.talos_server_url}"
  }

  provisioner "local-exec" {
    command = "mkdir -p $(dirname ${local.talos_iso_local_file_path}); curl -L -o ${local.talos_iso_local_file_path} ${local.talos_server_url}/${var.talos_iso_schematic_id}/v${var.talos_iso_version}/metal-${var.talos_iso_arch}.iso"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${path.module}/iso"
  }
}

resource "xenorchestra_vdi" "talos_iso" {
  depends_on = [null_resource.talos_iso_file]
  name_label = format("talos-iso-%s", var.talos_iso_version)
  sr_id      = data.xenorchestra_sr.linux_iso.id
  filepath   = local.talos_iso_local_file_path
  type       = "raw"
}

resource "xenorchestra_vm" "talos_control_plane" {
  for_each         = toset([for x in range(1, var.talos_control_plane_node_count + 1) : tostring(x)])
  memory_max       = 8589934592
  cpus             = 4
  name_label       = format("Talos Control Plane %02d", each.key)
  name_description = "This VM has been created with Terraform"
  template         = data.xenorchestra_template.template.id
  auto_poweron     = true

  # Prefer to run the VM on the primary pool instance
  affinity_host = data.xenorchestra_pool.pool.master
  network {
    network_id       = data.xenorchestra_network.net.id
    expected_ip_cidr = var.xenorchestra_network_cidr
  }

  disk {
    sr_id      = data.xenorchestra_sr.storage.id
    name_label = format("talos-control-plane-system-%02d", each.key)
    size       = 53687091200
  }

  disk {
    sr_id      = data.xenorchestra_sr.storage.id
    name_label = format("talos-control-plane-data-%02d", each.key)
    size       = 214748364800
  }

  cdrom {
    id = xenorchestra_vdi.talos_iso.id
  }

  tags = [
    "Dev",
  ]

  timeouts {
    create = "5m"
  }
}

resource "xenorchestra_vm" "talos_worker" {
  for_each         = toset([for x in range(1, var.talos_worker_node_count + 1) : tostring(x)])
  memory_max       = 8589934592
  cpus             = 4
  name_label       = format("Talos Worker %02d", each.key)
  name_description = "This VM has been created with Terraform"
  template         = data.xenorchestra_template.template.id
  auto_poweron     = true

  # Prefer to run the VM on the primary pool instance
  affinity_host = data.xenorchestra_pool.pool.master

  network {
    network_id       = data.xenorchestra_network.net.id
    expected_ip_cidr = var.xenorchestra_network_cidr
  }

  disk {
    sr_id      = data.xenorchestra_sr.storage.id
    name_label = format("talos-worker-system-%02d", each.key)
    size       = 53687091200
  }

  disk {
    sr_id      = data.xenorchestra_sr.storage.id
    name_label = format("talos-worker-data-%02d", each.key)
    size       = 214748364800
  }

  cdrom {
    id = xenorchestra_vdi.talos_iso.id
  }

  tags = [
    "Dev",
  ]

  timeouts {
    create = "5m"
  }
}
