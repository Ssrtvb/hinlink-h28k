# HINLINK H28K 固件

本仓库用于每周自动编译 ImmortalWrt HINLINK H28K 固件（RK3528）。

> 本项目仅供个人使用与配置留档，不面向通用环境，也不提供技术支持；请自行评估适配性。

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
2. 使用对应正式版的官方 `config.buildinfo`。
3. 应用 HINLINK H28K 补丁。
4. 加载固件参数和额外 Git 软件包。
5. 编译完整固件并上传到 Artifacts 和 Releases。

## 构建配置

所有可调整的构建配置放在 `config/`：

| 文件 | 用途 |
| --- | --- |
| `firmware.conf` | 设置 LAN 地址、root 密码、默认主题和 ABI 校验开关。 |
| `packages.conf` | 每行一条完整的 `git clone` 命令。 |
| `hinlink-h28k.config` | H28K 目标、软件包和分区配置。 |

当前固件参数：

```conf
lan_ip=192.168.0.2
password=q
default_theme=fluent
check_official_abi=true
```

- `password` 使用明文填写，留空表示不修改 ImmortalWrt 默认密码状态。
- `default_theme` 填写 `luci-static` 下的主题目录名，例如 `fluent`，不要填写
  `luci-theme-fluent`；留空表示不修改默认主题。
- `check_official_abi=true` 表示校验内核 ABI 与官方固件一致，设为 `false` 时跳过校验。
- LAN、密码和默认主题会在编译阶段直接写入固件源码。

额外软件包直接写完整克隆命令，目标路径相对于 OpenWrt 源码根目录，不能以 `/` 开头：

```text
git clone --depth=1 -b main https://github.com/nikkinikki-org/OpenWrt-nikki.git package/OpenWrt-nikki
git clone --depth=1 https://github.com/LazuliKao/luci-theme-fluent.git package/luci-theme-fluent
```

该流程不会修改官方 `feeds.conf.default`，也不会添加自定义运行时软件源。

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
