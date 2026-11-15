#!/usr/bin/env bash

# Exercise the real config parser and kernel preparation without network or builds.
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TEST_DIR"' EXIT

curl() {
  printf '%s\n' "$2" >> "$FETCH_LOG"
  if [[ "$2" != "https://downloads.immortalwrt.org/releases/$EXPECTED_VERSION/targets/rockchip/armv8/config.buildinfo" ]]; then
    printf 'FAIL: expected release %s, requested %s\n' "$EXPECTED_VERSION" "$2" >&2
    return 22
  fi
  cat > "$4" <<'EOF'
CONFIG_ALL_KMODS=y
CONFIG_DEVEL=y
CONFIG_KERNEL_TEST=y
CONFIG_KERNEL_BUILD_USER="builder"
EOF
}

make() {
  [[ "$*" == defconfig ]]
  touch defconfig.called
}
export -f curl make

run_case() {
  local requested="$1" resolved="$2" series="$3" abi="${4:-true}"
  local case_dir="$TEST_DIR/$requested-$abi"
  mkdir -p "$case_dir/source/include"
  cat > "$case_dir/firmware.conf" <<EOF
release_version=$requested
lan_ip=192.168.0.2
password=test
check_official_abi=$abi
EOF
  printf 'CONFIG_TARGET_rockchip=y\n' > "$case_dir/device.config"
  printf '\tgrep . .config.set | LC_ALL=C sort > .vermagic\n' > "$case_dir/source/include/kernel-defaults.mk"
  export EXPECTED_VERSION="$resolved" FETCH_LOG="$case_dir/fetch.log"
  "$BASH" "$REPO_DIR/scripts/prepare_kernel_config.sh" \
    "$case_dir/source" "$case_dir/firmware.conf" "$resolved" "$series" "$case_dir/device.config"
  [[ -f "$case_dir/source/defconfig.called" ]]
  if [[ "$abi" == true ]]; then
    [[ "$(wc -l < "$FETCH_LOG")" -eq 1 ]]
    grep -qx 'CONFIG_KERNEL_TEST=y' "$case_dir/source/.config"
    ! grep -q CONFIG_KERNEL_BUILD_USER "$case_dir/source/.config"
    if [[ "$series" == 24.10 ]]; then
      grep -Fq "grep -v '^CONFIG_CLK_RK3528=y'" "$case_dir/source/include/kernel-defaults.mk"
    fi
  else
    [[ ! -e "$FETCH_LOG" ]]
    cmp "$case_dir/device.config" "$case_dir/source/.config"
  fi
  printf 'PASS: %s -> %s (official ABI: %s)\n' "$requested" "$resolved" "$abi"
}

run_case 25.12 25.12.2 25.12
run_case 25.12.1 25.12.1 25.12
run_case v25.12.1 25.12.1 25.12
run_case 24.10 24.10.6 24.10
run_case 24.10.6 24.10.6 24.10
run_case 25.12 25.12.2 25.12 false
