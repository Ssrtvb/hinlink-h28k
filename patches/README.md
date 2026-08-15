# 版本化补丁目录

补丁按 ImmortalWrt 的版本系列分目录存放：

- `24.10/`：ImmortalWrt 24.10.x 完整补丁集，包含 RK3528 基础回移和 H28K 板级补丁。
- `25.12/`：ImmortalWrt 25.12.x H28K 板级补丁集。

每个目录中的 `*.patch` 文件会按文件名字典序依次应用。不要把不同版本
系列的补丁混放，否则可能出现补丁无法应用或生成错误固件的情况。

各版本目录中的 `series`、`TAG_COMPATIBILITY.md`、`SOURCE_NOTES.md` 和
`patches.sha256` 用于记录补丁顺序、兼容性和校验信息。
