# 来源与调整说明

- 原始五补丁来自 `Ssrtvb/hinlink-h28k` commit `9b6c3ba27a1dc39d72eba56a57b9aab652801663` 的 `patches/` 目录。
- ImmortalWrt 正式 tag 直接取自 `immortalwrt/immortalwrt`。
- `0010` 使用稳定的 RK3566 分组标题和 `nanopi-r3s-rk3566` 列表入口作为上下文。
- `0020` 是纯新增 Linux DTS，不依赖设备列表上下文。
- `0030` 使用 `esac` 及相邻稳定设备条目作为上下文。
- `0040` 使用 `Device/huake_guangmiao-g4c` 作为上下文。
- `0050` 使用 `boot()` 的函数尾作为上下文；PCIe PHY LED 的 `device_name` 参数与 25.12 官方同类设备一致，使用空字符串。
- 未加入邮件头、作者、Subject 或 Signed-off-by 等补丁元信息。
