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

编辑 [config/firmware.conf](config/firmware.conf) 中的 `release_version`：

```ini
# 精确构建指定版本
release_version=24.10.6
```

留空时，工作流会自动选择 `25.12.x` 系列最新正式版：

```ini
release_version=
```

同一文件还控制 LAN 地址、root 密码、默认 LuCI 主题和内核 ABI 校验：

```ini
lan_ip=192.168.0.2
password=your-password
default_theme=fluent
check_official_abi=true
```

将 `check_official_abi` 设为 `false` 时，会跳过官方 `config.buildinfo` 提取和 ABI/kmod 校验，但仍使用 H28K 配置生成 `.config`。

`config/packages.conf` 每行定义一个额外的 `git clone` 软件包；`config/hinlink-h28k.config` 保存目标、软件包和分区配置。

> `password` 会在编译时写入固件，请勿在公开仓库中使用真实生产密码。

## GitHub Actions

- `build.yml`：GitHub-hosted runner 每周自动构建，也支持手动触发。
- `build-local.yml`：在带有 `h28k-builder` 标签的自托管 runner 上手动构建。

两条工作流都会：选择版本 → 应用对应补丁 → 更新 feeds → 准备内核配置 → 编译固件 → 校验 ABI（如启用）→ 上传 Artifact 和 Release。

手动触发时只需要选择是否使用源码缓存；构建版本由 `config/firmware.conf` 控制。

## 构建脚本

| 脚本 | 职责 |
| --- | --- |
| `scripts/config.sh` | 共享配置读取和校验 |
| `scripts/select_release.sh` | 选择 ImmortalWrt 精确版本或系列最新版 |
| `scripts/apply_patches.sh` | 应用版本目录中的补丁 |
| `scripts/prepare_kernel_config.sh` | 按 ABI 开关准备 `.config` |
| `scripts/build_config.sh` | 注入固件参数、克隆软件包和检查 ABI |

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
