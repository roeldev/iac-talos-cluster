machine:
  nodeLabels:
    topology.kubernetes.io/zone: ${topology_zone}
  certSANs:
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

    extraHostEntries:
      - ip: ${ipv4_vip}
        aliases:
          - ${cluster_domain}
