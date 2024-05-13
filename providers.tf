terraform {
  required_providers {
    proxmox = {
      source  = "TheGameProfi/proxmox"
      version = ">= 2.9.15"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.5.0"
    }
    synclocal = {
      source  = "justenwalker/synclocal"
      version = ">= 0.0.2"
    }
    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
}
