machine:
  nodeLabels:
    topology.kubernetes.io/region: ${topology_region}
    cilium/bgp-peering-policy: default

  kubelet:
    extraConfig:
      serverTLSBootstrap: true
    extraArgs:
      # https://github.com/siderolabs/talos-cloud-controller-manager#node-certificate-approval
      cloud-provider: external
      rotate-server-certificates: true

  network:
    nameservers:
      - ${network_gateway}

  time:
    servers:
      - ${network_gateway}
      - 0.ubnt.pool.ntp.org

  install:
    disk: ${install_disk_device}
    image: ${install_image_url}
    bootloader: true
    wipe: false

  systemDiskEncryption:
    ephemeral:
      provider: luks2
      keys:
        - nodeID: { }
          slot: 0
    state:
      provider: luks2
      keys:
        - nodeID: { }
          slot: 0

  kernel:
    modules:
      - name: br_netfilter
        parameters:
          - nf_conntrack_max=131072

  sysctls:
    net.bridge.bridge-nf-call-ip6tables: "1"
    net.bridge.bridge-nf-call-iptables: "1"
    net.ipv4.ip_forward: "1"

  files:
    - path: /var/cri/conf.d/metrics.toml
      op: create
      content: |
        [metrics]
        address = "0.0.0.0:11234"

  features:
    kubePrism:
      enabled: true
      port: 7445

# https://www.talos.dev/v1.5/kubernetes-guides/network/deploying-cilium/
cluster:
  network:
    cni:
      name: none
  proxy:
    disabled: true
