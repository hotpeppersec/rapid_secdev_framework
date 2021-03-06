.PHONY: docker terraform test

REQS := python/requirements.txt
REQS_TEST := python/requirements-test.txt
# Used for colorizing output of echo messages
BLUE := "\\033[1\;36m"
NC := "\\033[0m" # No color/default

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
  match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
  if match:
    target, help = match.groups()
    print("%-20s %s" % (target, help))
    endef

export PRINT_HELP_PYSCRIPT

help: 
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: ## Cleanup all the things
	find . -name '*.pyc' | xargs rm -rf
	find . -name '__pycache__' | xargs rm -rf
	rm -rf myvenv
	rm -rf .tox/

docker: python ## build docker container for testing
	@echo "Building test env with docker-compose"
	@if [ -f /.dockerenv ]; then echo "Don't run make docker inside docker container" && exit 1; fi;
	docker-compose -f docker/docker-compose.yml build cloudlab
	@docker-compose -f docker/docker-compose.yml run cloudlab /bin/bash

python: ## setup python3
	if [ -f '$(REQS)' ]; then python3 -m pip install -r$(REQS); fi

terraform: ## setup up terraform env
	if [ ! -f "terraform/Dockerfile" ]; then cd terraform && wget https://github.com/jessfraz/dockerfiles/raw/master/terraform/Dockerfile; fi
	docker build --tag my_cloudlab .
	docker run -name terra my_cloudlab

test: python ## run tests in container
	if [ -f '$(REQS_TEST)' ]; then python3 -m pip install -r$(REQS_TEST); fi
	cd python && tox
