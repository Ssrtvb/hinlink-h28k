#!/usr/bin/env bash

set -euo pipefail

fail() { echo "error: $*" >&2; exit 1; }

source_dir="${1:-}"
release_version="${2:-}"
[[ -n "$source_dir" && -n "$release_version" ]] || fail "usage: $0 <source-dir> <release-version>"
[[ -d "$source_dir" ]] || fail "source directory not found: $source_dir"
[[ "$release_version" =~ ^(24\.10|25\.12)\.[0-9]+$ ]] || fail "invalid release version: $release_version"

curl -fsSL \
  "https://downloads.immortalwrt.org/releases/$release_version/targets/rockchip/armv8/feeds.buildinfo" \
  -o "$source_dir/feeds.conf.default"

cd "$source_dir"
./scripts/feeds update -a
./scripts/feeds install -a
