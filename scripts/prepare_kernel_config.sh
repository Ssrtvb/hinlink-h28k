#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./config.sh
source "$SCRIPT_DIR/config.sh"

source_dir="${1:-}"
config_file="${2:-}"
release_version="${3:-}"
device_config="${4:-}"
[[ -n "$source_dir" && -n "$config_file" && -n "$release_version" && -n "$device_config" ]] ||
  fail "usage: $0 <source-dir> <firmware.conf> <release-version> <device-config>"
[[ -d "$source_dir" ]] || fail "source directory not found: $source_dir"
[[ -f "$config_file" ]] || fail "config file not found: $config_file"
[[ -f "$device_config" ]] || fail "device config not found: $device_config"

check_official_abi="$(read_config_value "$config_file" check_official_abi)"

cd "$source_dir"
case "$check_official_abi" in
  true)
    buildinfo_url="https://downloads.immortalwrt.org/releases/${release_version}/targets/rockchip/armv8"
    curl -fsSL "$buildinfo_url/config.buildinfo" -o .config.buildinfo
    awk '
      /^CONFIG_ALL_KMODS=y$/ ||
      /^CONFIG_DEVEL=y$/ ||
      (/^CONFIG_KERNEL_[A-Za-z0-9_]+=/ &&
        $0 !~ /^CONFIG_KERNEL_BUILD_(DOMAIN|USER)=/) ||
      /^# CONFIG_KERNEL_[A-Za-z0-9_]+ is not set$/
    ' .config.buildinfo > .config.official
    grep -q '^CONFIG_ALL_KMODS=y$' .config.official
    grep -q '^CONFIG_DEVEL=y$' .config.official
    cat .config.official "$device_config" > .config
    ;;
  false)
    echo "Official kernel config extraction skipped (ABI check disabled)"
    cp "$device_config" .config
    ;;
  *)
    fail "check_official_abi must be true or false: $check_official_abi"
    ;;
esac

make defconfig
