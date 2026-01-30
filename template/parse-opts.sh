#!/usr/bin/env bash

parse() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
    --) shift; ARGS="$@"; return; break;;
    -h | --help) FLAG_HELP=1; ARGS="$@"; break ;;
    -l | --list) FLAG_LIST=1; ARGS="$@"; break ;;
    -v | --verbose) FLAG_VERB=1; ARGS="$@"; break ;;
    -f | --file) FILE="$1"; shift 2; ARGS="$@"; break ;;
    com) SUBCOM=com; shift; ARGS="$@"; break ;;
    *) ARGS="$@"; break ;;
    esac
  done
}
parse "$@"
set -- $ARGS

echo "[\$@] $@"
echo "[\$ARGS] $ARGS"
echo "[FLAG_HELP] $FLAG_HELP"
echo "[FLAG_LIST] $FLAG_LIST"
echo "[FLAG_VERB] $FLAG_VERB"
echo "[FILE] $FILE"
echo "[com] $com"

if [ "$FLAG_HELP" == "1" ]; then
  echo 'show help!'
  exit
fi
