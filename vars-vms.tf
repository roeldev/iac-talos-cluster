variable "worker_nodes" {
  type = list(object({
    # Name of Proxmox target server on which the worker node(s) will be deployed
    target_server = string
    # Additional kubernetes node labels to add to the worker node(s)
    node_labels   = optional(map(string), {})
    # Number of worker nodes to deploy on the target server
    count         = optional(number, 1)

    # The amount of CPU cores to give the worker node(s)
    cpu_cores = optional(number, 0)
    # The amount of memory in GiB to give the worker node(s)
    memory    = optional(number, 0)
    # The size of the boot disk in GiB to give the worker node(s)
    disk_size = optional(number, 0)

    data_disks = optional(list(object({
      device_name  = string
      mount_point  = string
      # The size of the data disk in GiB per worker node
      size         = number
      # The name of the storage pool where the disk be stored
      storage_pool = optional(string, "")
    })), [])
  }))
}

variable "control_plane_name_prefix" {
  description = "Name prefix used in both VM name and hostname, for a control-plane"
  type        = string
  default     = "talos-control-plane"
}

variable "worker_node_name_prefix" {
  description = "Name prefix used in both VM name and hostname, for a worker node"
  type        = string
  default     = "talos-worker-node"
}

variable "control_plane_first_id" {
  description = "First id of a control-plane"
  type        = number
  default     = 8101
}

variable "worker_node_first_id" {
  description = "First id of a worker node"
  type        = number
  default     = 8201
}

variable "control_plane_cpu_cores" {
  description = "The default amount of CPU cores to give the control plane nodes"
  type        = number
  default     = 2
}

variable "worker_node_cpu_cores" {
  description = "The default amount of CPU cores to give the worker nodes"
  type        = number
  default     = 4
}

variable "control_plane_memory" {
  description = "The default amount of memory (GiB) to give the control plane nodes"
  type        = number
  default     = 4
}

variable "worker_node_memory" {
  description = "The default amount of memory (GiB) to give the worker nodes"
  type        = number
  default     = 16
}

variable "control_plane_disk_size" {
  description = "The size of the boot disk (GiB) to give the control plane nodes"
  type        = number
  default     = 8
}

variable "worker_node_disk_size" {
  description = "The default size of the boot disk (GiB) to give the worker nodes"
  type        = number
  default     = 16
}
