# give the vms some time to boot before scanning for ip addresses
resource "time_sleep" "wait_for_vms_to_boot" {
  depends_on = [
    proxmox_virtual_environment_vm.talos-control-plane,
    proxmox_virtual_environment_vm.talos-worker-node
  ]

  create_duration = "15s"
}

# vms are booted, use nmap to scan the network and match the known mac
# addresses with the found ip addresses
data "external" "mac-to-ip" {
  depends_on = [time_sleep.wait_for_vms_to_boot]

  program = concat([
    "go",
    "run",
    "${path.module}/cmd/mac-to-ip",
    "-subnet",
    join(",", var.mac-to-ip_scan_subnets),
  ],
    [for i, cfg in macaddress.talos-control-plane : cfg.address],
    [for i, cfg in macaddress.talos-worker-node : cfg.address],
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
