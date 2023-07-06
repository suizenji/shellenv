#!/bin/bash

### >>> get response ###
is_first=1
while read line; do
    if [[ ${#line} == 1 ]]; then
        req_con_len=$(echo "$req_heads" | grep -Ei content-length | awk '{print $2}')
        read -n ${req_con_len:-0} -d "\0" req_body
        break
    fi

    line=$(echo "$line" | awk -v RS='\r' '{print $0 "\n"}')

    if [[ $is_first == 1 ]]; then
        req_heads="$line"
        is_first=0
        continue
    fi

    req_heads=$(cat <<EOF
${req_heads}
${line}
EOF
)
done

REQ=$(cat <<EOF
$req_heads

$req_body
EOF
)

q_str=$(echo "$REQ" | head -n1 | awk '{print $2}' | sed -E 's/[^?]+\?//')

### get response <<< ###

RES=$(LC_ALL=C echo $(cat <<EOF
<html>
<head></head>
<body>hello!</body>
</html>
EOF
))

BODY="${REQ}"
#BODY="${RES}"
#BODY="$q_str"

echo HTTP/1.1 200 OK
echo Content-Length: ${#BODY}
echo 
echo "${BODY}"
