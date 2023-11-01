resource "terraform_data" "inline-manifests" {
  depends_on = [
    data.external.kustomize_talos-ccm,
    data.external.kustomize_cilium,
    data.external.kustomize_metrics-server,
  ]

  input = [
    {
      # required, prevents certificate errors
      name     = "talos-ccm"
      contents = data.external.kustomize_talos-ccm.result.manifests
    },
    {
      # required, is used as CNI and is needed for Talos to report nodes as ready
      name     = "cilium"
      contents = data.external.kustomize_cilium.result.manifests
    },
#    {
#      # optional, may be installed using argocd
#      name     = "metrics-server"
#      contents = data.external.kustomize_metrics-server.result.manifests
#    },
  ]
}

resource "talos_machine_configuration_apply" "control-planes" {
  depends_on = [
    data.external.mac-to-ip,
    data.talos_machine_configuration.cp,
    terraform_data.inline-manifests,
  ]

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.cp.machine_configuration

  for_each = {for i, vm in proxmox_vm_qemu.talos-control-plane : (vm.vmid - var.control_plane_first_id) => vm}
  node     = data.external.mac-to-ip.result[each.value.network[0].macaddr]

  config_patches = [
    templatefile("${path.module}/talos-config/control-plane.yaml.tpl", {
      topology_zone     = each.value.target_node,
      cluster_domain    = var.cluster_domain,
      cluster_endpoint  = local.cluster_endpoint,
      network_interface = "enx${lower(replace(each.value.network[0].macaddr, ":", ""))}",
      network_ip_prefix = var.network_ip_prefix,
      network_gateway   = var.network_gateway,
      hostname          = "${var.control_plane_name_prefix}-${each.key + 1}"
      ipv4_local        = cidrhost(var.network_cidr, each.key + var.control_plane_first_ip),
      ipv4_vip          = var.cluster_vip,
      inline_manifests  = jsonencode(terraform_data.inline-manifests.output),
    }),
  ]
}

resource "talos_machine_configuration_apply" "worker-nodes" {
  depends_on = [
    data.external.mac-to-ip,
    data.talos_machine_configuration.wn,
  ]

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.wn.machine_configuration

  for_each = {for i, vm in proxmox_vm_qemu.talos-worker-node : (vm.vmid - var.worker_node_first_id) => vm}
  node     = data.external.mac-to-ip.result[each.value.network[0].macaddr]

  config_patches = concat([
    templatefile("${path.module}/talos-config/worker-node.yaml.tpl", {
      topology_zone     = each.value.target_node,
      cluster_domain    = var.cluster_domain,
      network_interface = "enx${lower(replace(each.value.network[0].macaddr, ":", ""))}",
      network_ip_prefix = var.network_ip_prefix,
      network_gateway   = var.network_gateway,
      hostname          = "${var.worker_node_name_prefix}-${each.key + 1}"
      ipv4_local        = cidrhost(var.network_cidr, each.key + var.worker_node_first_ip),
      ipv4_vip          = var.cluster_vip,
    }),
    templatefile("${path.module}/talos-config/node-labels.yaml.tpl", {
      node_labels = jsonencode(local.vm_worker_nodes[each.key].node_labels),
    })
  ],
    [
      for disk in var.talos_worker_nodes[local.vm_worker_nodes[each.key].index].data_disks : templatefile(
      "${path.module}/talos-config/worker-node-disk.yaml.tpl",
      {
        disk_device = "/dev/${disk.device_name}",
        mount_point = disk.mount_point,
      })
    ]
  )
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.control-planes,
    talos_machine_configuration_apply.worker-nodes
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = cidrhost(var.network_cidr, var.control_plane_first_ip)
}
