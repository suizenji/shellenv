#!/bin/bash

### >>> get request ###
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
### get request <<< ###

### >>> parse request ###
q_str=$(echo "$REQ" | head -n1 | awk '{print $2}' | sed -E 's/[^?]+\?//')

declare -A q_params=()

# https://qiita.com/ko1nksm/items/e23d43a7194a388fd850#c-bash-%E3%81%A7-lastpipe-%E3%82%92%E4%BD%BF%E3%81%86%E6%8E%A8%E5%A5%A8
shopt -s extglob lastpipe

echo "$q_str" | awk -v RS='&' '{print}' | while read kv; do
    key=$(echo "$kv" | awk -v FS='=' '{print $1}')
    value=$(echo "$kv" | awk -v FS='=' '{$1=""; print $0}')

    if [[ ${#key} == 0 ]]; then
	continue
    fi

    q_params["$key"]="$value"
done

get_q_val () {
    echo ${q_params[$1]}
}

url_decode () {
    printf "%b" "${@//%/\\x}"
}
### parse request <<< ###

name=$(url_decode $(get_q_val name))
len=$(url_decode $(get_q_val len))

### >>> generate response ###
RES=$(LC_ALL=C echo $(cat <<EOF
<html>
<head></head>
<body>hello ${name}!</body>
</html>
EOF
))

BODY="${REQ}"
#BODY="${RES}"
#BODY="$q_str"
#BODY=$(get_q_val k)
### generate response <<< ###

cat <<EOF
HTTP/1.1 200 OK
Content-Length: ${len:-${#BODY}}
Server: socat

${BODY}
EOF
