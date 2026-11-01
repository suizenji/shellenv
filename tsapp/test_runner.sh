#!/usr/bin/env bash
# Runs create-tsapp in a temp directory and checks the generated project.
# Usage: from tsapp/, ./test_runner.sh

set -euo pipefail

TSAPP="$(cd "$(dirname "$0")" && pwd)/create-tsapp"
ROOT="$(mktemp -d)"
trap 'rm -rf "$ROOT"' EXIT
printf "TEST ROOT: ${ROOT}\n"

run_create() {
  local dir=$1
  shift
  local log=$ROOT/create.log
  mkdir -p "$dir"
  if ! (cd "$dir" && "$TSAPP" "$@") >"$log" 2>&1; then
    echo "FAIL: create $*"
    cat "$log"
    exit 1
  fi
  if ! grep -q 'happy hacking!' "$log"; then
    echo "FAIL: missing happy hacking: $*"
    cat "$log"
    exit 1
  fi
}

run_create "$ROOT/plain"
run_create "$ROOT/with-src" --with-src proj

log=$ROOT/type-error.log
printf "\nconst n: number = 'no';\n" >> "$ROOT/plain/app/index.ts"
if (cd "$ROOT/plain/app" && npx tsc --noEmit && npx tsx ./index.ts) >"$log" 2>&1; then
  echo "FAIL: type error did not stop the dev command"
  cat "$log"
  exit 1
fi
if grep -q 'happy hacking!' "$log"; then
  echo "FAIL: tsx ran after a type error"
  cat "$log"
  exit 1
fi

echo ok
