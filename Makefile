SHELL :=/bin/bash -e -o pipefail
PWD   :=$(shell pwd)

# All packages in dependency order
PACKAGES := flutter_badge_manager_platform_interface flutter_badge_manager_android flutter_badge_manager_foundation flutter_badge_manager
PIGEON_PACKAGES := flutter_badge_manager_android flutter_badge_manager_foundation

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
					dirs=(lib test); \
					if [ -d "$(PWD)/$$pkg/pigeons" ]; then dirs+=(pigeons); fi; \
					cd $(PWD)/$$pkg && find "$${dirs[@]}" -type f -name '*.dart' ! -name '*.g.dart' -exec fvm dart format --set-exit-if-changed --line-length 80 -o none {} + || (echo "¯\_(ツ)_/¯ Format $$pkg error"; exit 1); \
				done

.PHONY: pigeon
pigeon: get ## Regenerate Pigeon bindings
				@for pkg in $(PIGEON_PACKAGES); do \
					echo "Generating Pigeon for $$pkg..."; \
					cd $(PWD)/$$pkg && $(MAKE) pigeon || (echo "¯\_(ツ)_/¯ Pigeon $$pkg error"; exit 1); \
				done

.PHONY: pigeon-check
pigeon-check: ## Verify generated Pigeon bindings
				@before="$$(for file in \
					flutter_badge_manager_android/lib/src/flutter_badge_manager_android.g.dart \
					flutter_badge_manager_android/test/test_api.g.dart \
					flutter_badge_manager_android/android/src/main/java/flutter/plugins/flutterbadgemanager/FlutterBadgeManagerPlugin.g.java \
					flutter_badge_manager_foundation/lib/src/flutter_badge_manager_foundation.g.dart \
					flutter_badge_manager_foundation/test/test_api.g.dart \
					flutter_badge_manager_foundation/darwin/flutter_badge_manager_foundation/Sources/flutter_badge_manager_foundation/FlutterBadgeManagerPlugin.g.swift; do \
						if [ -f "$$file" ]; then shasum "$$file"; else echo "missing $$file"; fi; \
					done)"; \
				$(MAKE) pigeon > /dev/null; \
				after="$$(for file in \
					flutter_badge_manager_android/lib/src/flutter_badge_manager_android.g.dart \
					flutter_badge_manager_android/test/test_api.g.dart \
					flutter_badge_manager_android/android/src/main/java/flutter/plugins/flutterbadgemanager/FlutterBadgeManagerPlugin.g.java \
					flutter_badge_manager_foundation/lib/src/flutter_badge_manager_foundation.g.dart \
					flutter_badge_manager_foundation/test/test_api.g.dart \
					flutter_badge_manager_foundation/darwin/flutter_badge_manager_foundation/Sources/flutter_badge_manager_foundation/FlutterBadgeManagerPlugin.g.swift; do \
						if [ -f "$$file" ]; then shasum "$$file"; else echo "missing $$file"; fi; \
					done)"; \
				if [ "$$before" != "$$after" ]; then \
					echo "¯\_(ツ)_/¯ Pigeon generated files are out of date"; \
					exit 1; \
				fi

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
					cd $(PWD)/$$pkg && fvm flutter analyze --fatal-warnings --no-fatal-infos lib/ test/ || (echo "¯\_(ツ)_/¯ Analyze $$pkg error"; exit 1); \
				done

.PHONY: check
check: analyze pigeon-check ## Analyze + pana for all packages
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
						cd "$(PWD)/$$pkg" && fvm flutter test --coverage || { echo "¯\_(ツ)_/¯ Test $$pkg error"; exit 1; }; \
						cd "$(PWD)/$$pkg" && genhtml coverage/lcov.info --output=coverage -o coverage/html || { echo "¯\_(ツ)_/¯ Error while running genhtml in $(PWD)/$$pkg"; exit 2; }; \
						if [ -d "$(PWD)/$$pkg/example" ]; then \
								cd "$(PWD)/$$pkg/example" && fvm flutter test --coverage || { echo "¯\_(ツ)_/¯ Test $$pkg example error"; exit 3; }; \
								cd "$(PWD)/$$pkg/example" && genhtml coverage/lcov.info --output=coverage -o coverage/html || { echo "¯\_(ツ)_/¯ Error while running genhtml in $$pkg/example"; exit 4; }; \
						else \
								echo "Skipping $$pkg/example tests..."; \
						fi; \
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
