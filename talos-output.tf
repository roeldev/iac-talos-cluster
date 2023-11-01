data "talos_cluster_kubeconfig" "this" {
  depends_on = [talos_machine_bootstrap.this]

  client_configuration = data.talos_client_configuration.this.client_configuration
  node                 = cidrhost(var.network_cidr, var.control_plane_first_ip)
}

resource "local_file" "export_inline-manifests" {
  depends_on = [terraform_data.inline-manifests]
  content    = yamlencode(terraform_data.inline-manifests.output)
  filename   = "${path.module}/output/inline-manifests.yaml"
}

resource "local_sensitive_file" "export_talosconfig" {
  depends_on = [data.talos_client_configuration.this]
  content    = data.talos_client_configuration.this.talos_config
  filename   = "${path.module}/output/talosconfig"
}

resource "local_sensitive_file" "export_kubeconfig" {
  depends_on = [data.talos_cluster_kubeconfig.this]
  content    = data.talos_cluster_kubeconfig.this.kubeconfig_raw
  filename   = "${path.module}/output/kubeconfig"
}

data "external" "copy_talosconfig" {
  depends_on = [local_sensitive_file.export_talosconfig]

  program = [
    "go",
    "run",
    "${path.module}/cmd/cp-to-home",
    "${path.module}/output/talosconfig",
    "~/.talos/config",
  ]
}

data "external" "copy_kubeconfig" {
  depends_on = [local_sensitive_file.export_kubeconfig]

  program = [
    "go",
    "run",
    "${path.module}/cmd/cp-to-home",
    "${path.module}/output/kubeconfig",
    "~/.kube/config",
  ]
}

resource "null_resource" "talos-cluster-up" {
  depends_on = [
    data.external.copy_talosconfig,
    data.external.copy_kubeconfig,
  ]
}

output "talos_client_configuration" {
  value     = data.talos_client_configuration.this
  sensitive = true
}

output "talos_cluster_kubeconfig" {
  value     = data.talos_cluster_kubeconfig.this
  sensitive = true
}
