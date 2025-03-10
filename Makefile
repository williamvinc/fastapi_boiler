# Docker Whitelist, Build and Push
export PLATFORM_ARCHITECTURE=linux/amd64

# Python & tests
export PYTHON_VERSION?=3.12
export BEHAVE_TEST_FOLDER=test/bdd

.PHONY: env-%
env-%:
	@ if [ "${${*}}" = "" ];then echo "Missing environment variable $*";exit 1;fi


### Python scripts ###

.PHONY: install
install: ensure-poetry
	python -m pip install --upgrade pip
	poetry env use 3.12
	@echo ">> Installing dependencies"
	poetry install --without dev

## Install for development
.PHONY: install-dev
install-dev: install
	poetry env use 3.12
	poetry install --only dev

## Install pre commit hooks
.PHONY: install-pre-commit
install-pre-commit: ensure-poetry
	poetry run python -m pip install pre-commit
	poetry run pre-commit install
	poetry run pre-commit run --all-files


## Lint using ruff
.PHONY: ruff
ruff: ensure-poetry
	poetry run ruff check .

## Format files using ruff
.PHONY: format
format: ensure-poetry
	poetry run ruff format .

## Run checks (ruff + typing)
.PHONY: check
check: ensure-poetry
	poetry run ruff check .
	poetry run mypy .

# Run all for dev
.PHONY: all-dev
all-dev: ruff format check test

### BDD and Unit Tests

.PHONY: test-bdd
test-bdd: ensure-poetry

.PHONY: test-unit
test-unit: ensure-poetry
	poetry run coverage run -m pytest
	poetry run coverage report
	poetry run coverage html

.PHONY: test
test: test-bdd test-unit

.PHONY: show-outdated
show-outdated: ensure-poetry
	poetry show --outdated

.PHONY: ensure-poetry
ensure-poetry:
	@pip install --quiet poetry

# Package
.PHONY: package
package: ensure-poetry
	pip --version
	poetry export --directory=. --format requirements.txt --without-hashes --output=requirements.txt
	pip install --target=dist -r requirements.txt --platform=manylinux2014_x86_64 --only-binary=:all:

	cp -rf src/* dist/
	cd dist && zip -r package.zip .


.PHONY: run
run: ensure-poetry
	poetry run python -m run