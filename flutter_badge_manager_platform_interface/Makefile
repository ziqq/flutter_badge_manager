SHELL :=/bin/bash -e -o pipefail
PWD   :=$(shell pwd)

.PHONY: help
help: ## Help dialog
				@echo 'Usage: make <OPTIONS>  <TARGETS>'
				@echo ''
				@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: format
format: ## Format code
				@echo "╠ RUN FORMAT THE CODE"
				@dart format -l 80 lib test || (echo "¯\_(ツ)_/¯ Format code error"; exit 1)
				@echo "╠ CODE FORMATED SUCCESSFULLY"

.PHONY: fix
fix: format ## Fix code
				@dart fix --apply lib

.PHONY: get
get: ## Get dependencies
				@echo "╠ RUN GET DEPENDENCIES"
				@flutter pub get || (echo "¯\_(ツ)_/¯ Get dependencies error"; exit 1)
				@echo "╠ DEPENDENCIES GETED SUCCESSFULLY"

.PHONY: pigeon
pigeon: ## Generate pigeon
				@echo "╠ RUN PIGEON"
				@dart run pigeon \
				--input pigeons/contactos.dart \
				--copyright_header pigeons/copyright_header.txt \
				--dart_out lib/src/contactos.g.dart \
				--java_out android/src/main/java/flutter/plugins/contactos/generated/ContactosPlugin.java \
				--java_package "flutter.plugins.contactos.generated" \
				@echo "╠ PIGEON SUCCESSFULLY"

.PHONY: analyze
analyze: get format ## Analyze code
				@echo "╠ RUN ANALYZE THE CODE"
				@dart analyze --fatal-infos --fatal-warnings
				@echo "╠ ANALYZED CODE SUCCESSFULLY"

.PHONY: check
check: analyze publish-check ## Check the code
				@echo "╠ RUN CECK CODE"
				@dart pub global activate pana
				@pana --json --no-warning --line-length 80 > log.pana.json
				@echo "╠ CECKED CODE SUCCESSFULLY"

.PHONY: coverage
coverage: ## Runs get coverage
				@lcov --summary coverage/lcov.info

.PHONY: run-genhtml
run-genhtml: ## Runs generage coverage html
				@genhtml coverage/lcov.info -o coverage/html

.PHONY: test-unit
test-unit: ## Runs unit tests
				@echo "╠ RUNNING UNIT TESTS FOR CONTACTOS PLATFORM INTERFACE"
				@flutter test --coverage || (echo "¯\_(ツ)_/¯ Error while running test-unit"; exit 1)
				@genhtml coverage/lcov.info --output=coverage -o coverage/html || (echo "¯\_(ツ)_/¯ Error while running genhtml with coverage"; exit 2)
				@echo "╠ CONTACTOS PLATFORM INTERFACE UNIT TESTS SUCCESSFULLY"