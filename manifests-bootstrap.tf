# download and kustomize metrics server manifests
resource "synclocal_url" "metrics_server_manifest" {
  url      = local.metrics_server_manifest_url
  filename = "${path.module}/manifests/metrics-server/metrics-server.yaml"
}

data "external" "kustomize_metrics-server" {
  depends_on = [synclocal_url.metrics_server_manifest]
  program    = [
    "go",
    "run",
    "${path.module}/cmd/kustomize",
    "--",
    "${path.module}/manifests/metrics-server",
  ]
}

# download and kustomize argocd manifests
resource "synclocal_url" "argocd_manifest" {
  url      = local.argocd_manifest_url
  filename = "${path.module}/manifests/argocd/argocd.yaml"
}


data "external" "kustomize_bootstrap-manifests" {
  depends_on = [
    data.external.talos-nodes-ready,
    synclocal_url.argocd_manifest,
  ]
  for_each = {
    for i, m in var.bootstrap_manifests: "bootstrap-manifest-${i}" => m
  }

  program  = [
    "go",
    "run",
    "${path.module}/cmd/kustomize",
    "--",
    "--enable-helm",
    "-o",
    "${path.module}/output/${each.key}.yaml",
    "${path.module}/${each.value}",
  ]
}

resource "null_resource" "apply_bootstrap-manifests" {
  depends_on = [data.external.kustomize_bootstrap-manifests]
  for_each   = data.external.kustomize_bootstrap-manifests
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/output/${each.key}.yaml"
  }
}
