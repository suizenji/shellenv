#!/bin/sh
# Test runner for detach. Uses temporary HOME to isolate ~/.detach.
# Usage: run from detach/ directory: ./test_runner.sh

set -e
DETACH_DIR="$(cd "$(dirname "$0")" && pwd)"
DETACH="$DETACH_DIR/detach"

# Use temporary HOME so we don't touch real ~/.detach
export HOME="${TMPDIR:-/tmp}/detach-test-$$"
mkdir -p "$HOME"
cleanup() { rm -rf "$HOME"; }
trap cleanup EXIT

run_ok() {
  if "$@"; then return 0; else return 1; fi
}
run_fail() {
  if "$@" 2>/dev/null; then return 1; else return 0; fi
}
assert_exit() {
  want=$1; shift
  if "$@"; then got=0; else got=1; fi
  if [ "$got" -eq "$want" ]; then return 0; fi
  echo "FAIL: exit code $got (expected $want): $*"
  return 1
}
assert_file_exists() {
  [ -e "$1" ] || { echo "FAIL: expected file to exist: $1"; return 1; }
}
assert_file_missing() {
  [ ! -e "$1" ] || { echo "FAIL: expected file to not exist: $1"; return 1; }
}
assert_stdout_contains() {
  out=$(cat)
  if echo "$out" | grep -q "$1"; then return 0; fi
  echo "FAIL: output should contain '$1'"
  echo "output: $out"
  return 1
}

passed=0 failed=0
test_case() {
  name="$1"
  if ( shift; "$@" ); then
    passed=$((passed + 1))
    echo "  OK: $name"
  else
    failed=$((failed + 1))
    echo "  FAIL: $name"
  fi
}

echo "=== detach test suite ==="
echo "HOME=$HOME"
echo ""

# --- help ---
echo "--- help ---"
test_case "help shows subcommands" "$DETACH" help 2>&1 | assert_stdout_contains "ls:"
test_case "help shows detach" "$DETACH" help 2>&1 | assert_stdout_contains "detach:"
test_case "-h shows help" "$DETACH" -h 2>&1 | assert_stdout_contains "pop:"

# --- detach (default subcommand) ---
echo ""
echo "--- detach (move files to stash) ---"
mkdir -p "$HOME/work"
touch "$HOME/work/f1"
touch "$HOME/work/f2"

test_case "detach one file" assert_exit 0 "$DETACH" "$HOME/work/f1"
test_case "file is gone from origin" assert_file_missing "$HOME/work/f1"
test_case "file exists under .detach" assert_file_exists "$HOME/.detach/1"

test_case "detach second file" assert_exit 0 "$DETACH" "$HOME/work/f2"
test_case "second file under .detach" assert_file_exists "$HOME/.detach/2"
test_case "config has two entries" [ "$(wc -l < "$HOME/.detach/config.list")" -ge 1 ]

# --- ls ---
echo ""
echo "--- ls ---"
ls_out=$("$DETACH" ls)
test_case "ls lists entries" echo "$ls_out" | assert_stdout_contains "1"
test_case "ls shows original path" echo "$ls_out" | grep -q "work/f1" || echo "$ls_out" | grep -q "work/f2"
test_case "ls with no args succeeds" assert_exit 0 "$DETACH" ls

# --- pop ---
echo ""
echo "--- pop ---"
test_case "pop restores last (default)" assert_exit 0 "$DETACH" pop
test_case "f2 restored" assert_file_exists "$HOME/work/f2"
test_case "pop restores by id" assert_exit 0 "$DETACH" pop 1
test_case "f1 restored" assert_file_exists "$HOME/work/f1"

# --- pop empty / errors ---
echo ""
echo "--- pop error cases ---"
test_case "pop on empty stash fails" assert_exit 1 "$DETACH" pop
touch "$HOME/work/dummy"
"$DETACH" "$HOME/work/dummy" >/dev/null 2>&1
test_case "pop invalid id prints error" "$DETACH" pop 999 2>&1 | grep -q "not found"
"$DETACH" clear >/dev/null 2>&1

# --- clear ---
echo ""
echo "--- clear ---"
touch "$HOME/work/c1"
"$DETACH" "$HOME/work/c1" >/dev/null 2>&1
test_case "clear removes one" assert_exit 0 "$DETACH" clear
test_case "cleared file is gone" assert_file_missing "$HOME/.detach/3"
test_case "c1 not restored" assert_file_missing "$HOME/work/c1"

# --- clear -a ---
touch "$HOME/work/d1"
touch "$HOME/work/d2"
"$DETACH" "$HOME/work/d1" "$HOME/work/d2" >/dev/null 2>&1
test_case "clear -a removes all" assert_exit 0 "$DETACH" clear -a
test_case "stash is empty after clear -a" [ -z "$("$DETACH" ls 2>/dev/null)" ]

# --- default subcommand (no args = detach) ---
echo ""
echo "--- default subcommand ---"
touch "$HOME/work/def"
test_case "no subcommand means detach" assert_exit 0 "$DETACH" "$HOME/work/def"
test_case "file detached by default" assert_file_missing "$HOME/work/def"
"$DETACH" clear -a >/dev/null 2>&1 || true

echo ""
echo "=== result: $passed passed, $failed failed ==="
[ "$failed" -eq 0 ]
