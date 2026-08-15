# HINLINK H28K ImmortalWrt 固件

本仓库用于自动编译 HINLINK H28K（Rockchip RK3528）固件。项目只保存编译配置、构建脚本和板级补丁，不包含 ImmortalWrt 上游源码。

> 仅供个人使用和配置留档，请自行确认硬件适配性。

## 支持版本

| ImmortalWrt 系列 | 补丁目录 | 内容 |
| --- | --- | --- |
| 24.10.x | `patches/24.10/` | 3 个 RK3528 基础回移补丁 + 5 个 H28K 板级补丁 |
| 25.12.x | `patches/25.12/` | 5 个 H28K 板级补丁 |

补丁只会应用所选版本目录中的 `*.patch` 文件，并按文件名字典序执行。补丁文件名前的编号就是应用顺序。

## 版本配置

编辑 [config/firmware.conf](config/firmware.conf) 中的 `release_version`。填写系列号会自动选择该系列最新正式版：

```ini
# 自动选择最新 24.10.x
release_version=24.10
```

填写完整版本号则固定构建指定版本：

```ini
release_version=24.10.6
```

同一文件还控制 LAN 地址、root 密码和默认 LuCI 主题：

```ini
lan_ip=192.168.0.2
password=your-password
default_theme=fluent
```

构建时使用 H28K 内核配置，并将内核 ABI 固定为所选版本的官方 ABI；不会提取官方内核配置或执行构建后 ABI 比对。
该操作只覆盖 ABI 标识，不验证官方 kmod 与回移内核的二进制兼容性。

`config/packages.conf` 每行定义一个额外的 `git clone` 软件包；`config/hinlink-h28k.config` 保存目标、软件包和分区配置。

## 构建脚本

| 脚本 | 职责 |
| --- | --- |
| `scripts/config.sh` | 共享配置读取和校验 |
| `scripts/install_dependencies.sh` | 安装编译依赖 |
| `scripts/select_release.sh` | 选择 ImmortalWrt 精确版本或系列最新版 |
| `scripts/apply_patches.sh` | 应用版本目录中的补丁 |
| `scripts/prepare_kernel_config.sh` | 使用 H28K 配置生成 `.config` |
| `scripts/force_kernel_abi.sh` | 将内核 ABI 固定为官方值 |
| `scripts/build_config.sh` | 注入固件参数并克隆额外软件包 |

## 默认组件

- `luci-theme-fluent`
- `luci-app-nikki`
- `kmod-mt7921u`
- `openssh-sftp-server`

## 设备信息

- 型号：HINLINK H28K
- SoC：Rockchip RK3528
- 架构：ARMv8 / AArch64
- LAN：`eth0`
- WAN：`eth1`
- 固件设备名：`hinlink_h28k`
