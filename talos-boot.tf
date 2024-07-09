resource "terraform_data" "inline-manifests" {
  depends_on = [
    data.external.kustomize_talos-ccm,
    data.external.kustomize_cilium,
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
    {
      name     = "cilium-bgp-peering-policy"
      contents = templatefile("${path.module}/manifests/cilium/bgp-peering-policy.yaml.tpl", {
        cilium_asn = var.cilium_asn,
        router_ip  = var.router_ip != "" ? var.router_ip : var.network_gateway,
        router_asn = var.router_asn,
      })
    }
  ]
}

resource "talos_machine_configuration_apply" "control-planes" {
  depends_on = [
    data.external.mac-to-ip,
    data.talos_machine_configuration.cp,
    terraform_data.inline-manifests,
  ]
  for_each = {
    for i, x in local.vm_control_planes : i => x
  }

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.cp.machine_configuration

  node = data.external.mac-to-ip.result[macaddress.talos-control-plane[each.key].address]

  config_patches = [
    templatefile("${path.module}/talos-config/control-plane.yaml.tpl", {
      topology_zone     = each.value,
      cluster_domain    = var.cluster_domain,
      cluster_endpoint  = local.cluster_endpoint,
      network_interface = "enx${lower(replace(macaddress.talos-control-plane[each.key].address, ":", ""))}",
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
  for_each = {
    for i, x in local.vm_worker_nodes : i => x
  }

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.wn.machine_configuration

  node = data.external.mac-to-ip.result[macaddress.talos-worker-node[each.key].address]

  config_patches = concat([
    templatefile("${path.module}/talos-config/worker-node.yaml.tpl", {
      topology_zone     = each.value.target_server,
      cluster_domain    = var.cluster_domain,
      network_interface = "enx${lower(replace(macaddress.talos-worker-node[each.key].address, ":", ""))}",
      network_ip_prefix = var.network_ip_prefix,
      network_gateway   = var.network_gateway,
      hostname          = "${var.worker_node_name_prefix}-${each.key + 1}"
      ipv4_local        = cidrhost(var.network_cidr, each.key + var.worker_node_first_ip),
      ipv4_vip          = var.cluster_vip,
    }),
    templatefile("${path.module}/talos-config/node-labels.yaml.tpl", {
      node_labels = jsonencode(each.value.node_labels),
    })
  ],
    [
      for disk in each.value.data_disks : templatefile(
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

# unfortunately, this does not really check, wait and retry for the cluster to
# be ready but instead errors and fails when unable to connect to nodes that
# are in the process of getting ready
#
# data "talos_cluster_health" "ready" {
#   depends_on = [null_resource.talos-cluster-up]
#
#   client_configuration = talos_machine_secrets.this.client_configuration
#   endpoints            = [for i, mac in macaddress.talos-control-plane : data.external.mac-to-ip.result[mac.address]]
#   control_plane_nodes  = [for i, mac in macaddress.talos-control-plane : data.external.mac-to-ip.result[mac.address]]
#   worker_nodes         = [for i, mac in macaddress.talos-worker-node : data.external.mac-to-ip.result[mac.address]]
# }
