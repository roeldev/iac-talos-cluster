variable "talos_version" {
  # https://github.com/siderolabs/talos/releases
  description = "Talos version to use"
  type        = string
  default     = "1.6.6"
}

variable "talos_machine_install_image_url" {
  # https://www.talos.dev/v1.6/talos-guides/install/boot-assets/
  description = "The URL of the Talos machine install image"
  type = string
  # % is replaced by talos_version
  default = "ghcr.io/siderolabs/installer:v%"
}

variable "k8s_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "1.29.2"
}

variable "talos_ccm_version" {
  # https://github.com/siderolabs/talos-cloud-controller-manager/releases
  description = "Talos Cloud Controller Manager version to use"
  type        = string
  default     = "1.4.0"
}

variable "cilium_version" {
  # https://helm.cilium.io/
  description = "Cilium Helm version to use"
  type        = string
  default     = "1.15.2"
}

variable "argocd_version" {
  # https://github.com/argoproj/argo-cd/releases
  description = "ArgoCD version to use"
  type        = string
  default     = "2.10.4"
}

variable "metrics_server_version" {
  # https://github.com/kubernetes-sigs/metrics-server/releases
  description = "Kubernetes Metrics Server version to use"
  type        = string
  default     = "0.7.0"
}
