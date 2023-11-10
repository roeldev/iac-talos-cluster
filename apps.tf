data "kustomization_build" "app_of_apps" {
  depends_on = [
    data.external.talos-nodes-ready,
    synclocal_url.argocd_manifest,
  ]

  path = "${path.module}/${var.app_of_apps}"

  kustomize_options {
    enable_helm     = true
    helm_path       = var.kustomize_helm_path
    load_restrictor = "none"
  }
}

resource "kustomization_resource" "app_of_apps_p0" {
  depends_on = [data.kustomization_build.app_of_apps]
  for_each   = data.kustomization_build.app_of_apps.ids_prio[0]

  manifest = (contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
  ? sensitive(data.kustomization_build.app_of_apps.manifests[each.value])
  : data.kustomization_build.app_of_apps.manifests[each.value])
}

resource "kustomization_resource" "app_of_apps_p1" {
  depends_on = [kustomization_resource.app_of_apps_p0]
  for_each   = data.kustomization_build.app_of_apps.ids_prio[1]

  manifest = (contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
  ? sensitive(data.kustomization_build.app_of_apps.manifests[each.value])
  : data.kustomization_build.app_of_apps.manifests[each.value])

  wait = true
  timeouts {
    create = "2m"
    update = "2m"
  }
}

resource "kustomization_resource" "app_of_apps_p2" {
  depends_on = [kustomization_resource.app_of_apps_p1]
  for_each   = data.kustomization_build.app_of_apps.ids_prio[2]

  manifest = (contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
  ? sensitive(data.kustomization_build.app_of_apps.manifests[each.value])
  : data.kustomization_build.app_of_apps.manifests[each.value])
}
