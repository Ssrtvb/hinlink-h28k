#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./config.sh
source "$SCRIPT_DIR/config.sh"

config_file="${1:-}"
github_output="${2:-}"
[[ -n "$config_file" && -n "$github_output" ]] ||
  fail "usage: $0 <firmware.conf> <github-output>"
upstream=https://github.com/immortalwrt/immortalwrt.git
load_firmware_config "$config_file"
requested_version="$release_version"

release_tag=""
if [[ -n "$requested_version" ]]; then
  release_version="${requested_version#v}"
  [[ "$release_version" =~ ^(24\.10|25\.12)\.[0-9]+$ ]] ||
    fail "unsupported exact release version: $requested_version"

  release_tag="v$release_version"
  release_series="${release_version%.*}"
  git ls-remote --exit-code --tags --refs "$upstream" "refs/tags/$release_tag" >/dev/null ||
    fail "upstream release tag not found: $release_tag"
  buildinfo="https://downloads.immortalwrt.org/releases/${release_version}/targets/rockchip/armv8/config.buildinfo"
  curl -fsSL -o /dev/null "$buildinfo" ||
    fail "official buildinfo not found: $buildinfo"
else
  release_series='25.12'
  release_prefix="v${release_series}."
  for tag in $(git ls-remote --tags --refs "$upstream" 'refs/tags/v*' \
    | awk -F/ -v prefix="$release_prefix" \
      '$3 ~ /^v[0-9]+\.[0-9]+\.[0-9]+$/ && index($3, prefix) == 1 { print $3 }' \
    | sort -Vr); do
    version="${tag#v}"
    buildinfo="https://downloads.immortalwrt.org/releases/${version}/targets/rockchip/armv8/config.buildinfo"
    if curl -fsSL -o /dev/null "$buildinfo"; then
      release_tag="$tag"
      release_version="$version"
      break
    fi
  done
  [[ -n "$release_tag" ]] || fail "no usable $release_series release was found"
fi

{
  echo "series=$release_series"
  echo "tag=$release_tag"
  echo "version=$release_version"
} >> "$github_output"

echo "Selected ImmortalWrt release: $release_tag (series $release_series)"
