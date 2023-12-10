locals {
  talos_iso_image_location = replace(var.talos_iso_image_location, "%", var.talos_version)

  //noinspection HILUnresolvedReference
  talos_control_planes = flatten([
    for name, host in var.proxmox_servers : [
      for i in range(host.control_planes_count) : name
    ]
  ])
  talos_control_planes_count = length(local.talos_control_planes)
}

resource "proxmox_vm_qemu" "talos-control-plane" {
  for_each = {
    for i, x in local.talos_control_planes : i => x
  }

  name        = "${var.control_plane_name_prefix}-${each.key + 1}"
  vmid        = each.key + var.control_plane_first_id
  target_node = each.value
  iso         = local.talos_iso_image_location
  qemu_os     = "l26" # Linux kernel type
  onboot      = true

  cpu     = "host"
  sockets = 1
  cores   = var.control_plane_cpu_cores
  memory  = var.control_plane_memory
  scsihw  = "virtio-scsi-pci"

  network {
    model    = "virtio"
    bridge   = var.proxmox_servers[each.value].network_bridge
    firewall = false
  }

  disk {
    type     = "virtio"
    size     = "${var.boot_disk_size}G"
    storage  = var.proxmox_servers[each.value].disk_storage_pool
    cache    = "writethrough"
    iothread = 1
    backup   = false
  }
}

output "talos_control_plane_mac_addrs" {
  value = {
    for i, cfg in proxmox_vm_qemu.talos-control-plane : cfg.vmid => cfg.network[0].macaddr
  }
}
