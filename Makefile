# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

THIS_FILE := $(lastword $(MAKEFILE_LIST))

down:
	USERID=$$(id -u) GROUPID=$$(id -g) docker-compose down -v --remove-orphans
build:
	USERID=$$(id -u) GROUPID=$$(id -g) docker-compose -f docker-compose.yml build
up:
	USERID=$$(id -u) GROUPID=$$(id -g) docker-compose -f docker-compose.yml build
	USERID=$$(id -u) GROUPID=$$(id -g) docker-compose -f docker-compose.yml up -d
