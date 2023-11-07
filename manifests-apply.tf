# download and kustomize argocd manifests
resource "synclocal_url" "argocd_manifest" {
  url      = local.argocd_manifest_url
  filename = "${path.module}/manifests/argocd/argocd.yaml"
}

resource "null_resource" "apply_app_of_apps" {
  depends_on = [
    data.external.talos-nodes-ready,
    synclocal_url.argocd_manifest,
  ]

  for_each = var.app_of_apps
  provisioner "local-exec" {
    command = "kubectl kustomize --enable-helm ${path.module}/${each.value} | kubectl apply -f -"
  }
}
