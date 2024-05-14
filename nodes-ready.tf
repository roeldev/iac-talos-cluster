# use kubectl to poll the readiness status of the nodes
data "external" "talos-nodes-ready" {
  depends_on = [null_resource.talos-cluster-up]

  program = concat([
    "go",
    "run",
    "${path.module}/cmd/nodes-ready",
  ],
    [for i, cfg in proxmox_virtual_environment_vm.talos-control-plane : cfg.name],
    [for i, cfg in proxmox_virtual_environment_vm.talos-worker-node : cfg.name],
  )
}
