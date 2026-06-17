# iOS Project Status

## Current status

- `NANYEN.xcodeproj` has been created.
- Xcode recognizes these schemes:
  - `NANYEN`
  - `NANYENCore`
- The project currently builds from the existing SwiftUI and core source files.

## Current blocker

Xcode itself is installed, but the iOS platform component is not installed yet.

Observed build error:

```text
iOS 26.5 is not installed. Please download and install the platform from Xcode > Settings > Components.
```

## User action needed

1. Open Xcode.
2. In the top menu, open `Xcode` > `Settings...`.
3. Open the `Components` tab.
4. Find `iOS 26.5` or the latest available `iOS` platform.
5. Click the download/install button.
6. Wait until installation finishes.
7. Tell Codex: `iOSコンポーネント入れました`.

## Next Codex action after that

Run:

```bash
xcodebuild -project NANYEN.xcodeproj -scheme NANYEN -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO
```

Then continue with:

1. Add SwiftData persistence.
2. Run the app in Simulator.
3. Prepare TestFlight/App Store configuration.
