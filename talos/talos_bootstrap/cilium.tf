locals {
  kubectl_config_path = "${path.module}/kubectl.talos.config"
  # see https://docs.cilium.io/en/stable/network/lb-ipam/
  # see https://docs.cilium.io/en/stable/network/l2-announcements/
  # see the CiliumL2AnnouncementPolicy type at https://github.com/cilium/cilium/blob/v1.15.4/pkg/k8s/apis/cilium.io/v2alpha1/l2announcement_types.go#L23-L42
  # see the CiliumLoadBalancerIPPool type at https://github.com/cilium/cilium/blob/v1.15.4/pkg/k8s/apis/cilium.io/v2alpha1/lbipam_types.go#L23-L47
  cilium_external_lb_manifests = [
    {
      apiVersion = "cilium.io/v2alpha1"
      kind       = "CiliumBGPClusterConfig"
      metadata = {
        name = "cluster-config-${var.cluster_bgp_local_asn}-${var.cluster_bgp_peer_asn}"
      }
      spec = {
        nodeSelector = {
          matchLabels = {
            role = "worker"
          }
        }
        bgpInstances = [
          {
            name     = "bgp-${var.cluster_bgp_local_asn}"
            localASN = var.cluster_bgp_local_asn
            peers = [
              {
                name        = "peer-${var.cluster_bgp_peer_asn}"
                peerAddress = var.cluster_bgp_peer_address
                peerASN     = var.cluster_bgp_peer_asn
                peerConfigRef = {
                  name = "peer-config-${var.cluster_bgp_peer_asn}"
                }
              }
            ]
          }
        ]
      }
    },
    {
      apiVersion = "cilium.io/v2alpha1"
      kind       = "CiliumBGPPeerConfig"
      metadata = {
        name = "peer-config-${var.cluster_bgp_peer_asn}"
      }
      spec = {
        authSecretRef = var.cluster_bgp_auth_secret_ref
        timers = {
          connectRetryTimeSeconds = 12
          holdTimeSeconds         = 9
          keepAliveTimeSeconds    = 3
        }
        gracefulRestart = {
          enabled            = true
          restartTimeSeconds = 30
        }
        ebgpMultihop = 1
        families = [
          {
            afi  = "ipv4"
            safi = "unicast"
            advertisements = {
              matchLabels = {
                advertise = "bgp"
              }
            }
          }
        ]
      }
    },
    {
      apiVersion = "cilium.io/v2alpha1"
      kind       = "CiliumBGPAdvertisement"
      metadata = {
        name = "bgp-advertisements-${var.cluster_bgp_peer_asn}"
        labels = {
          advertise = "bgp"
        }
      }
      spec = {
        advertisements = [
          {
            advertisementType = "Service"
            service = {
              addresses = [
                "ClusterIP",
                "ExternalIP",
                "LoadBalancerIP"
              ]
            }
            # Publish all services via BGP. By default, no services are published:
            # https://docs.cilium.io/en/stable/network/bgp-control-plane/#service-announcements
            selector = {
              matchExpressions = [
                {
                  key      = "cilium-bgp-dummy-service-key"
                  operator = "DoesNotExist"
                }
              ]
            }
            attributes = {
              communities = {
                standard = [
                  "65000:100"
                ]
              }
            }
          }
        ]
      }
    },
    {
      apiVersion = "cilium.io/v2alpha1"
      kind       = "CiliumLoadBalancerIPPool"
      metadata = {
        name = "external-pool"
      }
      spec = {
        blocks = [
          {
            cidr = var.cilium_load_balancer_cidr,
          }
        ]
      }
    },
  ]
  cilium_external_lb_manifest = join("---\n", [for d in local.cilium_external_lb_manifests : yamlencode(d)])
}

// see https://www.talos.dev/v1.7/kubernetes-guides/network/deploying-cilium/#method-4-helm-manifests-inline-install
// see https://docs.cilium.io/en/stable/network/servicemesh/ingress/
// see https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/
// see https://docs.cilium.io/en/stable/gettingstarted/hubble/
// see https://docs.cilium.io/en/stable/helm-reference/#helm-reference
// see https://github.com/cilium/cilium/releases
// see https://github.com/cilium/cilium/tree/v1.15.5/install/kubernetes/cilium
// see https://registry.terraform.io/providers/hashicorp/helm/latest/docs/data-sources/template
data "helm_template" "cilium" {
  namespace  = "kube-system"
  name       = "cilium"
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  # renovate: datasource=helm depName=cilium registryUrl=https://helm.cilium.io
  version = "1.16.2"
  # Set this to counter-act errors saying that cilium requires at least kubernetes 1.21.
  # TODO: Set this dynamically based on the actually running Kubernetes version?
  kube_version = "1.31.1"
  set {
    name  = "ipam.mode"
    value = "kubernetes"
  }
  set {
    name  = "securityContext.capabilities.ciliumAgent"
    value = "{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}"
  }
  set {
    name  = "securityContext.capabilities.cleanCiliumState"
    value = "{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}"
  }
  set {
    name  = "cgroup.autoMount.enabled"
    value = "false"
  }
  set {
    name  = "cgroup.hostRoot"
    value = "/sys/fs/cgroup"
  }
  set {
    name  = "k8sServiceHost"
    value = "localhost"
  }
  set {
    name  = "k8sServicePort"
    value = "7445"
  }
  set {
    name  = "kubeProxyReplacement"
    value = "true"
  }
  set {
    name  = "bgpControlPlane.enabled"
    value = "true"
  }
  set {
    name  = "ingressController.enabled"
    value = "true"
  }
  set {
    name  = "ingressController.default"
    value = "true"
  }
  set {
    name  = "ingressController.loadbalancerMode"
    value = "shared"
  }
  set {
    name  = "ingressController.enforceHttps"
    value = "false"
  }
  set {
    name  = "envoy.enabled"
    value = "true"
  }
  set {
    name  = "hubble.relay.enabled"
    value = "true"
  }
  set {
    name  = "hubble.ui.enabled"
    value = "true"
  }
}

resource "local_file" "kubectl_config" {
  content  = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = local.kubectl_config_path
}

resource "null_resource" "wait_for_cilium_installed" {
  depends_on = [talos_machine_bootstrap.this, local_file.kubectl_config]
  triggers = {
    on_manifests_change = "${local.cilium_external_lb_manifest}"
  }

  provisioner "local-exec" {
    command = "KUBECONFIG=${local.kubectl_config_path} cilium status --wait > /dev/null"
  }
}
