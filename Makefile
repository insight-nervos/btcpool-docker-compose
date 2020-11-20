SHELL := /bin/bash -euo pipefail
.PHONY: all test clean build

help: 								## Show help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

build:
	./scripts/build-images.sh

start:
	./scripts/compose.sh start

stop:
	./scripts/compose.sh stop

test:								## Run tests
	go test ./test -v -timeout 45m

test-init:							## Initialize the repo for tests
	go mod init test && go mod tidy