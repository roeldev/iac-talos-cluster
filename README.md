Talos cluster on Proxmox
========================

This repository contains a Terraform configuration to create a Talos cluster on Proxmox.
It includes a basic Kubernetes configuration to run services on the cluster, which includes Cilium as CNI and ArgoCD.
  

## Requirements

- Proxmox server(s)
- terraform
- kubectl
- go
- nmap


## Usage

- Make sure all tools are installed and are set in your PATH.
- Run `make init` to initialize the Terraform providers.
- Download the correct Talos release image and place it in a folder which Proxmox can access.
- Change the `mac-to-ip_scan_subnets` variable to match to subnets on which Proxmox creates the VMs by default.
- Optionally run `terraform plan` to see what will be created.
- Run `make cluster` to create the VMs, boot the Talos cluster and run some basic Kubernetes services.


## How it works

- Terraform creates VMs in Proxmox using a Talos release image
- Terraform creates Talos configs and applies it to the VMs running Talos
- A Talos control plane is bootstrapped and a Talos cluster is formed
- Terraform generates the inline manifests which Talos installs
- Terraform waits for the nodes to be ready and installs ArgoCD
- ArgoCD installs all specified applications
- ArgoCD keeps the applications in sync with the manifests in this repository

If everything works as expected, ArgoCD should automatically install metrics-server on the just created Kubernetes cluster.


## License

Copyright © 2023-2024 [Roel Schut](https://roelschut.nl). All rights reserved.

This project is governed by a BSD-style license that can be found in the [LICENSE](LICENSE) file.
