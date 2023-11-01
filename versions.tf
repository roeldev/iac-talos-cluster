variable "talos_version" {
  # https://github.com/siderolabs/talos/releases
  description = "Talos version to use"
  type        = string
  default     = "1.5.3"
}

variable "k8s_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "1.28.2"
}

variable "talos_ccm_version" {
  # https://github.com/siderolabs/talos-cloud-controller-manager/releases
  description = "Talos Cloud Controller Manager version to use"
  type        = string
  default     = "1.4.0"
}

variable "talos_ccm_manifest_url" {
  description = "Talos Cloud Controller Manager manifest to use"
  type        = string
  # % is replaced by talos_ccm_version
  default     = "https://raw.githubusercontent.com/siderolabs/talos-cloud-controller-manager/v%/docs/deploy/cloud-controller-manager.yml"
}

variable "metrics_server_version" {
  # https://github.com/kubernetes-sigs/metrics-server/releases
  description = "Kubernetes Metrics Server version to use"
  type        = string
  default     = "0.6.4"
}

variable "metrics_server_manifest_url" {
  description = "Kubernetes Metrics Server manifest to use"
  type        = string
  # % is replaced by metrics_server_version
  default     = "https://github.com/kubernetes-sigs/metrics-server/releases/download/v%/components.yaml"
}
