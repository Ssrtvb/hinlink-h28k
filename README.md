# HINLINK H28K 固件

本仓库用于每周自动编译 ImmortalWrt HINLINK H28K 固件（RK3528）。

> 本项目仅供个人使用与配置留档，不面向通用环境，也不提供技术支持；请自行评估适配性。

## 补丁说明

补丁按 ImmortalWrt 版本系列存放在 `patches/` 下：

- `patches/25.12/`：ImmortalWrt 25.12.x H28K 板级补丁集。
- `patches/24.10/`：ImmortalWrt 24.10.x 完整补丁集，包含 RK3528 基础回移和 H28K 板级补丁。

工作流只会应用所选版本系列目录中的 `*.patch` 文件，并按文件名的字典序
依次执行。不同版本系列的补丁不要混放。

| 补丁 | 说明 |
| --- | --- |
| `patches/25.12/0010-rockchip-add-HINLINK-H28K-U-Boot-support.patch` | 添加 U-Boot 目标、H28K DTS、U-Boot DTSI 和 defconfig。 |
| `patches/25.12/0020-rockchip-add-HINLINK-H28K-device-tree.patch` | 添加 Linux H28K 设备树和系统 LED 别名。 |
| `patches/25.12/0030-rockchip-add-HINLINK-H28K-board-defaults.patch` | 添加 LED 默认值、LAN/WAN 分配、MAC 地址生成和 IRQ affinity。 |
| `patches/25.12/0040-rockchip-add-HINLINK-H28K-image.patch` | 添加 `hinlink_h28k` 固件设备配置。 |
| `patches/25.12/0050-rockchip-configure-HINLINK-H28K-RJ45-LEDs.patch` | 配置两个 RJ45 接口的链路灯和活动灯。 |

24.10.x 目录另外包含 `0001`–`0003` 三个 RK3528 基础回移补丁；这些补丁只对
24.10.x 应用，25.12.x 不需要。

## 自动编译

GitHub Actions 每周自动运行一次，也可以在 Actions 页面手动触发。版本由
`config/firmware.conf` 中的 `release_version` 控制：填写精确版本号（例如
`24.10.6`、`25.12.1`）时构建该版本；留空时构建 `25.12.x` 最新正式版，并自动
选择对应的补丁目录。每次构建会：

1. 选择指定的 `vX.Y.Z` 标签，或使用 `25.12.x` 系列中的最新正式版。
2. 使用对应正式版的官方 `config.buildinfo`。
3. 应用对应版本目录中的 HINLINK H28K 补丁。
4. 加载固件参数和额外 Git 软件包。
5. 编译完整固件并上传到 Artifacts 和 Releases。

## 构建配置

所有可调整的构建配置放在 `config/`：

| 文件 | 用途 |
| --- | --- |
| `firmware.conf` | 设置 ImmortalWrt 版本、LAN 地址、root 密码、默认主题和 ABI 校验开关。 |
| `packages.conf` | 每行一条完整的 `git clone` 命令。 |
| `hinlink-h28k.config` | H28K 目标、软件包和分区配置。 |

将 `firmware.conf` 中的 `check_official_abi` 设为 `false` 时，工作流会跳过官方
`config.buildinfo` 的提取和 ABI/kmod 校验，但仍会使用 H28K 配置生成最终 `.config`。

## 构建脚本

- `scripts/config.sh`：共享配置读取和校验。
- `scripts/select_release.sh`：读取版本配置并选择 ImmortalWrt 标签。
- `scripts/apply_patches.sh`：按版本目录应用补丁。
- `scripts/prepare_kernel_config.sh`：准备官方或本地内核配置。
- `scripts/build_config.sh`：注入固件参数、克隆额外软件包并检查内核 ABI。

## 默认包含

- Fluent LuCI 主题：`luci-theme-fluent`
- Nikki：`luci-app-nikki`
- MT7921U USB 无线网卡驱动：`kmod-mt7921u`
- OpenSSH SFTP 服务：`openssh-sftp-server`

## 设备信息

- 型号：HINLINK H28K
- SoC：Rockchip RK3528
- 架构：ARMv8 / AArch64
- LAN：`eth0`
- WAN：`eth1`
- 固件设备名：`hinlink_h28k`
