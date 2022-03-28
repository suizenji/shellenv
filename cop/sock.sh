FILE_STDIN=stdin.sock
FILE_STDOUT=stdout.sock
FILE_STDERR=stderr.sock
FILE_OUTPUT=output.sock
FILE_STREAM=stream.sock
FILE_PID=pid
FILE_F_PID=fpid

_rs() {
  awk '
    {
      for (i = 1; i <= NF; i++) { a[NR, i] = $i }
    }
    NF > p { p = NF }
    END {
      for (j = 1; j <= p; j++) {
        str = a[1, j];
        for(i = 2; i <= NR; i++) {
          str = str" "a[i, j];
        }
        print str
      }
    }
  '
}

_get_job_first_pid() {
  local PID=
  PID=$1

  local _PPID=
  _PPID=$(ps -lp $PID | sed -e 's/^[[:space:]]+//' | _rs | awk '$1 == "PPID" {print $2}' 2>/dev/null)
  if [ -z "$_PPID" ]; then
    return 2
  fi

  ps -al | awk "NR == 1; /tail/ && /$_PPID/ {if (a++ < 1) print}" | sed -e 's/^[[:space:]]+//' | _rs | awk '$1 == "PID" {print $2}' 2>/dev/null
}

_read() {
  for i in "$@"; do
    (($i == 0)) && test -e "$FILE_STDIN" && cat "$FILE_STDIN"
    (($i == 1)) && test -e "$FILE_STDOUT" && cat "$FILE_STDOUT"
    (($i == 2)) && test -e "$FILE_STDERR" && cat "$FILE_STDERR"
    (($i == 3)) && test -e "$FILE_OUTPUT" && cat "$FILE_OUTPUT"
    (($i == 4)) && test -e "$FILE_STREAM" && cat "$FILE_STREAM"
  done
}

_clear() {
  for i in "$@"; do
    (($i == 0)) && test -e "$FILE_STDIN" && : > "$FILE_STDIN"
    (($i == 1)) && test -e "$FILE_STDOUT" && : > "$FILE_STDOUT"
    (($i == 2)) && test -e "$FILE_STDERR" && : > "$FILE_STDERR"
    (($i == 3)) && test -e "$FILE_OUTPUT" && : > "$FILE_OUTPUT"
    (($i == 4)) && test -e "$FILE_STREAM" && : > "$FILE_STREAM"
  done
}

_term() {
  if [ ! -e "$FILE_F_PID" ]; then
    return 1
  fi

  cat "$FILE_F_PID" | xargs -n 1 kill -TERM
  rm "$FILE_F_PID"
}

_write() {
  if [ ! -e "$FILE_STDIN" ]; then
    echo 'input socket is not opend.'
    return 1
  fi

  if [ $# -lt 1 ]; then
    while read line; do
      echo "$line" >> "$FILE_STDIN"
    done
  else
    echo "$@" >> "$FILE_STDIN"
  fi
}

_wait() {
  local OUTPUT_OLD=
  OUTPUT_OLD=$(wc -c "$FILE_OUTPUT" 2>/dev/null | awk '{print $1}')

  "$@"

  while true; do
    OUTPUT_NEW=$(wc -c "$FILE_OUTPUT" 2>/dev/null | awk '{print $1}')

    if [ ${OUTPUT_OLD:-0} -lt ${OUTPUT_NEW:-0} ]; then
      return
    fi
  done
}

_open() {
  (($#)) || {
    echo plz command.
    return 1
  }

  # already terminated
  if [ -e "$FILE_F_PID" ]; then
    echo 'co-process is running'
    return 2
  fi

  local JOB_PID=
  _close
  : > "$FILE_STDIN"
  : > "$FILE_STDOUT"
  : > "$FILE_STDERR"
  : > "$FILE_OUTPUT"
  : > "$FILE_STREAM"

  tail --follow=name "$FILE_STDIN" 2>/dev/null | "$@" 1>"$FILE_STDOUT" 2>"$FILE_STDERR" &
  JOB_PID=$!
  echo $JOB_PID >> "$FILE_PID"
  _get_job_first_pid $JOB_PID >> "$FILE_F_PID"

  tail --follow=name "$FILE_STDOUT" 2>/dev/null >> "$FILE_OUTPUT" &
  echo $! >> "$FILE_PID"
  tail --follow=name "$FILE_STDERR" 2>/dev/null >> "$FILE_OUTPUT" &
  echo $! >> "$FILE_PID"
  tail --follow=name "$FILE_STDIN" 2>/dev/null | awk -v PID=$! -v F="$FILE_PID" 'BEGIN {printf("echo %s >> %s\n", PID, F) | "sh"} {print ">>>", $0; system("");}' >> "$FILE_STREAM" &
  echo $! >> "$FILE_PID"
  tail --follow=name "$FILE_OUTPUT" 2>/dev/null | awk -v PID=$! -v F="$FILE_PID" 'BEGIN {printf("echo %s >> %s\n", PID, F) | "sh"} {print "<<<", $0; system("");}' >> "$FILE_STREAM" &
  echo $! >> "$FILE_PID"
}

_close() {
  _term

  if [ -e "$FILE_PID" ]; then
    (cat "$FILE_PID" | xargs -n 1 kill -KILL) 2>/dev/null
  fi

  rm -rf "$FILE_STDIN" "$FILE_STDOUT" "$FILE_STDERR" "$FILE_OUTPUT" "$FILE_STREAM" "$FILE_PID"
}
