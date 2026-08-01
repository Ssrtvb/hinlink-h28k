# ImmortalWrt 25.12 HINLINK H28K support

This repository carries out-of-tree HINLINK H28K support for the
`openwrt-25.12` branch of ImmortalWrt. The implementation follows the
existing ImmortalWrt Rockchip layout and is delivered as repository-level
patches intended for `git apply`.

The H28K hardware description is maintained as local ImmortalWrt Rockchip
source files, matching the layout used by devices such as MangoPi M28K.

## Patch layout

| Patch | Purpose |
| --- | --- |
| `0010-rockchip-add-HINLINK-H28K-U-Boot-support.patch` | Adds the U-Boot target and locally maintained DTS, U-Boot DTSI, and defconfig under `uboot-rockchip/src`. |
| `0020-rockchip-add-HINLINK-H28K-device-tree.patch` | Adds the locally maintained Linux DTS under `target/linux/rockchip/files`, including system LED aliases. |
| `0030-rockchip-add-HINLINK-H28K-board-defaults.patch` | Adds LED defaults, LAN/WAN assignment, deterministic MAC generation, and IRQ affinity. |
| `0040-rockchip-add-HINLINK-H28K-image.patch` | Adds the `hinlink_h28k` image profile and required kernel packages. |
| `0050-rockchip-configure-HINLINK-H28K-RJ45-LEDs.patch` | Configures both RJ45 ports to use green for link and amber for activity. |

## Apply

```sh
git clone --branch openwrt-25.12 --single-branch \
  https://github.com/immortalwrt/immortalwrt.git
cd immortalwrt

for patch in /path/to/immh28k/patches/*.patch; do
  git apply --check "$patch"
  git apply "$patch"
done
```

To select only this device, use the supplied seed configuration:

```sh
cp /path/to/immh28k/.github/configs/hinlink-h28k.config .config
make defconfig
make -j"$(nproc)" download
make -j"$(nproc)"
```

The expected image name starts with
`immortalwrt-rockchip-armv8-hinlink_h28k-`.

## Validation

The patch set was validated on a 24-core Debian 11 build host against
ImmortalWrt commit `1cfeb3edade40fe2dfec59c21381de1d8e361100`.

- `make -j1 target/linux/compile V=s`: passed with Linux 6.12.94.
- `make -j24`: passed, including U-Boot 2025.10 and final image generation.
- Linux H28K DTB: generated successfully.
- U-Boot H28K DTB and `hinlink-h28k-rk3528-u-boot-rockchip.bin`: generated successfully.
- Firmware: `immortalwrt-rockchip-armv8-hinlink_h28k-squashfs-sysupgrade.img.gz`.

## Implementation notes

- Linux DTS support stays in `target/linux/rockchip/files`, matching
  ImmortalWrt's locally maintained MangoPi M28 device family.
- U-Boot DTS and defconfig files stay in `package/boot/uboot-rockchip/src`,
  while the target selection is registered in the package Makefile.
- The ADC boot button explicitly pulls in both `kmod-input-adc-keys` and
  ImmortalWrt's modular `kmod-saradc-rockchip` driver.
- The board uses `eth0` as LAN and `eth1` as WAN, matching the official DTS
  enumeration and OpenWrt board defaults.
