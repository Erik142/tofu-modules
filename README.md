# OpenTofu IaC Modules

This repository contains all OpenTofu IaC modules that I use in my personal homelab, as well as in CI for those OpenTofu modules.

Each directory in the root of this repository is a rough categorization of the OpenTofu modules, and each subdirectory contains the corresponding OpenTofu module itself.

Currently, my homelab consists of a single physical host running XCP-ng as the bare metal operating system, as well as a [MikroTik RB4011iGS+RM](https://mikrotik.com/product/rb4011igs_rm) router. The intention is to use OpenTofu to deploy all infrastructure on the physical XCP-ng host, i.e. the Virtual Machines, the network configuration, the storage repositories etc. as well as to configure the MikroTik router itself. In case of an emergency, I want my homelab to be recoverable using OpenTofu, without having to manually re-deploy or re-configure any Virtual Machines or services. This is not yet the case, however, since a homelab re-build is around the corner, my homelab will be fully automated after re-building the homelab with new hardware.
