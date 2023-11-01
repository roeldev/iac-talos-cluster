variable "cluster_name" {
  description = "Name of the Talos Kubernetes cluster"
  type        = string
  default     = "talos-cluster"
}

variable "cluster_vip" {
  description = "Virtual IP of the Talos Kubernetes cluster"
  type        = string
}

variable "cluster_domain" {
  description = "Domain name of the Talos Kubernetes cluster"
  type        = string
  default     = "talos-cluster.local"
}

variable "cluster_endpoint_port" {
  description = "Port of the Kubernetes API endpoint"
  type        = number
  default     = 6443
}

variable "network_ip_prefix" {
  description = "Network IP network prefix"
  type        = number
  default     = 24
}

variable "network_cidr" {
  description = "Network address in CIDR notation"
  type        = string
  default     = "10.0.0.1/24"
}

variable "network_gateway" {
  description = "Gateway of the network"
  type        = string
  default     = "10.0.0.1"
}

variable "control_plane_first_ip" {
  description = "First ip of a control-plane"
  type        = number
  default     = 111
}

variable "worker_node_first_ip" {
  description = "First ip of a worker node"
  type        = number
  default     = 121
}

variable "install_disk_device" {
  description = "Disk to install Talos on"
  type        = string
  default     = "/dev/vda"
}
