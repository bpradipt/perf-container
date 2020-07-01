# Create a Docker image with Linux trace tools

## Build
```
make release
make manifest
```

## Running
Some tools require access to `/lib/modules` so that the right kernel headers are used. Newer kernels include a kernel module named `kheaders.ko`, which when loaded makes the kernel headers available under `/sys/kernel/kheaders.tar.xz` [CONFIG_IKHEADERS]. In addition, tracefs/debugfs is used for creating probes, so `/sys/kernel/debug` needs to be available inside the container.

This can be achieved by passing `--volume /lib/modules:/lib/modules --volume /sys/kernel/debug:/sys/kernel/debug` to the container.
