locals {
  vm_worker_nodes = flatten([
    for i, worker in var.worker_nodes : [
      for j in range(worker.count) : {
        index         = i
        target_server = worker.target_server
        node_labels   = merge(var.proxmox_servers[worker.target_server].node_labels, worker.node_labels)
        cpu_cores     = worker.cpu_cores > 0 ? worker.cpu_cores : var.worker_node_cpu_cores
        memory        = worker.memory > 0 ? worker.memory : var.worker_node_memory
        disk_size     = worker.disk_size > 0 ? worker.disk_size : var.worker_node_disk_size
        data_disks    = worker.data_disks
      }
    ]
  ])
}

resource "macaddress" "talos-worker-node" {
  count = length(local.vm_control_planes)
}

resource "proxmox_virtual_environment_vm" "talos-worker-node" {
  depends_on = [
#     proxmox_virtual_environment_file.talos-iso,
    macaddress.talos-worker-node
  ]
  for_each = {
    for i, x in local.vm_worker_nodes : i => x
  }

  name          = "${var.worker_node_name_prefix}-${each.key + 1}"
  vm_id         = each.key + var.worker_node_first_id
  node_name     = each.value.target_server
  on_boot       = true
  scsi_hardware = "virtio-scsi-pci"

  cdrom {
    enabled = true
    file_id = replace(local.talos_iso_image_location, "%", var.talos_version)
  }

  cpu {
    type    = "host"
    sockets = 1
    cores   = each.value.cpu_cores
  }

  memory {
    dedicated = each.value.memory*1024
  }

  network_device {
    enabled     = true
    model       = "virtio"
    bridge      = var.proxmox_servers[each.value.target_server].network_bridge
    mac_address = macaddress.talos-worker-node[each.key].address
    firewall    = false
  }

  operating_system {
    type = "l26" # Linux kernel type
  }

  disk {
    interface    = "virtio0"
    size         = each.value.disk_size
    datastore_id = var.proxmox_servers[each.value.target_server].disk_storage_pool
    file_format  = "raw"
    cache        = "writethrough"
    iothread     = true
    backup       = false
  }

  dynamic "disk" {
    for_each = var.worker_nodes[each.value.index].data_disks

    content {
      interface    = "virtio${each.value.index+1}"
      size         = disk.value.size
      datastore_id = disk.value.storage_pool != "" ? disk.value.storage_pool : var.proxmox_servers[each.value.target_server].disk_storage_pool
      file_format  = "raw"
      cache        = "none"
      iothread     = true
      backup       = false
    }
  }
}

output "talos_worker_node_mac_addrs" {
  value = macaddress.talos-worker-node
}
