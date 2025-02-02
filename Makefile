.PHONY: all clean deps build test full-refresh run-source run-staging run-curated lint lint-fix format

# Default variables
MODELS ?= all  # Can be overridden from command line
DBT = dbt
PROJECT_DIR = .

# Default target
all: build

# Install dependencies
deps:
	pip install -r requirements.txt

# Clean dbt artifacts
clean:
	rm -rf target/
	rm -rf dbt_packages/
	rm -rf logs/

# Run dbt deps to install packages
dbt-deps:
	$(DBT) deps

# Build all models
build: dbt-deps
	$(DBT) build --models $(MODELS)

# Run tests
test: dbt-deps
	$(DBT) test --models $(MODELS)

# Full refresh of models
full-refresh: dbt-deps
	$(DBT) build --full-refresh --models $(MODELS)

# Run only source models
run-source: dbt-deps
	$(DBT) build --models source.*

# Run only staging models
run-staging: dbt-deps
	$(DBT) build --models staging.*

# Run only curated models
run-curated: dbt-deps
	$(DBT) build --models curated.*

# Run specific models with full refresh
full-refresh-models: dbt-deps
	$(DBT) build --full-refresh --models $(MODELS)

# Show documentation
docs:
	$(DBT) docs generate
	$(DBT) docs serve

# Quality targets
# Variables for formatting
YELLOW := \033[1;33m
GREEN := \033[1;32m
NC := \033[0m
MODELS_DIR := models
SQLFLUFF_CONFIG := .sqlfluff

YELLOW := \033[1;33m
GREEN := \033[1;32m
NC := \033[0m
MODELS_DIR := models
SQLFLUFF_CONFIG := .sqlfluff

lint:
	sqlfluff lint \

lint-fix:
	sqlfluff fix \
		--config $(SQLFLUFF_CONFIG) \
		--ignore .venv,target,dbt_packages .

# Example usage:
# make build MODELS=staging.political_users+  # Run political_users and its children
# make full-refresh MODELS=source.*  # Full refresh of source models
# make run-staging  # Run all staging models
# make full-refresh-models MODELS=staging.political_users  # Full refresh specific model