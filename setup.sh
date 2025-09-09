#!/bin/bash

echo "Setting up UIKit Sentry Demo..."

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    echo "CocoaPods is not installed. Installing..."
    sudo gem install cocoapods
fi

# Install dependencies
echo "Installing CocoaPods dependencies..."
pod install

echo "Setup complete!"
echo "Open UIKitSentryDemo.xcworkspace in Xcode to build and run the app."
