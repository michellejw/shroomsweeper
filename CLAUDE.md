# Shroomsweeper — notes for Claude

## App Store / marketing screenshots

**Don't rebuild this — it exists.** Run `./tools/capture-screenshots.sh` from the
project root. It builds the app, boots the iPhone 16 Pro Max simulator, captures
ten 1320×2868 PNGs to `marketing/screenshots/` (5 forest + 5 twilight), and
overrides the status bar to Apple's classic 9:41 layout.

How it works:
- `Screenshots/ScreenshotMode.swift` reads launch arguments
  (`--uiScreenshotMode`, `--uiScreenshotTarget <name>`, `--uiAppearance twilight`).
- `AppState.init()` checks `ScreenshotMode.isActive` and seeds the right
  screen + state (skips welcome/loading, seeds `ScoreStore`, jumps to a
  pre-played `Game`, opens the scores sheet, etc.).
- Seeding lives in `// MARK: - Screenshot seeding` extensions at the bottom of
  `Game.swift`, `ScoreStore.swift`, and `TutorialFlow.swift`.

Targets supported: `home`, `game`, `tutorial`, `win`, `scores` (plus
`--uiAppearance twilight` for night-mode variants).

If a screenshot needs to change, edit the seed in the relevant `// MARK:`
section and re-run the script — don't add new mocks or fixture views.

## ShroomKit package quirk

ShroomKit is a local Swift package at `~/dev/games/shroomkit` (relative path
in pbxproj). The xcode-tools `BuildProject` MCP **cannot** resolve it and will
fail with "Missing package product 'ShroomKit'". Use `xcodebuild` directly
(`xcodebuild -project shroomsweeper.xcodeproj -scheme shroomsweeper …`) — it
resolves packages correctly.

## Project layout

- Sources use Xcode 16+ synchronized root group, so new files dropped into
  `shroomsweeper/<subdir>/` are auto-picked-up. No pbxproj edits needed.
- No test target currently exists. The screenshot capture flow uses launch
  arguments + `xcrun simctl io screenshot`, not XCUITests.
