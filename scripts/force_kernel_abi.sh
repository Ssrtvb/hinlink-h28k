#!/usr/bin/env bash

set -euo pipefail

fail() { echo "error: $*" >&2; exit 1; }

source_dir="${1:-}"
kernel_abi="${2:-}"
kernel_defaults="$source_dir/include/kernel-defaults.mk"
[[ -d "$source_dir" ]] || fail "source directory not found: $source_dir"
[[ "$kernel_abi" =~ ^[0-9a-f]{32}$ ]] || fail "invalid kernel ABI: $kernel_abi"
[[ -f "$kernel_defaults" ]] || fail "kernel defaults not found: $kernel_defaults"

sed -i -E \
  "s#^([[:space:]]*)grep '=[[]ym[]]'.*\.vermagic\$#\1echo '$kernel_abi' > \$(LINUX_DIR)/.vermagic#" \
  "$kernel_defaults"
grep -Fq "echo '$kernel_abi' > \$(LINUX_DIR)/.vermagic" "$kernel_defaults" ||
  fail "kernel ABI generation rule was not found"

echo "Forced kernel ABI: $kernel_abi"
