#!/usr/bin/env bash
set -euo pipefail

role="${1:-server}"
failures=0
warnings=0

pass() { printf 'PASS: %s\n' "$1"; }
warn() { printf 'WARN: %s\n' "$1"; warnings=$((warnings + 1)); }
fail() { printf 'FAIL: %s\n' "$1"; failures=$((failures + 1)); }

if [[ "$role" != "server" && "$role" != "agent" ]]; then
  printf 'Usage: %s [server|agent]\n' "$0" >&2
  exit 2
fi

if [[ "${EUID}" -ne 0 ]]; then
  fail "run this script as root so host checks are reliable"
else
  pass "running with root privileges"
fi

for command in awk findmnt getent grep ip lsmod mountpoint ss stat sysctl systemctl; do
  if command -v "$command" >/dev/null 2>&1; then
    pass "required command is available: $command"
  else
    fail "required command is missing: $command"
  fi
done

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  pass "operating system detected: ${PRETTY_NAME:-unknown}"
else
  fail "/etc/os-release is not readable"
fi

if [[ "$(sysctl -n net.ipv4.ip_forward 2>/dev/null || true)" == "1" ]]; then
  pass "IPv4 forwarding is enabled"
else
  fail "net.ipv4.ip_forward must be 1"
fi

for module in overlay br_netfilter; do
  if lsmod | awk '{print $1}' | grep -qx "$module"; then
    pass "kernel module is loaded: $module"
  else
    fail "kernel module is not loaded: $module"
  fi
done

if awk 'NR > 1 && $3 != "0" {found=1} END {exit !found}' /proc/swaps; then
  fail "swap is active; disable it unless the selected RKE2 version and policy explicitly support it"
else
  pass "swap is disabled"
fi

if getent group rke2-admins >/dev/null 2>&1; then
  pass "rke2-admins group exists"
else
  warn "create the rke2-admins group before using write-kubeconfig-group"
fi

if [[ -f /etc/rancher/rke2/token ]]; then
  token_mode="$(stat -c '%a' /etc/rancher/rke2/token)"
  if [[ "$token_mode" == "600" ]]; then
    pass "RKE2 token file permissions are 0600"
  else
    fail "RKE2 token file permissions are $token_mode; expected 600"
  fi
else
  warn "RKE2 token file does not exist yet"
fi

if [[ "$role" == "server" ]]; then
  if getent passwd etcd >/dev/null 2>&1 && getent group etcd >/dev/null 2>&1; then
    pass "etcd user and group exist for the CIS profile"
  else
    fail "create the system etcd user and group required by the RKE2 CIS profile"
  fi

  for port in 9345 6443 2379 2380; do
    if ss -H -lnt "sport = :$port" | grep -q .; then
      warn "TCP port $port is already listening; confirm this is an existing RKE2 component"
    else
      pass "TCP port $port is available"
    fi
  done
else
  if command -v iscsiadm >/dev/null 2>&1; then
    pass "open-iscsi client is installed for Longhorn"
  else
    fail "iscsiadm is missing; install and enable open-iscsi before Longhorn"
  fi

  if command -v mount.nfs >/dev/null 2>&1; then
    pass "NFS client utilities are installed for Longhorn RWX support"
  else
    warn "mount.nfs is missing; install NFS client utilities before using Longhorn RWX volumes"
  fi

  if mountpoint -q /var/lib/longhorn; then
    pass "/var/lib/longhorn is a dedicated mount point"
  else
    warn "/var/lib/longhorn is not a dedicated mount point; verify capacity and failure-domain design"
  fi
fi

printf '\nPreflight summary: %d failure(s), %d warning(s)\n' "$failures" "$warnings"
if ((failures > 0)); then
  exit 1
fi
