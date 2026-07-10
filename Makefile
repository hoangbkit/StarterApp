# Build, install, and run Demo on a physical iPhone from Terminal only —
# no need to open Xcode.app, aside from the one-time account setup noted below.
#
# Quick start:
#   make devices                        # find your iPhone's identifier
#   make deploy DEVICE_ID=<identifier>   # build + install + launch
#
# One-time prerequisite (can't be avoided, it's an Apple requirement, not an
# Xcode one): your Apple ID must be added under Xcode > Settings > Accounts
# at least once, so the system has a personal signing team to build with.
# After that, everything below is pure command line.
#
# If your Apple ID has more than one team, pass TEAM_ID explicitly:
#   make deploy DEVICE_ID=<identifier> TEAM_ID=<team id>
# Find your Team ID with:
#   security find-identity -v -p codesigning

PROJECT           := Demo.xcodeproj
SCHEME            := Demo
CONFIGURATION     := Debug
BUNDLE_ID         := com.hoangbkit.Demo
BUILD_DIR         := build
APP_PATH          := $(BUILD_DIR)/Build/Products/$(CONFIGURATION)-iphoneos/Demo.app

ifdef DEVICE_ID
DESTINATION := id=$(DEVICE_ID)
else ifdef DEVICE_NAME
DESTINATION := platform=iOS,name=$(DEVICE_NAME)
endif

TEAM_ARG :=
ifdef TEAM_ID
TEAM_ARG := DEVELOPMENT_TEAM=$(TEAM_ID)
endif

.PHONY: help devices build install launch deploy clean

help:
	@echo "Targets:"
	@echo "  make devices                          List connected iPhones and their identifiers"
	@echo "  make build   DEVICE_ID=<id>            Build for a specific device"
	@echo "  make install DEVICE_ID=<id>            Install the last build onto a device"
	@echo "  make launch  DEVICE_ID=<id>             Launch the installed app on a device"
	@echo "  make deploy  DEVICE_ID=<id>            Build + install + launch, all in one"
	@echo "  make clean                              Remove local build output"
	@echo ""
	@echo "Optional: TEAM_ID=<team id> if your Apple ID has multiple teams"
	@echo "You can use DEVICE_NAME=\"Your iPhone\" instead of DEVICE_ID if you prefer."

devices:
	@echo "Connected devices:"
	@xcrun devicectl list devices

build:
	@if [ -z "$(DESTINATION)" ]; then \
		echo "Error: pass DEVICE_ID=<identifier> or DEVICE_NAME=\"Your iPhone\" (run 'make devices' to find it)"; \
		exit 1; \
	fi
	xcodebuild build \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration $(CONFIGURATION) \
		-destination '$(DESTINATION)' \
		-derivedDataPath $(BUILD_DIR) \
		-allowProvisioningUpdates \
		CODE_SIGNING_ALLOWED=YES \
		CODE_SIGNING_REQUIRED=YES \
		$(TEAM_ARG)

install:
	@if [ -z "$(DEVICE_ID)" ]; then \
		echo "Error: pass DEVICE_ID=<identifier> (run 'make devices' to find it)"; \
		exit 1; \
	fi
	@if [ ! -d "$(APP_PATH)" ]; then \
		echo "Error: no build found at $(APP_PATH). Run 'make build DEVICE_ID=$(DEVICE_ID)' first."; \
		exit 1; \
	fi
	xcrun devicectl device install app --device $(DEVICE_ID) $(APP_PATH)

launch:
	@if [ -z "$(DEVICE_ID)" ]; then \
		echo "Error: pass DEVICE_ID=<identifier> (run 'make devices' to find it)"; \
		exit 1; \
	fi
	xcrun devicectl device process launch --device $(DEVICE_ID) $(BUNDLE_ID)

deploy: build install launch

clean:
	rm -rf $(BUILD_DIR)
