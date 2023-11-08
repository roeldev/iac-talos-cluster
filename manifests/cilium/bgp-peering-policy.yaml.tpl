# https://docs.cilium.io/en/v1.14/network/bgp-control-plane/
---
apiVersion: "cilium.io/v2alpha1"
kind: CiliumBGPPeeringPolicy
metadata:
  name: default
  namespace: cilium-system
spec:
  # Nodes which are selected by this label selector will apply the given policy
  nodeSelector:
    matchLabels:
      cilium/bgp-peering-policy: default
  virtualRouters:
    - localASN: ${cilium_asn}
      exportPodCIDR: true
      neighbors:
        - peerAddress: ${router_ip}/32
          peerASN: ${router_asn}
          eBGPMultihopTTL: 10
          connectRetryTimeSeconds: 120
          holdTimeSeconds: 90
          keepAliveTimeSeconds: 30
          gracefulRestart:
            enabled: true
            restartTimeSeconds: 120
