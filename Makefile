.PHONY: docker test

REQS := requirements.txt
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

docker: ## build docker container for testing
	@echo "Building test env with docker-compose"
	@if [ -f /.dockerenv ]; then echo "Don't run make docker inside docker container" && exit 1; fi;
	docker-compose -f docker/docker-compose.yml up franklin
	@docker-compose -f docker/docker-compose.yml run franklin /bin/bash

python: ## setup python3
	if [ -f 'requirements.txt' ]; then pip3 install -r$(REQS); fi

test: python ## run tests in container
	if [ -f 'requirements-test.txt' ]; then pip3 install -rrequirements-test.txt; fi
	tox
