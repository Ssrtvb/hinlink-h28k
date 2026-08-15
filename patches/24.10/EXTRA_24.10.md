# 相比 25.12 补丁多出的 24.10 必需内容

1. `0001`：24.10 没有 RK3528 rkbin/trusted-firmware 构建目标。
2. `0002`：24.10 的 U-Boot 2024.10 没有 RK3528 SoC 支持和 `U-Boot/rk3528/Default`。
3. `0003`：24.10 的 Linux 6.6 没有 RK3528 clock/reset、pinctrl、SARADC、GMAC、ComboPHY、PCIe、USB2 PHY、thermal、power-domain、基础 DTSI 和 `Device/rk3528`。
4. `0040` 中的 `DEVICE_DTS_DIR` 与 `KERNEL` 是 H28K 局部兼容项，用来保持 24.10 其他 Rockchip profile 的全局镜像规则不变。
5. `0050` 兼容 24.10.1 的旧 `led_set` API 和 24.10.2 之后的 `netled_set` API；通过运行时检测选择官方已有接口，不复制整份 LED 初始化脚本。

没有加入 generic RK3528 参考板、generic defconfig、MAINTAINERS、generic 文档、iStoreOS vendor DTS 或 legacy bootscript。

`v24.10.0` 没有官方 `etc/init.d/phy-leds` 文件，因此完整八补丁集不对该 tag 强行添加重复的基础脚本。
