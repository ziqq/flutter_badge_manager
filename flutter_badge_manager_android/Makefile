SHELL :=/bin/bash -e -o pipefail
PWD   :=$(shell pwd)

.DEFAULT_GOAL := all
.PHONY: all
all: ## build pipeline
all: get format analyze pigeon-check test-unit publish-check

.PHONY: ci
ci: ## CI build pipeline
ci: all

.PHONY: precommit
precommit: ## validate the branch before commit
precommit: all

.PHONY: help
help: ## Help dialog
				@echo 'Usage: make <OPTIONS>  <TARGETS>'
				@echo ''
				@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: doctor
doctor: ## Check flutter doctor
				@fvm flutter doctor

.PHONY: version
version: ## Check flutter version
				@fvm flutter --version

.PHONY: format
format: ## Format code
				@find lib test pigeons -type f -name '*.dart' ! -name '*.g.dart' -exec fvm dart format -l 80 {} + || (echo "¯\_(ツ)_/¯ Format code error"; exit 1)

.PHONY: pigeon
pigeon: ## Regenerate Pigeon bindings
				@fvm dart run pigeon --input pigeons/flutter_badge_manager.dart || (echo "¯\_(ツ)_/¯ Pigeon generation error"; exit 1)
				@perl -0pi -e 's/public class FlutterBadgeManagerPluginPigeon/class FlutterBadgeManagerPluginPigeon/' android/src/main/java/flutter/plugins/flutterbadgemanager/FlutterBadgeManagerPlugin.g.java

.PHONY: pigeon-check
pigeon-check: ## Verify generated Pigeon bindings
				@before="$$(for file in \
					lib/src/flutter_badge_manager_android.g.dart \
					test/test_api.g.dart \
					android/src/main/java/flutter/plugins/flutterbadgemanager/FlutterBadgeManagerPlugin.g.java; do \
						if [ -f "$$file" ]; then shasum "$$file"; else echo "missing $$file"; fi; \
					done)"; \
				$(MAKE) pigeon > /dev/null; \
				after="$$(for file in \
					lib/src/flutter_badge_manager_android.g.dart \
					test/test_api.g.dart \
					android/src/main/java/flutter/plugins/flutterbadgemanager/FlutterBadgeManagerPlugin.g.java; do \
						if [ -f "$$file" ]; then shasum "$$file"; else echo "missing $$file"; fi; \
					done)"; \
				if [ "$$before" != "$$after" ]; then \
					echo "¯\_(ツ)_/¯ Pigeon generated files are out of date"; \
					exit 1; \
				fi

.PHONY: fix
fix: format ## Fix code
				@fvm dart fix --apply lib

.PHONY: clean
clean: ## Clean flutter
				@fvm flutter clean

.PHONY: get
get: ## Get dependencies
				@fvm flutter pub get || (echo "¯\_(ツ)_/¯ Get flutter_badge_manager_platform_interface dependencies error"; exit 1)

.PHONY: analyze
analyze: ## Analyze code
				@fvm dart analyze --fatal-infos --fatal-warnings || (echo "¯\_(ツ)_/¯ Analyze code error"; exit 1)

.PHONY: check
check: ## Check the code
				@$(MAKE) pigeon-check
				@fvm dart pub global activate pana
				@pana --json --no-warning --line-length 80 > log.pana.json || (echo "¯\_(ツ)_/¯ Check code error"; exit 1)

.PHONY: publish-check
publish-check: ## Check the code before publish
				@fvm dart pub publish --dry-run

.PHONY: publish
publish: ## Publish package
				@fvm dart pub publish --server=https://pub.dartlang.org || (echo "¯\_(ツ)_/¯ Publish error"; exit 1)

.PHONY: coverage
coverage: ## Runs get coverage
				@lcov --summary coverage/lcov.info

.PHONY: run-genhtml
run-genhtml: ## Runs generage coverage html
				@genhtml coverage/lcov.info -o coverage/html

.PHONY: test-unit
test-unit: ## Runs unit tests
				@fvm flutter test --coverage || (echo "¯\_(ツ)_/¯ Error while running test-unit"; exit 1)
				@genhtml coverage/lcov.info --output=coverage -o coverage/html || (echo "¯\_(ツ)_/¯ Error while running genhtml"; exit 2)
				@cd example && fvm flutter test --coverage || (echo "¯\_(ツ)_/¯ Error while running test-unit in example"; exit 3)
				@cd example && genhtml coverage/lcov.info --output=coverage -o coverage/html || (echo "¯\_(ツ)_/¯ Error while running genhtml in example"; exit 4)
