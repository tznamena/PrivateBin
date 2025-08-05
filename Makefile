.PHONY: all coverage coverage-js coverage-php doc doc-js doc-php increment sign test test-js test-php help docker-build docker-dev docker-test docker-shell docker-clean docker-prod docker-logs docker-stop docker-restart

CURRENT_VERSION = 2.0.0
VERSION ?= 2.0.1
VERSION_FILES = README.md SECURITY.md doc/Installation.md js/package*.json lib/Controller.php Makefile
REGEX_CURRENT_VERSION := $(shell echo $(CURRENT_VERSION) | sed "s/\./\\\./g")
REGEX_VERSION := $(shell echo $(VERSION) | sed "s/\./\\\./g")

all: coverage doc ## Equivalent to running `make coverage doc`.

composer: ## Update composer dependencies (only production ones, optimize the autoloader)
	composer update --no-dev --optimize-autoloader

coverage: coverage-js coverage-php ## Run all unit tests and generate code coverage reports.

coverage-js: ## Run JS unit tests and generate code coverage reports.
	cd js && nyc mocha

coverage-php: ## Run PHP unit tests and generate code coverage reports.
	cd tst && XDEBUG_MODE=coverage phpunit 2> /dev/null
	cd tst/log/php-coverage-report && sed -i "s#$(CURDIR)/##g" *.html */*.html

doc: doc-js doc-php ## Generate all code documentation.

doc-js: ## Generate JS code documentation.
	jsdoc -p -d doc/jsdoc js/privatebin.js js/legacy.js

doc-php: ## Generate JS code documentation.
	phpdoc --visibility=public,protected,private --target=doc/phpdoc --directory=lib/

increment: ## Increment and commit new version number, set target version using `make increment VERSION=1.2.3`.
	for F in `grep -l -R $(REGEX_CURRENT_VERSION) $(VERSION_FILES)`; \
	do \
		sed -i "s/$(REGEX_CURRENT_VERSION)/$(REGEX_VERSION)/g" $$F; \
	done
	git add $(VERSION_FILES) CHANGELOG.md
	git commit -m "incrementing version"

sign: ## Sign a release.
	git tag --sign --message "Release v$(VERSION)" $(VERSION)
	git push origin $(VERSION)
	signrelease.sh

test: test-js test-php ## Run all unit tests.

test-js: ## Run JS unit tests.
	cd js && mocha

test-php: ## Run PHP unit tests.
	cd tst && phpunit --no-coverage

# Docker Development Targets
docker-build: ## Build the development Docker image
	docker compose build privatebin-dev

docker-dev: ## Start development environment with live reload
	docker compose up -d
	@echo "PrivateBin development environment started!"
	@echo "Access the application at: http://localhost:8080"
	@echo "Database admin (Adminer) at: http://localhost:8081"
	@echo "MinIO console at: http://localhost:9001"

docker-test: ## Run all tests in Docker container
	docker compose exec privatebin-dev make test

docker-test-php: ## Run PHP unit tests in Docker container
	docker compose exec privatebin-dev make test-php

docker-test-js: ## Run JavaScript unit tests in Docker container
	docker compose exec privatebin-dev make test-js

docker-coverage: ## Generate coverage reports in Docker container
	docker compose exec privatebin-dev make coverage

docker-shell: ## Open shell in running development container
	docker compose exec privatebin-dev bash

docker-logs: ## Show logs from development containers
	timeout 30s docker compose logs -f || docker compose logs --tail 50

docker-stop: ## Stop development environment
	docker compose down

docker-restart: ## Restart development environment
	docker compose restart privatebin-dev

docker-clean: ## Clean up Docker containers, images and volumes
	docker compose down -v --rmi all
	docker system prune -f

docker-prod: ## Build and start production environment
	docker compose -f docker-compose.prod.yml up -d --build
	@echo "PrivateBin production environment started!"
	@echo "Access the application at: http://localhost"

docker-prod-stop: ## Stop production environment
	docker compose -f docker-compose.prod.yml down

docker-prod-logs: ## Show logs from production containers
	timeout 30s docker compose -f docker-compose.prod.yml logs -f || docker compose -f docker-compose.prod.yml logs --tail 50

help: ## Displays these usage instructions.
	@echo "Usage: make <target(s)>"
	@echo
	@echo "Specify one or multiple of the following targets and they will be processed in the given order:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "%-20s%s\n", $$1, $$2}' $(MAKEFILE_LIST)
