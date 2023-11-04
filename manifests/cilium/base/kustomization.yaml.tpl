resources:
  - namespace.yaml

helmCharts:
  - name: cilium
    repo: https://helm.cilium.io/
    version: ${cilium_version}
    releaseName: cilium
    namespace: cilium-system
    includeCRDs: true
    valuesFile: values.yaml
