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

#echo "R: $REQ"

q_str=$(echo "$REQ" | head -n1 | awk '{print $2}' | sed -E 's/[^?]+\?//')
#echo 'q:' $q_str

declare -A q_params=()
echo "$q_str" | awk -v RS='&' '{print}' | while read kv; do
#echo '>' $kv
    key=$(echo "$kv" | awk -v FS='=' '{print $1}')
    value=$(echo "$kv" | awk -v FS='=' '{$1=""; print $0}')
#    q_params["$key"]="$value"
#echo $key $value
done

## get response <<< ###

RES=$(LC_ALL=C echo $(cat <<EOF
<html>
<head></head>
<body>hello!</body>
</html>
EOF
))

BODY="${REQ}"
#BODY="${RES}"
BODY="$q_str"
#BODY="${q_params['key']}"

echo HTTP/1.1 200 OK
echo Content-Length: ${#BODY}
echo 
echo "${BODY}"

declare -A q_params=()

echo
#echo '> qstr'
#echo "$q_str"
#echo
#
#echo '> splited qstr'
#echo "$q_str" | awk -v RS='&' '$0 {print}'
#echo

# https://qiita.com/ko1nksm/items/e23d43a7194a388fd850#c-bash-%E3%81%A7-lastpipe-%E3%82%92%E4%BD%BF%E3%81%86%E6%8E%A8%E5%A5%A8
shopt -s extglob lastpipe

echo '> key-value'
echo "$q_str" | awk -v RS='&' '{print}' | while read kv; do
    key=$(echo "$kv" | awk -v FS='=' '{print $1}')
    value=$(echo "$kv" | awk -v FS='=' '{$1=""; print $0}')

    if [[ ${#key} == 0 ]]; then
	continue
    fi

    echo $key
    echo $value
    q_params["$key"]="$value"
done

echo ${q_params['k']}
