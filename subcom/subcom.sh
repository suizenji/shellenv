#!/bin/bash
(($#)) || {
    cat <<EOF
Usage: $(basename "$0") [-f rlwrap-options] command
EOF
    exit 1
}

RLWRAP_FLAGS=
[[ "$1" == "-f" ]] && {
    RLWRAP_FLAGS="$2"
    shift 2
}

SRC_HOME="$(dirname "$(readlink "$0")")"
FILTER="${SRC_HOME}/filter.pl"
CMD="$@"
CMD_BASE="$(basename "$1")"

# -c: file
rlwrap -z"${FILTER} '$CMD'" -C "$CMD_BASE" $RLWRAP_FLAGS -- awk -v Cmd="$CMD" '
  function prompt() {printf("%s> ", Cmd) > "/dev/stderr"}
  BEGIN {prompt()}
  $0 {
    ExecCmd = (/^!/ ? "" : Cmd" ") $0
    sub("^!", "", ExecCmd)
    system(ExecCmd)
  }
  {prompt()}
'
