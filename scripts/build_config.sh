#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./config.sh
source "$SCRIPT_DIR/config.sh"

clone_extra_packages() {
  local source_dir="$1" list="$2" line
  local -a command
  [[ -d "$source_dir" ]] || fail "source directory not found: $source_dir"
  [[ -f "$list" ]] || fail "package list not found: $list"

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    [[ "$line" =~ ^[[:space:]]*(#|$) ]] && continue
    read -r -a command <<< "$line"
    [[ "${command[0]:-}" == git && "${command[1]:-}" == clone ]] ||
      fail "only git clone commands are allowed: $line"
    (cd "$source_dir" && "${command[@]}")
  done < "$list"
}

apply_device_config() {
  local source_dir="$1" lan_ip_value="$2" password_value="$3" theme="$4"
  local shadow password_hash

  sed -i "s/192\.168\.1\.1/$lan_ip_value/g" \
    "$source_dir/package/base-files/files/bin/config_generate"

  if [[ -n "$theme" ]]; then
    sed -i "s|/luci-static/bootstrap|/luci-static/$theme|" \
      "$source_dir/feeds/luci/modules/luci-base/root/etc/config/luci"
  fi

  shadow="$source_dir/package/base-files/files/etc/shadow"
  password_hash="$(printf '%s\n' "$password_value" | openssl passwd -6 -stdin)"
  sed -i "s|^root:[^:]*:|root:${password_hash}:|" "$shadow"
}

enable_official_kmods() {
  local source_dir="$1"
  sed -i 's/CONFIG_BUILDBOT/CONFIG_ALL_KMODS/g' \
    "$source_dir/include/feeds.mk"
  test "$(grep -c 'CONFIG_ALL_KMODS' "$source_dir/include/feeds.mk")" -eq 2
}

prepare() {
  local source_dir="$1" config_file="$2" packages_file="$3"
  [[ -d "$source_dir" ]] || fail "source directory not found: $source_dir"
  load_firmware_config "$config_file"
  clone_extra_packages "$source_dir" "$packages_file"
  apply_device_config "$source_dir" "$lan_ip" "$password" "$default_theme"
  [[ "$check_official_abi" == true ]] && enable_official_kmods "$source_dir"
}

read_built_abi() {
  local source_dir="$1" vermagic
  vermagic="$(find "$source_dir"/build_dir/target-* \
    -path '*/linux-rockchip_armv8/linux-*/.vermagic' -print -quit)"
  [[ -n "$vermagic" ]] || fail "kernel .vermagic was not found"
  tr -d '[:space:]' < "$vermagic"
}

check_official_abi() {
  local source_dir="$1" version="$2" built_abi="$3"
  local official_kernel official_abi distfeeds

  official_kernel="$(curl -fsSL \
    "https://downloads.immortalwrt.org/releases/$version/targets/rockchip/armv8/packages/index.json" \
    | jq -r '.packages.kernel')"
  official_abi="$(sed -nE 's/.*~([0-9a-f]{32})-r[0-9]+/\1/p' <<< "$official_kernel")"
  [[ "$built_abi" == "$official_abi" ]] ||
    fail "kernel ABI does not match official release"

  distfeeds="$(find "$source_dir/staging_dir" "$source_dir/build_dir" \
    -path '*/etc/apk/repositories.d/distfeeds.list' -print 2>/dev/null \
    | while read -r file; do
        grep -Eq "/targets/rockchip/armv8/kmods/[^/]+-${built_abi}/packages\\.adb$" "$file" && {
          echo "$file"
          break
        }
      done)"
  [[ -n "$distfeeds" ]] || fail "official kmods repository is missing"
  echo "$official_abi"
}

write_github_env() {
  local github_env="$1" built_abi="$2"
  [[ -n "$github_env" ]] || return 0
  {
    echo "KERNEL_ABI=$built_abi"
    echo "FIRMWARE_LAN_IP=$lan_ip"
    echo "FIRMWARE_PASSWORD=$password"
  } >> "$github_env"
}

check_abi() {
  local source_dir="$1" config_file="$2" version="$3" tag="$4" github_env="${5:-}"
  local built_abi official_abi
  load_firmware_config "$config_file"

  built_abi="$(read_built_abi "$source_dir")"
  echo "release=$tag"
  echo "built_abi=$built_abi"

  if [[ "$check_official_abi" == true ]]; then
    official_abi="$(check_official_abi "$source_dir" "$version" "$built_abi")"
    echo "official_abi=$official_abi"
  else
    echo 'official ABI check disabled'
  fi
  write_github_env "$github_env" "$built_abi"
}

case "${1:-}" in
  prepare) prepare "$2" "$3" "$4" ;;
  check-abi) check_abi "$2" "$3" "$4" "$5" "${6:-}" ;;
  *) fail "unknown command: ${1:-}" ;;
esac
