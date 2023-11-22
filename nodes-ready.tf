data "external" "talos-nodes-ready" {
  depends_on = [null_resource.talos-cluster-up]

  program = concat([
    "go",
    "run",
    "${path.module}/cmd/nodes-ready",
  ],
    [for i, cfg in proxmox_vm_qemu.talos-control-plane : cfg.name],
    [for i, cfg in proxmox_vm_qemu.talos-worker-node : cfg.name],
  )
}
