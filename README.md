# UIKit Sentry Demo

This is a minimal iOS app using UIKit with UIApplicationDelegate and the latest Sentry Cocoa SDK to test UI load spans reporting.

## Features

- Uses UIApplicationDelegate (not UIWindowSceneDelegate) as the main entry point
- Sentry SDK 8.0+ with comprehensive tracing enabled
- UIViewController tracking and tracing enabled
- Auto performance tracking enabled
- User interaction tracing enabled
- Network tracking enabled

## Setup

1. Install CocoaPods if you haven't already:
   ```bash
   sudo gem install cocoapods
   ```

2. Install dependencies:
   ```bash
   cd uikit-ios-demo
   pod install
   ```

3. Open the workspace:
   ```bash
   open UIKitSentryDemo.xcworkspace
   ```

4. Build and run the app on a device or simulator

## Sentry Configuration

The app is configured with the provided Sentry DSN:
- DSN: `https://bd03859ac43e47f1a74c83a5a2b8614b@o88872.ingest.us.sentry.io/6748045`
- Debug mode enabled
- 100% trace sampling rate
- All tracking features enabled

## Testing UI Load Spans

1. Launch the app
2. The app will automatically create test transactions and spans
3. Tap the "Test Sentry" button to generate additional test data
4. Check your Sentry dashboard for:
   - UI load spans
   - View controller tracking
   - Performance transactions
   - User interaction traces

## Key Files

- `AppDelegate.swift` - Main app delegate with Sentry initialization
- `ViewController.swift` - Main view controller with test functionality
- `SceneDelegate.swift` - Scene delegate for iOS 13+ compatibility
- `Main.storyboard` - Main UI layout
- `Podfile` - CocoaPods dependencies

## Troubleshooting

If you're not seeing UI load spans:

1. Ensure the app is running on a device or simulator (not just built)
2. Check that Sentry is properly initialized in AppDelegate
3. Verify the DSN is correct
4. Check Sentry dashboard for any error messages
5. Ensure you're looking at the correct project in Sentry

## Notes

- This app uses UIApplicationDelegate as the main entry point, not UIWindowSceneDelegate
- The app creates a window programmatically in AppDelegate for iOS 12 compatibility
- SceneDelegate is included for iOS 13+ compatibility but the main logic is in AppDelegate
