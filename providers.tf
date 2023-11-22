terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">= 2.9.14"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.3.3"
    }
    synclocal = {
      source = "justenwalker/synclocal"
      version = ">= 0.0.2"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = ">= 0.9.4"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
}

provider "kustomization" {
  kubeconfig_raw = data.talos_cluster_kubeconfig.this.kubeconfig_raw
}
