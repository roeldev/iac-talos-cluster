variable "bootstrap_manifests" {
  description = "Bootstrap manifests from directories using Kustomize"
  type        = list(string)
  default     = ["manifests/apps"]
}

variable "talos_ccm_manifest_url" {
  description = "Talos Cloud Controller Manager manifest to use"
  type        = string
  # % is replaced by talos_ccm_version
  default     = "https://raw.githubusercontent.com/siderolabs/talos-cloud-controller-manager/v%/docs/deploy/cloud-controller-manager.yml"
}

variable "argocd_manifest_url" {
  description = "ArgoCD manifest to use"
  type        = string
  # % is replaced by metrics_server_version
  default     = "https://raw.githubusercontent.com/argoproj/argo-cd/v%/manifests/ha/install.yaml"
}

variable "metrics_server_manifest_url" {
  description = "Kubernetes Metrics Server manifest to use"
  type        = string
  # % is replaced by metrics_server_version
  default     = "https://github.com/kubernetes-sigs/metrics-server/releases/download/v%/components.yaml"
}
