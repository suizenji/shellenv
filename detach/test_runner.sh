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
test_case "pop (default 1) restores newest" assert_exit 0 "$DETACH" pop
test_case "f2 restored" assert_file_exists "$HOME/work/f2"
test_case "pop 1 restores one more" assert_exit 0 "$DETACH" pop 1
test_case "f1 restored" assert_file_exists "$HOME/work/f1"

# --- pop N (multiple) ---
touch "$HOME/work/p1"
touch "$HOME/work/p2"
touch "$HOME/work/p3"
"$DETACH" "$HOME/work/p1" "$HOME/work/p2" "$HOME/work/p3" >/dev/null 2>&1
test_case "pop 2 restores two newest" assert_exit 0 "$DETACH" pop 2
test_case "p2 p3 restored by pop 2" assert_file_exists "$HOME/work/p2" && assert_file_exists "$HOME/work/p3" && assert_file_missing "$HOME/work/p1"
test_case "pop 1 restores remaining" assert_exit 0 "$DETACH" pop 1
test_case "p1 restored" assert_file_exists "$HOME/work/p1"

# --- pop empty / errors ---
echo ""
echo "--- pop error cases ---"
test_case "pop on empty stash fails" assert_exit 1 "$DETACH" pop
touch "$HOME/work/dummy"
"$DETACH" "$HOME/work/dummy" >/dev/null 2>&1
test_case "pop 0 fails" assert_exit 1 "$DETACH" pop 0
test_case "pop negative fails" assert_exit 1 "$DETACH" pop -1
touch "$HOME/work/pd1"
touch "$HOME/work/pd2"
"$DETACH" "$HOME/work/pd1" "$HOME/work/pd2" >/dev/null 2>&1
test_case "pop -d 2 deletes without restoring" assert_exit 0 "$DETACH" pop -d 2
test_case "pd1 pd2 not restored after pop -d" assert_file_missing "$HOME/work/pd1" && assert_file_missing "$HOME/work/pd2"
test_case "stash empty after pop -d 2" ! "$DETACH" ls 2>/dev/null | grep -q .
"$DETACH" clear >/dev/null 2>&1

# --- get ---
echo ""
echo "--- get ---"
touch "$HOME/work/g1"
touch "$HOME/work/g2"
"$DETACH" "$HOME/work/g1" "$HOME/work/g2" >/dev/null 2>&1
test_case "get requires at least one id" assert_exit 1 "$DETACH" get
test_case "get restores by id" assert_exit 0 "$DETACH" get 2
test_case "g2 restored by get" assert_file_exists "$HOME/work/g2"
test_case "get restores multiple ids" assert_exit 0 "$DETACH" get 1
test_case "g1 restored by get" assert_file_exists "$HOME/work/g1"
test_case "get multiple in one call" assert_exit 0 "$DETACH" "$HOME/work/g1" "$HOME/work/g2" && "$DETACH" get 2 1
test_case "both restored by get 2 1" assert_file_exists "$HOME/work/g1" && assert_file_exists "$HOME/work/g2"
"$DETACH" clear -a >/dev/null 2>&1 || true

# --- get -c (copy, keep in stash) ---
touch "$HOME/work/gc1"
"$DETACH" "$HOME/work/gc1" >/dev/null 2>&1
test_case "get -c copies to org" assert_exit 0 "$DETACH" get -c 1
test_case "gc1 exists after get -c" assert_file_exists "$HOME/work/gc1"
test_case "get -c keeps entry in stash" [ "$("$DETACH" ls 2>/dev/null | wc -l)" -eq 1 ]
"$DETACH" clear -a >/dev/null 2>&1 || true

# --- pop -c (copy, keep in stash) ---
touch "$HOME/work/pc1"
touch "$HOME/work/pc2"
"$DETACH" "$HOME/work/pc1" "$HOME/work/pc2" >/dev/null 2>&1
test_case "pop -c 1 copies one to org" assert_exit 0 "$DETACH" pop -c 1
test_case "pc2 exists after pop -c 1" assert_file_exists "$HOME/work/pc2"
test_case "pop -c keeps entries in stash" [ "$("$DETACH" ls 2>/dev/null | wc -l)" -eq 2 ]
"$DETACH" clear -a >/dev/null 2>&1 || true

# --- clear ---
echo ""
echo "--- clear ---"
touch "$HOME/work/c1"
"$DETACH" "$HOME/work/c1" >/dev/null 2>&1
test_case "clear removes one" assert_exit 0 "$DETACH" clear
test_case "cleared file is gone" assert_file_missing "$HOME/.detach/3"
test_case "c1 not restored" assert_file_missing "$HOME/work/c1"

# --- clear multiple ids ---
touch "$HOME/work/cm1"
touch "$HOME/work/cm2"
touch "$HOME/work/cm3"
"$DETACH" "$HOME/work/cm1" "$HOME/work/cm2" "$HOME/work/cm3" >/dev/null 2>&1
test_case "clear 2 1 removes by two ids" assert_exit 0 "$DETACH" clear 2 1
test_case "only cm3 (id 3) remains after clear 2 1" [ "$("$DETACH" ls 2>/dev/null | wc -l)" -eq 1 ] && "$DETACH" ls 2>/dev/null | grep -q "cm3"
"$DETACH" clear -a >/dev/null 2>&1

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
