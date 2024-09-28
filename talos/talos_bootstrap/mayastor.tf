resource "kubectl_manifest" "mayastor_namespace" {
  depends_on = [null_resource.wait_for_cilium_installed]
  yaml_body  = file("${path.module}/files/manifests/mayastor/namespace.yaml")
}

resource "helm_release" "mayastor" {
  provider          = helm.cluster
  depends_on        = [kubectl_manifest.mayastor_namespace]
  name              = "mayastor"
  namespace         = "mayastor"
  repository        = "https://openebs.github.io/mayastor-extensions/"
  chart             = "mayastor"
  version           = "2.6.1"
  timeout           = 600
  dependency_update = true
  wait              = true

  set {
    name  = "etcd.localpvScConfig.basePath"
    value = "/var/openebs/local/{{ .Release.Name }}/localpv-hostpath/etcd"
  }

  set {
    name  = "loki-stack.localpvScConfig.basePath"
    value = "/var/openebs/local/{{ .Release.Name }}/localpv-hostpath/loki"
  }
}

resource "kubectl_manifest" "mayastor_diskpools" {
  depends_on = [helm_release.mayastor]
  count      = length(var.talos_worker_nodes)
  yaml_body = templatefile("${path.module}/templates/manifests/mayastor/diskpool.yaml.tmpl", {
    hostname  = format("worker-%02d", count.index + 1)
    data_disk = var.talos_worker_nodes[count.index].data_disk
  })
}
