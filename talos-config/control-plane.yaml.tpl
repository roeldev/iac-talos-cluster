machine:
  nodeLabels:
    topology.kubernetes.io/zone: ${topology_zone}
  certSANs:
    - ${cluster_domain}
    - ${ipv4_vip}
    - ${hostname}
    - ${ipv4_local}

  network:
    hostname: ${hostname}
    interfaces:
      - interface: ${network_interface}
        dhcp: false
        addresses:
          - ${ipv4_local}/${network_ip_prefix}
        routes:
          - network: 0.0.0.0/0
            gateway: ${network_gateway}
        vip:
          ip: ${ipv4_vip}

    extraHostEntries:
      - ip: 127.0.0.1
        aliases:
          - ${cluster_domain}

  # https://github.com/siderolabs/talos-cloud-controller-manager#node-certificate-approval
  features:
    kubernetesTalosAPIAccess:
      enabled: true
      allowedRoles:
        - os:reader
      allowedKubernetesNamespaces:
        - kube-system

cluster:
  inlineManifests: ${inline_manifests}
