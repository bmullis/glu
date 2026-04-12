.PHONY: build run clean generate

SCHEME = Glu
PROJECT = Glu.xcodeproj
DESTINATION = platform=macOS,arch=arm64
BUILD_DIR = build

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination '$(DESTINATION)' -derivedDataPath $(BUILD_DIR) build

run: build
	open $(BUILD_DIR)/Build/Products/Debug/Glu.app

clean:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) clean
	rm -rf $(BUILD_DIR)

generate:
	xcodegen generate
