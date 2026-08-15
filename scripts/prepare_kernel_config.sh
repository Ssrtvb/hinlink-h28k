#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./config.sh
source "$SCRIPT_DIR/config.sh"

source_dir="${1:-}"
device_config="${2:-}"
[[ -n "$source_dir" && -n "$device_config" ]] || fail "usage: $0 <source-dir> <device-config>"
[[ -d "$source_dir" ]] || fail "source directory not found: $source_dir"
[[ -f "$device_config" ]] || fail "device config not found: $device_config"

cd "$source_dir"
cp "$device_config" .config
make defconfig
