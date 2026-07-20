PROJECT := Demo.xcodeproj
SCHEME := Demo
UI_TEST_SCHEME := Demo UI Tests
CONFIGURATION ?= Debug
BUNDLE_ID := com.hoangbkit.demo
BUILD_DIR := build
APP_PATH := $(BUILD_DIR)/Build/Products/$(CONFIGURATION)-iphoneos/Demo.app

# Allow `make deploy se2` as shorthand for `make deploy DEVICE_NAME=se2`.
DEVICE_TARGETS := deploy build install launch
ifneq (,$(filter $(firstword $(MAKECMDGOALS)),$(DEVICE_TARGETS)))
EXTRA_ARG := $(word 2,$(MAKECMDGOALS))
ifneq (,$(EXTRA_ARG))
DEVICE_NAME := $(EXTRA_ARG)
$(eval $(EXTRA_ARG):;@:)
endif
endif

ifdef DEVICE_NAME
DEVICE_ID := $(shell xcrun xctrace list devices 2>/dev/null \
	| grep -i -- "$(DEVICE_NAME)" | head -1 | sed -n 's/.*(\(.*\)).*/\1/p')
endif

ifdef DEVICE_ID
DEVICE_DESTINATION := id=$(DEVICE_ID)
else ifdef DEVICE_NAME
DEVICE_DESTINATION := platform=iOS,name=$(DEVICE_NAME)
endif

TEAM_ARG :=
ifdef TEAM_ID
TEAM_ARG := DEVELOPMENT_TEAM=$(TEAM_ID)
endif

.PHONY: help generate open build test ui-test devices install launch deploy clean

help:
	@echo "Targets:"
	@echo "  make generate                         Generate Demo.xcodeproj with XcodeGen"
	@echo "  make open                             Generate and open the project"
	@echo "  make build                            Build for a generic iOS Simulator"
	@echo "  make test                             Run unit tests on an available iPhone Simulator"
	@echo "  make ui-test                          Run UI tests on an available iPhone Simulator"
	@echo "  make devices                          List connected devices"
	@echo "  make deploy se2                       Build, install, and launch on device named se2"
	@echo "  make deploy DEVICE_ID=<identifier>    Build, install, and launch on a device"
	@echo "  make clean                            Remove generated project and build output"
	@echo ""
	@echo "Optional: TEAM_ID=<team id> overrides the configured signing team."

generate:
	@command -v xcodegen >/dev/null 2>&1 || { \
		echo "XcodeGen 2.45.4+ is required. Install it with: brew install xcodegen"; \
		exit 1; \
	}
	xcodegen generate

open: generate
	open "$(PROJECT)"

devices:
	@xcrun devicectl list devices

build: generate
	@if [ -n "$(DEVICE_DESTINATION)" ]; then \
		xcodebuild build \
			-project "$(PROJECT)" \
			-scheme "$(SCHEME)" \
			-configuration "$(CONFIGURATION)" \
			-destination '$(DEVICE_DESTINATION)' \
			-derivedDataPath "$(BUILD_DIR)" \
			-allowProvisioningUpdates \
			CODE_SIGNING_ALLOWED=YES \
			CODE_SIGNING_REQUIRED=YES \
			$(TEAM_ARG); \
	else \
		xcodebuild build \
			-project "$(PROJECT)" \
			-scheme "$(SCHEME)" \
			-configuration "$(CONFIGURATION)" \
			-destination 'generic/platform=iOS Simulator' \
			-derivedDataPath "$(BUILD_DIR)" \
			CODE_SIGNING_ALLOWED=NO; \
	fi

test: generate
	@SIMULATOR_ID="$$(xcrun simctl list devices available -j | python3 -c \
		'import json,sys; data=json.load(sys.stdin); print(next((device["udid"] for devices in data["devices"].values() for device in devices if device.get("isAvailable") and device["name"].startswith("iPhone")), ""))')"; \
	if [ -z "$$SIMULATOR_ID" ]; then \
		echo "No available iPhone Simulator was found."; \
		exit 1; \
	fi; \
	xcodebuild test \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME)" \
		-destination "platform=iOS Simulator,id=$$SIMULATOR_ID" \
		-derivedDataPath "$(BUILD_DIR)" \
		-only-testing:DemoTests \
		CODE_SIGNING_ALLOWED=NO

ui-test: generate
	@SIMULATOR_ID="$$(xcrun simctl list devices available -j | python3 -c \
		'import json,sys; data=json.load(sys.stdin); print(next((device["udid"] for devices in data["devices"].values() for device in devices if device.get("isAvailable") and device["name"].startswith("iPhone")), ""))')"; \
	if [ -z "$$SIMULATOR_ID" ]; then \
		echo "No available iPhone Simulator was found."; \
		exit 1; \
	fi; \
	xcodebuild test \
		-project "$(PROJECT)" \
		-scheme "$(UI_TEST_SCHEME)" \
		-destination "platform=iOS Simulator,id=$$SIMULATOR_ID" \
		-derivedDataPath "$(BUILD_DIR)" \
		CODE_SIGNING_ALLOWED=NO

install:
	@if [ -z "$(DEVICE_ID)" ]; then \
		echo "Pass DEVICE_ID=<identifier> or DEVICE_NAME=<name>."; \
		exit 1; \
	fi
	@if [ ! -d "$(APP_PATH)" ]; then \
		echo "No device build found at $(APP_PATH). Run make deploy with the same device first."; \
		exit 1; \
	fi
	xcrun devicectl device install app --device "$(DEVICE_ID)" "$(APP_PATH)"

launch:
	@if [ -z "$(DEVICE_ID)" ]; then \
		echo "Pass DEVICE_ID=<identifier> or DEVICE_NAME=<name>."; \
		exit 1; \
	fi
	xcrun devicectl device process launch --device "$(DEVICE_ID)" "$(BUNDLE_ID)"

deploy: build install launch

clean:
	rm -rf "$(BUILD_DIR)" "$(PROJECT)" Generated
