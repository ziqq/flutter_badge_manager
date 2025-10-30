SHELL :=/bin/bash -e -o pipefail
PWD   :=$(shell pwd)

.DEFAULT_GOAL := all
.PHONY: all
all: ## build pipeline
all: format analyze test-unit

.PHONY: ci
ci: ## CI build pipeline
ci: all

.PHONY: precommit
precommit: ## validate the branch before commit
precommit: all

.PHONY: help
help: ## Help dialog
				@echo 'Usage: make <OPTIONS> ... <TARGETS>'
				@echo ''
				@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: doctor
doctor: ## Check fvm flutter doctor
				@fvm flutter doctor

.PHONY: version
version: ## Check fvm flutter version
				@fvm flutter --version


.PHONY: format
format: ## Format code
				@echo "╠ RUN FORMAT THE CODE"
				@fvm dart format --fix -l 80 . || (echo "¯\_(ツ)_/¯ Format code error"; exit 1)
				@echo "╠ CODE FORMATED SUCCESSFULLY"

.PHONY: fix
fix: format ## Fix code
				@fvm dart fix --apply lib

.PHONY: get
get: ## Get dependencies
				@echo "╠ RUN GET DEPENDENCIES..."
				@cd flutter_badge_manager_platform_interface; fvm flutter pub get || (echo "¯\_(ツ)_/¯ Get dependencies in flutter_badge_manager_platform_interface error ¯\_(ツ)_/¯"; exit 1)
				@cd flutter_badge_manager_android; fvm flutter pub get || (echo "¯\_(ツ)_/¯ Get dependencies in flutter_badge_manager_android error ¯\_(ツ)_/¯"; exit 2)
				@cd flutter_badge_manager_foundation; fvm flutter pub get || (echo "¯\_(ツ)_/¯ Get dependencies in flutter_badge_manager_foundation error ¯\_(ツ)_/¯"; exit 3)
				@cd flutter_badge_manager; fvm flutter pub get || (echo "¯\_(ツ)_/¯ Get dependencies in flutter_badge_manager error ¯\_(ツ)_/¯"; exit 4)
				@echo "╠ DEPENDENCIES GETED SUCCESSFULLY"

.PHONY: analyze
analyze: get format ## Analyze code
				@echo "╠ RUN ANALYZE THE CODE..."
				@fvm dart analyze --fatal-infos --fatal-warnings
				@echo "╠ ANALYZED CODE SUCCESSFULLY"

.PHONY: check
check: analyze ## Check code
				@echo "╠ RUN CECK CODE..."
				@fvm dart pub publish --dry-run
				@fvm dart pub global activate pana
				@pana --json --no-warning --line-length 80 > log.pana.json
				@echo "╠ CECKED CODE SUCCESSFULLY"

.PHONY: publish
publish: ## Publish package
				@echo "╠ RUN PUBLISHING..."
				@fvm dart pub publish --server=https://pub.dartlang.org || (echo "¯\_(ツ)_/¯ Publish error ¯\_(ツ)_/¯"; exit 1)
				@echo "╠ PUBLISH PACKAGE SUCCESSFULLY"

.PHONY: coverage
coverage: ## Runs get coverage
				@lcov --summary coverage/lcov.info

.PHONY: run-genhtml
run-genhtml: ## Runs generage coverage html
				@genhtml coverage/lcov.info -o coverage/html

.PHONY: tag-add
tag-add: ## Make command to add TAG. E.g: make tag-add TAG=v1.0.0
				@if [ -z "$(TAG)" ]; then echo "TAG is not set"; exit 1; fi
				@echo ""
				@echo "START ADDING TAG: $(TAG)"
				@echo ""
				@git tag $(TAG)
				@git push origin $(TAG)
				@echo ""
				@echo "CREATED AND PUSHED TAG $(TAG)"
				@echo ""

.PHONY: tag-remove
tag-remove: ## Make command to delete TAG. E.g: make tag-delete TAG=v1.0.0
				@if [ -z "$(TAG)" ]; then echo "TAG is not set"; exit 1; fi
				@echo ""
				@echo "START REMOVING TAG: $(TAG)"
				@echo ""
				@git tag -d $(TAG)
				@git push origin --delete $(TAG)
				@echo ""
				@echo "DELETED TAG $(TAG) LOCALLY AND REMOTELY"
				@echo ""

.PHONY: build
build: clean analyze test-unit ## Build test apk for android on example apps
				@echo "╠ START BUILD EXAMPLES..."
				@echo "║"
				@cd example && fvm flutter clean && fvm flutter pub get && fvm flutter build apk --release && fvm flutter build ios --release --no-codesign
				@echo "║"
				@echo "╠ FINISH BUILD EXAMPLES..."

.PHONY: test-unit
test-unit: ## Runs unit tests for all packages
	@echo "╠ RUNNING UNIT TESTS FOR flutter_badge_manager_platform_interface..."
	@cd flutter_badge_manager_platform_interface && flutter test --coverage test/flutter_badge_manager_platform_interface_test.dart && flutter test --coverage test/method_channel_flutter_badge_manger_test.dart || (echo "¯\_(ツ)_/¯ Error while running tests in flutter_badge_manager_platform_interface"; exit 1)

	@echo "╠ RUNNING UNIT TESTS FOR flutter_badge_manager_foundation..."
	@cd flutter_badge_manager_foundation && flutter test --coverage test/flutter_badge_manager_foundation_test.dart || (echo "¯\_(ツ)_/¯ Error while running tests in flutter_badge_manager_foundation"; exit 1)
