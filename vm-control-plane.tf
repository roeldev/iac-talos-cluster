locals {
  talos_iso_image_location = "${var.talos_iso_destination_storage_pool}:iso/${replace(var.talos_iso_destination_filename, "%", var.talos_version)}"

  //noinspection HILUnresolvedReference
  vm_control_planes = flatten([
    for name, host in var.proxmox_servers : [
      for i in range(host.control_planes_count) : name
    ]
  ])
  vm_control_planes_count = length(local.vm_control_planes)
}

# this keeps bitching about the file already exists... i know, just skip it then
#
# resource "proxmox_virtual_environment_file" "talos-iso" {
#   content_type = "iso"
#   datastore_id = var.talos_iso_destination_storage_pool
#   node_name    = var.talos_iso_destination_server != "" ? var.talos_iso_destination_server : keys(var.proxmox_servers)[0]
#   overwrite = false
#
#   source_file {
#     path      = replace(var.talos_iso_download_url, "%", var.talos_version)
#     file_name = replace(var.talos_iso_destination_filename, "%", var.talos_version)
#   }
# }

resource "macaddress" "talos-control-plane" {
  count = length(local.vm_control_planes)
}

resource "proxmox_virtual_environment_vm" "talos-control-plane" {
  depends_on = [
#     proxmox_virtual_environment_file.talos-iso,
    macaddress.talos-control-plane
  ]
  for_each = {
    for i, x in local.vm_control_planes : i => x
  }

  name          = "${var.control_plane_name_prefix}-${each.key + 1}"
  vm_id         = each.key + var.control_plane_first_id
  node_name     = each.value
  on_boot       = true
  scsi_hardware = "virtio-scsi-pci"

  cdrom {
    enabled = true
    file_id =  replace(local.talos_iso_image_location, "%", var.talos_version)
  }

  cpu {
    type    = "host"
    sockets = 1
    cores   = var.control_plane_cpu_cores
  }

  memory {
    dedicated = var.control_plane_memory*1024
  }

  network_device {
    enabled     = true
    model       = "virtio"
    bridge      = var.proxmox_servers[each.value].network_bridge
    mac_address = macaddress.talos-control-plane[each.key].address
    firewall    = false
  }

  operating_system {
    type = "l26" # Linux kernel type
  }

  disk {
    interface    = "virtio0"
    size         = var.control_plane_disk_size
    datastore_id = var.proxmox_servers[each.value].disk_storage_pool
    file_format  = "raw"
    cache        = "writethrough"
    iothread     = true
    backup       = false
  }
}

output "talos_control_plane_mac_addrs" {
  value = macaddress.talos-control-plane
}
