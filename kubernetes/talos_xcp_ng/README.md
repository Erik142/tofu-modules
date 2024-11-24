# Talos XCP-ng

This OpenTofu module creates Virtual Machine instances on XCP-ng, that will use PXE booting to boot a customized Talos ISO created using the [Talos Image Factory](https://factory.talos.dev/).

The following variables can be used to configure the module behavior:

| name | description | required |
| ---- | ----------- | -------- |
| xenorchestra_hostname | The hostname (or IP address) of the XCP-ng host | true |
| xenorchestra_username | The username used to authenticate with the XCP-ng host | true |
| xenorchestra_password | The password used to authenticate with the XCP-ng host | true |
| xenorchestra_insecure | Do not verify the XCP-ng host's TLS certificate (default `true`) | false |
| xenorchestra_pool_name | The name of the XCP-ng pool where the Virtual Machines should be created | true |
| xenorchestra_network_name | The network name to be used by the Virtual Machines | true |
| xenorchestra_network_name | The network CIDR to be used by the Virtual Machines. This is used for waiting on the Virtual Machines to be created and booted with network connectivity | true |
| xenorchestra_sr_name | The storage repository name used to store the Virtual Machines' VDIs | true |
| xenorchestra_iso_sr_name | The storage repository name used to store the Talos Linux ISO file | true |
| talos_control_plane_node_count | The number of Talos control plane Virtual Machines to deploy | true |
| talos_worker_node_count | The number of Talos worker Virtual Machines to deploy | true |
| talos_iso_arch | The hardware architecture to be used when downloading the Talos Linux ISO file (defaults to `amd64`) | false |
| talos_iso_version | The version of the Talos Linux ISO file to download | true |
| talos_iso_schematic_id | The "schematic ID" of the custom Talos Linux ISO file to be downloaded | true |
