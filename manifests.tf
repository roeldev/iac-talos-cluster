locals {
  talos_ccm_manifest_url      = replace(var.talos_ccm_manifest_url, "%", var.talos_ccm_version)
  metrics_server_manifest_url = replace(var.metrics_server_manifest_url, "%", var.metrics_server_version)
  argocd_manifest_url         = replace(var.argocd_manifest_url, "%", var.argocd_version)
}

# download and kustomize talos ccm manifests
resource "synclocal_url" "talos_ccm_manifest" {
  url      = local.talos_ccm_manifest_url
  filename = "${path.module}/manifests/talos-ccm/talos-ccm.yaml"

  lifecycle {
    prevent_destroy = true
  }
}

data "external" "kustomize_talos-ccm" {
  depends_on = [synclocal_url.talos_ccm_manifest]
  program    = [
    "go",
    "run",
    "${path.module}/cmd/kustomize",
    "--",
    "${path.module}/manifests/talos-ccm",
  ]
}

# kustomize cilium manifests
resource "local_file" "cilium_kustomization" {
  filename = "${path.module}/manifests/cilium/base/kustomization.yaml"
  content  = templatefile("${path.module}/manifests/cilium/base/kustomization.yaml.tpl", {
    cilium_version = var.cilium_version
  })

  lifecycle {
    prevent_destroy = true
  }
}

data "external" "kustomize_cilium" {
  depends_on = [local_file.cilium_kustomization]
  program    = [
    "go",
    "run",
    "${path.module}/cmd/kustomize",
    "--",
    "--enable-helm",
    "${path.module}/manifests/cilium",
  ]
}

# download and kustomize metrics server manifests
resource "synclocal_url" "metrics_server_manifest" {
  url      = local.metrics_server_manifest_url
  filename = "${path.module}/manifests/metrics-server/metrics-server.yaml"

  lifecycle {
    prevent_destroy = true
  }
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

  lifecycle {
    prevent_destroy = true
  }
}