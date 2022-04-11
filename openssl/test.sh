#!/bin/bash
set -e

create_cert() {
    make ${1}.ext EXT_TYPE=${2} \
	 ${1}.crt CSR_SUB=/O=${1}.com \
	 CA=${3} CRT_CHAIN=1
}

prepare() {
    W_DIR=$(mktemp -d)
    trap "rm -rf ${W_DIR}" 0

    cp Makefile ${W_DIR}
    cp "$0" ${W_DIR}
    cd ${W_DIR}
}

prepare
create_cert rootCA CA
create_cert leafCA CA  rootCA
create_cert server SRV leafCA

crt_info() {
    openssl x509 -in server.crt -$1 -noout | cut -d' ' -f 3
}

I=$(openssl x509 -in server.crt -issuer -noout | cut -d' ' -f 3)
S=$(openssl x509 -in server.crt -subject -noout | cut -d' ' -f 3)

[[ $I == leafCA.com ]]
[[ $S == server.com ]]

printf "\e[32mOK!\e[m\n"

