locals {
  vm_worker_nodes = flatten([
    for i, worker in var.talos_worker_nodes : [
      for j in range(worker.count) : {
        index         = i
        target_server = worker.target_server
        node_labels   = merge(var.proxmox_servers[worker.target_server].node_labels, worker.node_labels)
        data_disks    = worker.data_disks
      }
    ]
  ])
}

resource "proxmox_vm_qemu" "talos-worker-node" {
  for_each = {
    for i, x in local.vm_worker_nodes : i => x
  }

  name        = "${var.worker_node_name_prefix}-${each.key + 1}"
  vmid        = each.key + var.worker_node_first_id
  target_node = each.value.target_server
  iso         = local.talos_iso_image_location
  qemu_os     = "l26" # Linux kernel type
  onboot      = true

  cpu     = "host"
  sockets = 1
  cores   = var.worker_node_cpu_cores
  memory  = var.worker_node_memory
  scsihw  = "virtio-scsi-pci"

  network {
    model    = "virtio"
    bridge   = var.proxmox_servers[each.value.target_server].network_bridge
    firewall = false
  }

  disk {
    type     = "virtio"
    size     = "${var.boot_disk_size}G"
    storage  = var.proxmox_servers[each.value.target_server].disk_storage_pool
    cache    = "writethrough"
    iothread = 1
    backup   = false
  }

  dynamic "disk" {
    for_each = var.talos_worker_nodes[each.value.index].data_disks

    content {
      type     = "virtio"
      size     = "${disk.value.size}G"
      storage  = disk.value.storage_pool != "" ? disk.value.storage_pool : var.proxmox_servers[each.value.target_server].disk_storage_pool
      cache    = "none"
      iothread = 1
      backup   = false
    }
  }
}

output "talos_worker_node_mac_addrs" {
  value = {
    for i, cfg in proxmox_vm_qemu.talos-worker-node : cfg.vmid => cfg.network[0].macaddr
  }
}
