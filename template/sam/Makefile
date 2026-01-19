APP := app

ifeq ($(shell uname -m),arm64)
	ARCH := arm64
else
	ARCH := x86_64
endif

help:
	@cat Makefile | sed -En '/^[^[:space:]]+:/p'

env:
	@echo APP = $(APP)
	@echo ARCH = $(ARCH)

build:
	sam build --parameter-overrides Arch=$(ARCH)

invoke:
	sam local invoke --parameter-overrides Arch=$(ARCH) --skip-pull-image --event events/event.json --docker-network sam-net

invoke-stg:
	sam remote invoke --stack-name stack --event-file events/event.json

put-stg:
	aws kinesis put-record --stream-name stream --partition-key 1 --data base64string

log-stg:
	aws logs tail --format short --follow /aws/lambda/xxx

deploy-stg:
	make build ARCH=x86_64
	sam deploy --config-env stg
