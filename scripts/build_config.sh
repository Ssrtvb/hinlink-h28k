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

write_github_env() {
  local github_env="$1"
  [[ -n "$github_env" ]] || return 0
  {
    echo "FIRMWARE_LAN_IP=$lan_ip"
    echo "FIRMWARE_PASSWORD=$password"
  } >> "$github_env"
}

source_dir="${1:-}"
config_file="${2:-}"
packages_file="${3:-}"
github_env="${4:-}"
[[ -n "$source_dir" && -n "$config_file" && -n "$packages_file" ]] ||
  fail "usage: $0 <source-dir> <firmware.conf> <packages.conf> [github-env]"
[[ -d "$source_dir" ]] || fail "source directory not found: $source_dir"

load_firmware_config "$config_file"
clone_extra_packages "$source_dir" "$packages_file"
apply_device_config "$source_dir" "$lan_ip" "$password" "$default_theme"
write_github_env "$github_env"
