#!/usr/bin/env bash
# <TOOL NAME> – <one line: what it sets up>
# Guide: https://vrealmatic.com/<url>   (CS: https://vrealmatic.com/<cs-url>)
# Source: https://github.com/Vrealmatic/tools/tree/main/<platform>/<tool>
#
# Usage: sudo bash install.sh --check | --dry-run | --apply [options]
# Exit codes: 0 ok, 1 error, 2 usage, 3 unsupported system, 10 check: not in target state.

set -Eeuo pipefail

readonly SCRIPT_VERSION="0.0.0"
readonly SUPPORTED_UBUNTU=("22.04" "24.04" "26.04")

# ---------- common helpers (copied from _template, keep in sync) ----------

MODE=""
log()  { printf '[%s] %s\n' "$1" "$2" >&2; }
die()  { log error "$1"; exit "${2:-1}"; }
trap 'die "failed at line $LINENO: $BASH_COMMAND"' ERR

# Run a command, or only print it in --dry-run.
run() {
  if [[ $MODE == apply ]]; then log apply "$*"; "$@"; else log plan "$*"; fi
}

require_root() { [[ $EUID -eq 0 ]] || die "run as root (sudo)" 2; }

require_ubuntu() {
  [[ -r /etc/os-release ]] || die "cannot read /etc/os-release" 3
  # shellcheck disable=SC1091
  . /etc/os-release
  [[ ${ID:-} == ubuntu ]] || die "not Ubuntu (ID=${ID:-unknown})" 3
  local v
  for v in "${SUPPORTED_UBUNTU[@]}"; do [[ ${VERSION_ID:-} == "$v" ]] && return 0; done
  die "Ubuntu ${VERSION_ID:-?} is not supported (supported: ${SUPPORTED_UBUNTU[*]})" 3
}

# Write $2 into file $1 only if the content differs; back up the old file first.
write_file() {
  local path=$1 content=$2 mode=${3:-0644}
  if [[ -f $path ]] && [[ $(cat "$path") == "$content" ]]; then
    log ok "$path unchanged"; return 0
  fi
  if [[ $MODE != apply ]]; then log plan "write $path"; return 0; fi
  if [[ -f $path ]]; then cp -a "$path" "$path.bak.$(date +%Y%m%d%H%M%S)"; fi
  install -D -m "$mode" /dev/null "$path"
  printf '%s\n' "$content" > "$path"
  log apply "wrote $path"
}

usage() {
  cat <<EOF
Usage: sudo bash $0 --check | --dry-run | --apply [options]

  --check     report current state, change nothing (exit 0 = done, 10 = not yet)
  --dry-run   print planned changes, change nothing
  --apply     make the changes
  -h, --help  this help

Options:
  (none yet)
EOF
}

# ---------- arguments ----------

while [[ $# -gt 0 ]]; do
  case $1 in
    --check) MODE=check ;;
    --dry-run) MODE=dry-run ;;
    --apply) MODE=apply ;;
    -h|--help) usage; exit 0 ;;
    *) usage; die "unknown argument: $1" 2 ;;
  esac
  shift
done
[[ -n $MODE ]] || { usage; exit 2; }

# ---------- tool logic ----------

is_done() {
  # Return 0 when the system is already in the target state.
  return 1
}

main() {
  require_root
  require_ubuntu
  log check "<tool> v$SCRIPT_VERSION on Ubuntu $VERSION_ID ($(dpkg --print-architecture))"

  if [[ $MODE == check ]]; then
    if is_done; then log ok "target state reached"; exit 0; fi
    log warn "not in target state"; exit 10
  fi

  # Steps: each one checks first, then calls run/write_file.
  # run apt-get update
  # write_file /etc/example.d/10-vrealmatic.conf "key=value"

  log ok "done ($MODE)"
}

main
