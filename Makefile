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
				@fvm dart format --fix -l 80 . || (echo "¯\_(ツ)_/¯ Format code error ¯\_(ツ)_/¯"; exit 1)
				@echo "╠ CODE FORMATED SUCCESSFULLY"

.PHONY: fix
fix: format ## Fix code
				@fvm dart fix --apply lib

.PHONY: clean-cache
clean-cache: ## Clean the pub cache
				@echo "╠ CLEAN PUB CACHE"
				@fvm flutter pub cache repair
				@echo "╠ PUB CACHE CLEANED SUCCESSFULLY"

.PHONY: clean
clean: ## Clean flutter
				@echo "╠ RUN FLUTTER CLEAN"
				@fvm flutter clean
				@echo "╠ FLUTTER CLEANED SUCCESSFULLY"

.PHONY: get
get: ## Get dependencies
				@echo "╠ RUN GET DEPENDENCIES..."
				@fvm flutter pub get || (echo "¯\_(ツ)_/¯ Get dependencies error ¯\_(ツ)_/¯"; exit 1)
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

.PHONY: test-unit
test-unit: ## Runs unit tests
				@echo "╠ RUNNING UNIT TESTS..."
				@fvm flutter test --coverage || (echo "¯\_(ツ)_/¯ Error while running tests ¯\_(ツ)_/¯"; exit 1)
				@genhtml coverage/lcov.info --output=coverage -o coverage/html || (echo "¯\_(ツ)_/¯ Error while running genhtml with coverage ¯\_(ツ)_/¯"; exit 2)
				@echo "╠ UNIT TESTS SUCCESSFULLY"

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
