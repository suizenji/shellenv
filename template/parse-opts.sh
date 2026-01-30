#!/usr/bin/env bash

parse() {
  while [ "$#" -gt 0 ]; do
    echo "[\$#] $#"
    echo "[\$@] $@"
    case "$1" in
    --) shift; ARGS="$@"; return; break;;
    -h | --help) FLAG_HELP=1; shift; ARGS="$@"; break ;;
    -l | --list) FLAG_LIST=1; shift; ARGS="$@"; ;;
    -v | --verbose) FLAG_VERB=1; shift; ARGS="$@"; ;;
    -f | --file) FILE="$2"; shift 2; ARGS="$@"; ;;
    com) SUBCOM=com; shift; ARGS="$@"; break ;;
    -[!-]?*)
      opts="${1#-}"
      shift
      for ((i=0; i<${#opts}; i++)); do
        set -- "-${opts:$i:1}" "$@"
      done
      continue
      ;;
    *)
      if [ "${1#-}" != "$1" ]; then
        echo "Unknown option: $1" >&2
        exit 1
      fi
      ARGS="$@"; break ;;
    esac
  done
}
parse "$@"
set -- $ARGS

if [ "$FLAG_HELP" == "1" ]; then
  echo 'show help!' >&2
  exit 1
fi

echo '...'
echo "[\$@] $@"
echo "[\$ARGS] $ARGS"
echo "[FLAG_HELP] $FLAG_HELP"
echo "[FLAG_LIST] $FLAG_LIST"
echo "[FLAG_VERB] $FLAG_VERB"
echo "[FILE] $FILE"
echo "[com] $SUBCOM"
