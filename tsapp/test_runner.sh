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
run_create "$ROOT/no-git" --no-git nogit

assert_git() {
  local dir=$1
  if [ ! -d "$dir/.git" ]; then
    echo "FAIL: missing .git: $dir"
    exit 1
  fi
  if ! git -C "$dir" rev-parse --verify HEAD >/dev/null 2>&1; then
    echo "FAIL: missing initial commit: $dir"
    exit 1
  fi
}

assert_gitignore() {
  local dir=$1
  if ! grep -qx '/node_modules' "$dir/.gitignore" || ! grep -qx '/dist' "$dir/.gitignore"; then
    echo "FAIL: .gitignore: $dir"
    cat "$dir/.gitignore"
    exit 1
  fi
}

assert_git "$ROOT/plain/app"
assert_git "$ROOT/with-src/proj"
assert_gitignore "$ROOT/plain/app"
assert_gitignore "$ROOT/with-src/proj"
assert_gitignore "$ROOT/no-git/nogit"
if [ -d "$ROOT/no-git/nogit/.git" ]; then
  echo "FAIL: .git exists with --no-git"
  exit 1
fi

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
