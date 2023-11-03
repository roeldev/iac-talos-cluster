# download and kustomize argocd manifests
resource "synclocal_url" "argocd_manifest" {
  url      = local.argocd_manifest_url
  filename = "${path.module}/manifests/argocd/argocd.yaml"
}

resource "null_resource" "apply_argocd" {
  depends_on = [
    data.external.talos-nodes-ready,
    synclocal_url.argocd_manifest,
  ]
  provisioner "local-exec" {
    command = "kubectl apply -k ${path.module}/manifests/argocd"
  }
}

resource "null_resource" "apply_app_of_apps" {
  depends_on = [null_resource.apply_argocd]
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/${var.app_of_apps_manifest}"
  }
}
