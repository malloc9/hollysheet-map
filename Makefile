# Makefile for local Flutter development
# Requires a .env file (copy from .env.example and fill in values)

# Import .env file
ifneq ($(wildcard .env),)
    include .env
    export
endif

# Build the --dart-define flags from .env variables
DART_DEFINES := \
	--dart-define=FIREBASE_API_KEY=$(FIREBASE_API_KEY) \
	--dart-define=FIREBASE_AUTH_DOMAIN=$(FIREBASE_AUTH_DOMAIN) \
	--dart-define=FIREBASE_PROJECT_ID=$(FIREBASE_PROJECT_ID) \
	--dart-define=FIREBASE_STORAGE_BUCKET=$(FIREBASE_STORAGE_BUCKET) \
	--dart-define=FIREBASE_MESSAGING_SENDER_ID=$(FIREBASE_MESSAGING_SENDER_ID) \
	--dart-define=FIREBASE_APP_ID=$(FIREBASE_APP_ID)

.PHONY: check-env run run-web build-web analyze clean help

check-env:
	@if [ -z "$(FIREBASE_API_KEY)" ]; then \
		echo "Error: FIREBASE_API_KEY is not set in .env file."; \
		echo "Copy .env.example to .env and fill in your Firebase config."; \
		exit 1; \
	fi

## Run the app on a connected device (mobile/desktop)
run: check-env
	flutter run $(DART_DEFINES)

## Run the app in a web browser
run-web: check-env
	flutter run -d chrome $(DART_DEFINES)

## Build a release web app
build-web: check-env
	flutter build web --release --base-href /hollysheet-map/ $(DART_DEFINES)

## Run Flutter analyzer
analyze:
	flutter analyze --no-fatal-infos --no-fatal-warnings

## Clean build artifacts
clean:
	flutter clean

## Show available targets
help:
	@echo "Available targets:"
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## //; s/:.*/\t/'
