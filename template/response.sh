#!/bin/bash

REQ=$(awk '
{
    print $0;
    if (length($0) == 1) exit;
}
')

RES=$(LC_ALL=C echo $(cat <<EOF
<html>
<head></head>
<body>hello!</body>
</html>
EOF
))

#BODY="${REQ}"
BODY="${RES}"

echo HTTP/1.1 200 OK
echo Content-Length: ${#BODY}
echo 
echo "${BODY}"
