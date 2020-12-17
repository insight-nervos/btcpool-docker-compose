SHELL := /bin/bash -euo pipefail
.PHONY: all test clean build

help: 								## Show help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

clean:
	@sudo rm -rf ckb-node/data mysql/data redis/data

build:
	./scripts/build-images.sh

start:
	./scripts/compose.sh start

stop:
	./scripts/compose.sh stop

ps:
	./scripts/compose.sh ps

test: test-base

test-base:
	@python -m pytest tests
