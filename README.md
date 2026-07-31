<div align="center">

<img src="https://img.shields.io/badge/ImmortalWrt-25.12-blue?style=for-the-badge&logo=openwrt" alt="ImmortalWrt">
<img src="https://img.shields.io/badge/SoC-RK3528-orange?style=for-the-badge&logo=arm" alt="RK3528">
<img src="https://img.shields.io/badge/Arch-ARMv8--aarch64-green?style=for-the-badge" alt="ARMv8">

# H28K

**基于 ImmortalWrt 的 H28K (RK3528) 每日自动编译固件**

[![每日编译](https://github.com/Ssrtvb/immortalwrt-h28k/actions/workflows/build.yml/badge.svg)](https://github.com/Ssrtvb/immortalwrt-h28k/actions/workflows/build.yml)
[![Latest Release](https://img.shields.io/github/v/release/Ssrtvb/immortalwrt-h28k?label=最新固件&color=brightgreen)](https://github.com/Ssrtvb/immortalwrt-h28k/releases/latest)
[![下载量](https://img.shields.io/github/downloads/Ssrtvb/immortalwrt-h28k/total?color=blue&label=总下载量)](https://github.com/Ssrtvb/immortalwrt-h28k/releases/latest)

[📥 下载固件](https://github.com/Ssrtvb/immortalwrt-h28k/releases/latest) · [🐛 提交问题](https://github.com/Ssrtvb/immortalwrt-h28k/issues) · [📖 ImmortalWrt 官方](https://immortalwrt.org)

</div>

---

> **声明：本项目仅供个人使用，不对外提供任何形式的技术支持或服务。**

## 📋 设备信息

| 项目 | 说明 |
|------|------|
| **设备型号** | H28K |
| **处理器** | 瑞芯微 RK3528 (四核 Cortex-A53) |
| **架构** | ARMv8 / AArch64 |
| **固件格式** | squashfs-sysupgrade |
| **上游分支** | [immortalwrt/openwrt-25.12](https://github.com/immortalwrt/immortalwrt/tree/openwrt-25.12) |

## 📦 默认配置

- 默认 IP：`192.168.1.1`
- 默认密码：无（首次登录请设置）
- 管理界面：LuCI (HTTP/HTTPS)
- 包管理器：apk
- 内置 nikki 代理插件

## 🔄 自动更新

本仓库每日自动编译，始终跟踪上游最新代码。编译成功后固件会自动上传到 [Releases](https://github.com/Ssrtvb/immortalwrt-h28k/releases/latest)。

## 🙏 致谢

- [ImmortalWrt](https://github.com/immortalwrt/immortalwrt) — 上游项目
- [OpenWrt](https://openwrt.org) — 基础框架
- [nikki](https://github.com/nikkinikki-org/OpenWrt-nikki) — 代理插件

---

<div align="center">

**本项目仅供个人使用**

</div>
