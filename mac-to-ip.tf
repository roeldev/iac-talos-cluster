resource "time_sleep" "wait_for_vms_to_boot" {
  depends_on = [
    proxmox_vm_qemu.talos-control-plane,
    proxmox_vm_qemu.talos-worker-node
  ]

  create_duration = "15s"
}

data "external" "mac-to-ip" {
  depends_on = [time_sleep.wait_for_vms_to_boot]

  program = concat([
    "go",
    "run",
    "${path.module}/cmd/mac-to-ip",
    "-subnet",
    join(",", var.mac-to-ip_scan_subnets),
  ],
    [for i, cfg in proxmox_vm_qemu.talos-control-plane : cfg.network[0].macaddr],
    [for i, cfg in proxmox_vm_qemu.talos-worker-node : cfg.network[0].macaddr],
  )
}

output "mac-to-ip" {
  value = data.external.mac-to-ip.result
}

variable "mac-to-ip_scan_subnets" {
  description = "Subnets to scan MAC addresses for IP addresses."
  type        = list(string)
  default     = ["10.0.0.1/24"]
}
