# parent CA name
CA :=

# subject
# https://docs.oracle.com/cd/F37626_01/security/ca-using-openssl.html
CSR_SUB :=

# max:825
CRT_EXP := 365

# append parent crt to child crt
CRT_CHAIN :=

# Subject Alternative Name (SAN)
CRT_SAN := DNS:localhost
#CRT_SAN := DNS.1:localhost,DNS.3:foo.localhost,DNS:*.localhost

# min:2048
DHP_LEN := 2048

# socat ssl server port
SRV_PORT := 443

# socat ssl server response
BI_ADDR2 := system:cat

# CA or SRV
EXT_TYPE =

.PRECIOUS: %.key %.csr

# show usage.
usage:
	@echo 'usage:'
	@echo '	make [target|VAR=VAL, ..]'
	@echo ''
	@echo 'examples:'
	@echo '	make ore.crt'
	@echo '	make ore.crt CSR_SUB=/C=JP'
	@echo '	make clean ore.crt CSR_SUB=/C=JP'
	@echo '	make ore.server SRV_PORT=4443 BI_ADDR2="system:./response.sh"'
	@echo '	make ca.ext EXT_TYPE=CA ca.crt ca.show-crt'
	@echo '	make root.crt && make child.crt CA=root CRT_CHAIN=1'
	@echo '	make help'
	@echo '	make link'
	@echo ''
	@echo 'tips:'
	@echo '	curl --cacert root.crt https://localhost'
	@echo '	curl telnet://localhost:8080'
	@echo '	openssl s_client localhost:443'
	@echo ''

# list this make targets.
target:
	@cat Makefile | grep -E -B1 '^[^#\.][^[:space:]]+:' | sed 's/^--//'

# show this help.
help: usage target

# genpkey
# https://wiki.ninth-nine.com/OpenSSL/genpkey

# generate a private key.
%.key:
#	openssl genrsa -out $@
	openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out $@

# generate a CSR file.
%.csr: %.key
	openssl req -new -key $< -out $@ \
	$(if $(CSR_SUB),-subj $(CSR_SUB),)

# openssl extension
# https://qiita.com/aqmr-kino/items/40ceea7c6674a78abbf4
export __EXT_V3

ifeq ($(EXT_TYPE),CA)
override define __EXT_V3
basicConstraints = critical, CA:true
keyUsage = keyCertSign, cRLSign
extendedKeyUsage = serverAuth, clientAuth
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid, issuer
endef
else ifeq ($(EXT_TYPE),SRV)
override define __EXT_V3
basicConstraints = critical, CA:false
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid, issuer
subjectAltName = $(CRT_SAN)
endef
else
endif

# generate a extention file(with var "EXT_TYPE=CA/SRV").
%.ext:
	@echo "$$__EXT_V3" > $@

# generate a crt file.
%.crt: %.key %.csr
	openssl x509 -req \
	-days $(CRT_EXP) \
	$(CRT_SIGN) \
	$(CRT_EXT) \
	-in $*.csr -out $@
ifneq ($(CRT_CHAIN),)
	-test -e $(CA).crt && cat $(CA).crt >> $@
endif

ifeq ($(CA),)
CRT_SIGN = -signkey $*.key
else
CRT_SIGN = -CA $(CA).crt -CAkey $(CA).key -CAcreateserial
endif

CRT_EXT = $(if $(wildcard $*.ext),-extfile $*.ext,)

# show key info
%.show-key: %.key
#	openssl rsa -in $< -text -noout
	openssl pkey -in $< -text -noout

# show pub info
%.show-pub: %.pub
	openssl rsa -pubin -in $< -text -noout

# show scr info.
%.show-csr: %.csr
	openssl req -in $< -text -noout

# show crt info.
%.show-crt: %.crt
	openssl x509 -in $< -text -noout

# show expiration date.
%.show-exp: %.crt
	openssl x509 -in $< -dates -noout

# socat proxy
# https://racchai.hatenablog.com/entry/2016/04/14/173000
# run a ssl server
%.server: %.crt
	sudo socat -v -v -v openssl-listen:$(SRV_PORT),verify=0,cert=$<,key=$*.key,fork,reuseaddr $(BI_ADDR2)

# socat proxy(another ver)
# https://qiita.com/cuzic/items/672c66e8ccdfba067166
# run a ssl server(another ver).
%.server2: %.cert
	sudo socat -v openssl-listen:$(SRV_PORT),verify=0,cert=$< $(BI_ADDR2)

# generate a mix file(key, crt, dhparam) for server2.
%.cert: %.key %.crt
	cat $^ > $@
	openssl dhparam $(DHP_LEN) >> $@

# clear all files.
clean:
	@make target | sed -n -e '/^%/ {s/:.*//; s/%/\*/; p}' -e '1irm -rf' | xargs | sh
	@rm -rf *.srl

# show links.
link:
	@grep -E -B1 '^# https?://.*' Makefile | sed 's/^--//'

# do test
test:
	bash test.sh

# ----- NOTE -----
# make basic usage
# http://exlight.net/devel/make/basics.html

# make here document
# https://piyolian.blogspot.com/2015/06/here-document-in-makefile.html

# socat basic usage
# http://x68000.q-e-d.net/~68user/unix/pickup?socat#prgmemo-socat-basic

# socat usage
# https://kazuhira-r.hatenablog.com/entry/2020/04/11/154036
# https proxy-> $ sudo socat openssl-listen:443,cert=foo.crt,key=foo.key,verify=0 openssl:google.com:443,verify=0

# openssl rsa/pem/der
# https://www.sambaiz.net/article/135/

# openssl usage and crt knowledge
# https://qiita.com/kunichiko/items/12cbccaadcbf41c72735

# ssl route of A+
# https://blog.kksg.net/posts/nginx-secure-ssl/

# X.509
# https://qiita.com/TakahikoKawasaki/items/4c35ac38c52978805c69

# about crt types
# https://jp.globalsign.com/ssl/about/types-of-ssl.html

# dhparam
# https://qiita.com/r-ytakada/items/7ac9ce32c1ed4d01d505

# openssl cnf
# https://qiita.com/3244/items/8c7e6892efdb4e500be9

# ----- Books -----
# professional SSL/TLS
# https://www.lambdanote.com/products/tls

# mastering tcp/ip tls
# https://www.ohmsha.co.jp/book/9784274065422/
