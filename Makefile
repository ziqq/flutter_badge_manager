SHELL :=/bin/bash -e -o pipefail
PWD   :=$(shell pwd)

# All packages in dependency order
PACKAGES := flutter_badge_manager_platform_interface flutter_badge_manager_android flutter_badge_manager_foundation flutter_badge_manager

.DEFAULT_GOAL := all
.PHONY: all
all: ## Full pipeline: format + check + test-unit
all: format check test-unit

.PHONY: ci
ci: ## CI build pipeline
ci: all

.PHONY: precommit
precommit: ## Validate the branch before commit
precommit: all

.PHONY: help
help: ## Help dialog
				@echo 'Usage: make <OPTIONS> <TARGETS>'
				@echo ''
				@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: doctor
doctor: ## Check flutter doctor
				@fvm flutter doctor

.PHONY: version
version: ## Check flutter version
				@fvm flutter --version

.PHONY: format
format: ## Format all packages
				@for pkg in $(PACKAGES); do \
					echo "Formatting $$pkg..."; \
					cd $(PWD)/$$pkg && fvm dart format -l 80 lib test || (echo "¯\_(ツ)_/¯ Format $$pkg error"; exit 1); \
				done

.PHONY: fix
fix: ## Fix all packages
				@for pkg in $(PACKAGES); do \
					echo "Fixing $$pkg..."; \
					cd $(PWD)/$$pkg && fvm dart fix --apply lib || (echo "¯\_(ツ)_/¯ Fix $$pkg error"; exit 1); \
				done

.PHONY: clean-cache
clean-cache: ## Clean the pub cache
				@fvm flutter pub cache repair

.PHONY: clean
clean: ## Clean all packages
				@for pkg in $(PACKAGES); do \
					echo "Cleaning $$pkg..."; \
					cd $(PWD)/$$pkg && fvm flutter clean || true; \
				done

.PHONY: get
get: ## Get dependencies for all packages
				@for pkg in $(PACKAGES); do \
					echo "Getting dependencies for $$pkg..."; \
					cd $(PWD)/$$pkg && fvm flutter pub get || (echo "¯\_(ツ)_/¯ Get $$pkg dependencies error"; exit 1); \
				done

.PHONY: analyze
analyze: get ## Analyze all packages
				@for pkg in $(PACKAGES); do \
					echo "Analyzing $$pkg..."; \
					cd $(PWD)/$$pkg && fvm dart analyze --fatal-warnings --no-fatal-infos || (echo "¯\_(ツ)_/¯ Analyze $$pkg error"; exit 1); \
				done

.PHONY: check
check: analyze ## Analyze + pana for all packages
				@fvm dart pub global deactivate pana > /dev/null 2>&1 || true
				@fvm dart pub global activate pana
				@for pkg in $(PACKAGES); do \
					echo "Running pana for $$pkg..."; \
					cd $(PWD)/$$pkg && fvm dart pub global run pana --json > log.pana.json || (echo "¯\_(ツ)_/¯ Pana $$pkg error"; exit 1); \
				done

.PHONY: publish-check
publish-check: ## Dry-run publish for all packages
				@for pkg in $(PACKAGES); do \
					echo "Publish check $$pkg..."; \
					cd $(PWD)/$$pkg && fvm dart pub publish --dry-run || (echo "¯\_(ツ)_/¯ Publish check $$pkg error"; exit 1); \
				done

.PHONY: test-unit
test-unit: ## Run unit tests for all packages
				@for pkg in $(PACKAGES); do \
					echo "Testing $$pkg..."; \
					cd $(PWD)/$$pkg && fvm flutter test --coverage || (echo "¯\_(ツ)_/¯ Test $$pkg error"; exit 1); \
				done

.PHONY: tag
tag: ## Add a tag to the current commit
	@dart run tool/tag.dart

.PHONY: tag-add
tag-add: ## Add TAG. E.g: make tag-add TAG=v1.0.0
				@if [ -z "$(TAG)" ]; then echo "¯\_(ツ)_/¯ TAG is not set"; exit 1; fi
				@echo ""
				@echo "START ADDING TAG: $(TAG)"
				@echo ""
				@git tag $(TAG)
				@git push origin $(TAG)
				@echo ""
				@echo "CREATED AND PUSHED TAG $(TAG)"
				@echo ""

.PHONY: tag-remove
tag-remove: ## Delete TAG. E.g: make tag-remove TAG=v1.0.0
				@if [ -z "$(TAG)" ]; then echo "¯\_(ツ)_/¯ TAG is not set"; exit 1; fi
				@echo ""
				@echo "START REMOVING TAG: $(TAG)"
				@echo ""
				@git tag -d $(TAG)
				@git push origin --delete $(TAG)
				@echo ""
				@echo "DELETED TAG $(TAG) LOCALLY AND REMOTELY"
				@echo ""
