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


data "external" "kustomize_apps-manifests" {
  depends_on = [
    data.external.talos-nodes-ready,
    synclocal_url.argocd_manifest,
  ]
  program    = [
    "go",
    "run",
    "${path.module}/cmd/kustomize",
    "--",
    "--enable-helm",
    "${path.module}/${var.app_of_apps}",
  ]
}

resource "local_file" "export_apps-manifests" {
  depends_on = [data.external.kustomize_apps-manifests]
  content    = data.external.kustomize_apps-manifests.result.manifests
  filename   = "${path.module}/output/apps-manifests.yaml"
}

resource "null_resource" "apply_apps-manifests" {
  depends_on = [local_file.export_apps-manifests]
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/output/apps-manifests.yaml"
  }
}
