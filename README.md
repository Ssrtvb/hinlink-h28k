# HINLINK H28K 固件

本仓库用于每周自动编译 ImmortalWrt HINLINK H28K 固件（RK3528）。

## 补丁说明

| 补丁 | 说明 |
| --- | --- |
| `0010-rockchip-add-HINLINK-H28K-U-Boot-support.patch` | 添加 U-Boot 目标、H28K DTS、U-Boot DTSI 和 defconfig。 |
| `0020-rockchip-add-HINLINK-H28K-device-tree.patch` | 添加 Linux H28K 设备树和系统 LED 别名。 |
| `0030-rockchip-add-HINLINK-H28K-board-defaults.patch` | 添加 LED 默认值、LAN/WAN 分配、MAC 地址生成和 IRQ affinity。 |
| `0040-rockchip-add-HINLINK-H28K-image.patch` | 添加 `hinlink_h28k` 固件设备配置。 |
| `0050-rockchip-configure-HINLINK-H28K-RJ45-LEDs.patch` | 配置两个 RJ45 接口的链路灯和活动灯。 |

## 自动编译

GitHub Actions 每周自动运行一次，也可以在 Actions 页面手动触发。每次构建会：

1. 自动选择 ImmortalWrt 最新正式版 `vX.Y.Z` 标签。
2. 使用对应版本的 `feeds.buildinfo` 和 `config.buildinfo`。
3. 应用 HINLINK H28K 补丁。
4. 编译完整固件并上传到 Artifacts 和 Releases。

## 手动应用补丁

先准备 ImmortalWrt 正式版源码，再按顺序应用补丁：

```sh
git clone --branch v25.12.1 --single-branch \
  https://github.com/immortalwrt/immortalwrt.git source
cd source

for patch in /path/to/hinlink-h28k/patches/*.patch; do
  git apply --check "$patch"
  git apply "$patch"
done
```

使用仓库提供的最小配置：

```sh
cp /path/to/hinlink-h28k/.github/configs/hinlink-h28k.config .config
make defconfig
make -j"$(nproc)" download
make -j"$(nproc)"
```

`make defconfig` 会根据官方配置自动补齐软件包和内核模块依赖。

## 设备信息

- 型号：HINLINK H28K
- SoC：Rockchip RK3528
- 架构：ARMv8 / AArch64
- LAN：`eth0`
- WAN：`eth1`
- 固件设备名：`hinlink_h28k`
