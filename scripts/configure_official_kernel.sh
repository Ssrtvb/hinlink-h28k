#!/usr/bin/env bash

set -euo pipefail

fail() { echo "error: $*" >&2; exit 1; }

source_dir="${1:-}"
release_version="${2:-}"
release_series="${3:-}"
kernel_kmods="${4:-}"
kernel_abi="${kernel_kmods##*-}"
kernel_defaults="$source_dir/include/kernel-defaults.mk"
kmods_url="https://downloads.immortalwrt.org/releases/$release_version/targets/rockchip/armv8/kmods/$kernel_kmods"

[[ -d "$source_dir" ]] || fail "source directory not found: $source_dir"
[[ "$release_version" =~ ^(24\.10|25\.12)\.[0-9]+$ ]] || fail "invalid release version: $release_version"
[[ "$release_series" == 24.10 || "$release_series" == 25.12 ]] || fail "invalid release series: $release_series"
[[ "${release_version%.*}" == "$release_series" ]] || fail "release version and series do not match"
[[ "$kernel_kmods" =~ ^[0-9][0-9A-Za-z._-]*-[0-9a-f]{32}$ ]] || fail "invalid kmods directory: $kernel_kmods"
[[ -f "$kernel_defaults" ]] || fail "kernel defaults not found: $kernel_defaults"

sed -i -E \
  "s#^([[:space:]]*)grep '=[[]ym[]]'.*\.vermagic\$#\1echo '$kernel_abi' > \$(LINUX_DIR)/.vermagic#" \
  "$kernel_defaults"
grep -Fq "echo '$kernel_abi' > \$(LINUX_DIR)/.vermagic" "$kernel_defaults" ||
  fail "kernel ABI generation rule was not found"

case "$release_series" in
  24.10)
    feed_file="$source_dir/package/system/opkg/files/customfeeds.conf"
    feed_line="src/gz immortalwrt_kmods $kmods_url"
    ;;
  25.12)
    feed_file="$source_dir/package/system/apk/files/customfeeds.list"
    feed_line="$kmods_url/packages.adb"
    ;;
esac
[[ -f "$feed_file" ]] || fail "custom feeds file not found: $feed_file"
printf '\n%s\n' "$feed_line" >> "$feed_file"

echo "Forced kernel ABI: $kernel_abi"
echo "Added kmods feed: $feed_line"
