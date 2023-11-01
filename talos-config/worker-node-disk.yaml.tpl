machine:
  kubelet:
    extraMounts:
      - destination: ${mount_point}
        type: bind
        source: ${mount_point}
        options:
          - bind
          - rshared
          - rw

  disks:
    - device: ${disk_device}
      partitions:
        - mountpoint: ${mount_point}
