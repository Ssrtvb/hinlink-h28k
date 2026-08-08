#!/usr/bin/env bash

set -euo pipefail

fail() { echo "error: $*" >&2; exit 1; }

load_config() {
  local file="$1" key value octet
  lan_ip=""
  password=""
  default_theme=""
  check_official_abi=true
  while IFS='=' read -r key value || [[ -n "$key" ]]; do
    key="${key%$'\r'}"
    value="${value%$'\r'}"
    [[ -z "$key" ]] && continue
    case "$key" in
      lan_ip) lan_ip="$value" ;;
      password) password="$value" ;;
      default_theme) default_theme="$value" ;;
      check_official_abi) check_official_abi="$value" ;;
      *) fail "unknown config key: $key" ;;
    esac
  done < "$file"
  [[ -n "$lan_ip" ]] || fail "lan_ip is required"
  [[ "$lan_ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || fail "invalid lan_ip: $lan_ip"
  IFS=. read -r -a octets <<< "$lan_ip"
  for octet in "${octets[@]}"; do
    (( 10#$octet <= 255 )) || fail "invalid lan_ip: $lan_ip"
  done
  [[ -z "$default_theme" || "$default_theme" =~ ^[A-Za-z0-9_-]+$ ]] ||
    fail "invalid default_theme: $default_theme"
  [[ "$check_official_abi" == true || "$check_official_abi" == false ]] ||
    fail "check_official_abi must be true or false"
}

clone_packages() {
  local source_dir="$1" list="$2" line
  local -a command
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
    read -r -a command <<< "$line"
    [[ "${command[0]:-}" == git && "${command[1]:-}" == clone ]] ||
      fail "only git clone commands are allowed: $line"
    (cd "$source_dir" && "${command[@]}")
  done < "$list"
}

apply_device_config() {
  local source_dir="$1" shadow password_hash
  sed -i "s/192\.168\.1\.1/$lan_ip/g" \
    "$source_dir/package/base-files/files/bin/config_generate"

  if [[ -n "$default_theme" ]]; then
    sed -i "s|/luci-static/bootstrap|/luci-static/$default_theme|" \
      "$source_dir/feeds/luci/modules/luci-base/root/etc/config/luci"
  fi

  if [[ -n "$password" ]]; then
    shadow="$source_dir/package/base-files/files/etc/shadow"
    password_hash="$(printf '%s\n' "$password" | openssl passwd -6 -stdin)"
    sed -i "s|^root:[^:]*:|root:${password_hash}:|" "$shadow"
  fi
}

prepare() {
  local source_dir="$1" config="$2" packages="$3"
  load_config "$config"
  clone_packages "$source_dir" "$packages"
  apply_device_config "$source_dir"
}

assemble_config() {
  local source_dir="$1" official="$2" custom="$3" file line
  cat "$official" "$custom" > "$source_dir/.config"
  make -C "$source_dir" defconfig
  for file in "$official" "$custom"; do
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line%$'\r'}"
      [[ -z "$line" ]] || grep -Fqx -- "$line" "$source_dir/.config" ||
        fail "config option was not preserved: $line"
    done < "$file"
  done
}

check_abi() {
  local source_dir="$1" config="$2" version="$3" tag="$4" github_env="${5:-}"
  local vermagic built_abi official_kernel official_abi distfeeds
  load_config "$config"
  vermagic="$(find "$source_dir"/build_dir/target-* \
    -path '*/linux-rockchip_armv8/linux-*/.vermagic' -print -quit)"
  [[ -n "$vermagic" ]] || fail "kernel .vermagic was not found"
  built_abi="$(tr -d '[:space:]' < "$vermagic")"
  echo "release=$tag"
  echo "built_abi=$built_abi"

  if [[ "$check_official_abi" == true ]]; then
    official_kernel="$(curl -fsSL \
      "https://downloads.immortalwrt.org/releases/$version/targets/rockchip/armv8/packages/index.json" \
      | jq -r '.packages.kernel')"
    official_abi="$(sed -nE 's/.*~([0-9a-f]{32})-r[0-9]+/\1/p' <<< "$official_kernel")"
    [[ "$built_abi" == "$official_abi" ]] || fail "kernel ABI does not match official release"
    distfeeds="$(find "$source_dir/staging_dir" "$source_dir/build_dir" \
      -path '*/etc/apk/repositories.d/distfeeds.list' -print 2>/dev/null \
      | while read -r file; do
          grep -Eq "/targets/rockchip/armv8/kmods/[^/]+-${built_abi}/packages\\.adb$" "$file" && {
            echo "$file"
            break
          }
        done)"
    [[ -n "$distfeeds" ]] || fail "official kmods repository is missing"
    echo "official_abi=$official_abi"
  else
    echo 'official ABI check disabled'
  fi
  [[ -z "$github_env" ]] || echo "KERNEL_ABI=$built_abi" >> "$github_env"
}

case "${1:-}" in
  validate)
    load_config "$2"
    clone_count="$(grep -cve '^[[:space:]]*$' "$3" || true)"
    echo "lan_ip=$lan_ip password=$([[ -n "$password" ]] && echo set || echo unchanged) theme=${default_theme:-unchanged} abi=$check_official_abi git_packages=$clone_count"
    ;;
  prepare) prepare "$2" "$3" "$4" ;;
  assemble-config) assemble_config "$2" "$3" "$4" ;;
  check-abi) check_abi "$2" "$3" "$4" "$5" "${6:-}" ;;
  *) fail "unknown command: ${1:-}" ;;
esac
