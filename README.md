# HINLINK H28K support

This repository provides out-of-tree HINLINK H28K support for the
`openwrt-25.12` Rockchip source tree. The implementation is delivered as
repository-level patches intended for `git apply`.

## Patch layout

| Patch | Purpose |
| --- | --- |
| `0010-rockchip-add-HINLINK-H28K-U-Boot-support.patch` | Adds the U-Boot target and H28K DTS, U-Boot DTSI, and defconfig. |
| `0020-rockchip-add-HINLINK-H28K-device-tree.patch` | Adds the Linux H28K device tree and system LED aliases. |
| `0030-rockchip-add-HINLINK-H28K-board-defaults.patch` | Adds LED defaults, LAN/WAN assignment, MAC generation, and IRQ affinity. |
| `0040-rockchip-add-HINLINK-H28K-image.patch` | Adds the `hinlink_h28k` image profile and required kernel packages. |
| `0050-rockchip-configure-HINLINK-H28K-RJ45-LEDs.patch` | Configures both RJ45 ports for link and activity LEDs. |

## Apply

Checkout the `openwrt-25.12` source tree, then apply the patches in order:

```sh
cd source

for patch in /path/to/hinlink-h28k/patches/*.patch; do
  git apply --check "$patch"
  git apply "$patch"
done
```

To build only this device, use the supplied seed configuration:

```sh
cp /path/to/hinlink-h28k/.github/configs/hinlink-h28k.config .config
make defconfig
make -j"$(nproc)" download
make -j"$(nproc)"
```

The image profile is `hinlink_h28k` and the generated filename uses the
standard target, architecture, and device naming convention.

## Validation

The patch set was validated against the `openwrt-25.12` source tree at
commit `1cfeb3edade40fe2dfec59c21381de1d8e361100`.

- Linux H28K DTB generated successfully.
- U-Boot H28K DTB and image generated successfully.
- Firmware image generation completed successfully.

## Implementation notes

- Linux DTS support stays in `target/linux/rockchip/files`.
- U-Boot DTS and defconfig files stay in `package/boot/uboot-rockchip/src`.
- The ADC boot button pulls in both ADC keys and the Rockchip SARADC driver.
- The board uses `eth0` as LAN and `eth1` as WAN.
