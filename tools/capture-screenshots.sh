#!/bin/bash
# Captures App Store / marketing screenshots by launching the app with
# `--uiScreenshotMode` and friends, then snapping the simulator screen.
#
# Usage: ./tools/capture-screenshots.sh
# Output: marketing/screenshots/*.png at 1320 × 2868 (iPhone 16 Pro Max).
set -euo pipefail

BUNDLE_ID="com.michw.shroomsweeper"
DEVICE_NAME="iPhone 16 Pro Max"
APP_NAME="shroomsweeper"
OUT_DIR="marketing/screenshots"
DERIVED="$(pwd)/.screenshot-build"

# --- Find or create the simulator ---------------------------------------------
DEVICE_UDID=$(xcrun simctl list devices available \
  | awk -v name="$DEVICE_NAME" '$0 ~ name {print}' \
  | grep -oE "[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}" \
  | head -1)

if [ -z "$DEVICE_UDID" ]; then
  echo "✗ No '$DEVICE_NAME' simulator found."
  echo "  Open Xcode → Window → Devices and Simulators → + to create one."
  exit 1
fi

echo "→ Using simulator $DEVICE_UDID ($DEVICE_NAME)"

# --- Boot --------------------------------------------------------------------
xcrun simctl boot "$DEVICE_UDID" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE_UDID" -b >/dev/null

# --- Build -------------------------------------------------------------------
echo "→ Building for simulator…"
xcodebuild \
  -project shroomsweeper.xcodeproj \
  -scheme shroomsweeper \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$DEVICE_UDID" \
  -derivedDataPath "$DERIVED" \
  -quiet \
  build

APP_PATH=$(find "$DERIVED" -type d -name "$APP_NAME.app" -path "*Debug-iphonesimulator*" | head -1)
if [ -z "$APP_PATH" ]; then
  echo "✗ Could not locate built $APP_NAME.app under $DERIVED"
  exit 1
fi
echo "→ App built at $APP_PATH"

# --- Install -----------------------------------------------------------------
xcrun simctl install "$DEVICE_UDID" "$APP_PATH"
mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR"/*.png

# --- Pretty status bar (Apple's classic 9:41 layout) -------------------------
xcrun simctl status_bar "$DEVICE_UDID" override \
  --time "9:41" \
  --dataNetwork wifi \
  --wifiMode active \
  --wifiBars 3 \
  --cellularMode active \
  --cellularBars 4 \
  --batteryState charged \
  --batteryLevel 100

# --- Capture helper ----------------------------------------------------------
capture() {
  local target="$1"
  local filename="$2"
  local appearance="${3:-forest}"

  xcrun simctl terminate "$DEVICE_UDID" "$BUNDLE_ID" 2>/dev/null || true

  local args=("--uiScreenshotMode" "--uiScreenshotTarget" "$target")
  if [ "$appearance" = "twilight" ]; then
    args+=("--uiAppearance" "twilight")
  fi

  xcrun simctl launch "$DEVICE_UDID" "$BUNDLE_ID" "${args[@]}" >/dev/null
  sleep 2.5
  xcrun simctl io "$DEVICE_UDID" screenshot "$OUT_DIR/$filename"
  echo "  ✓ $filename"
}

echo "→ Capturing forest (light) screenshots…"
capture "home"     "01-home.png"
capture "game"     "02-game.png"
capture "tutorial" "03-tutorial.png"
capture "win"      "04-win.png"
capture "scores"   "05-scores.png"

echo "→ Capturing twilight (dark) screenshots…"
capture "home"     "01-home-night.png"     "twilight"
capture "game"     "02-game-night.png"     "twilight"
capture "tutorial" "03-tutorial-night.png" "twilight"
capture "win"      "04-win-night.png"      "twilight"
capture "scores"   "05-scores-night.png"   "twilight"

xcrun simctl terminate "$DEVICE_UDID" "$BUNDLE_ID" 2>/dev/null || true

echo ""
echo "Done. Screenshots in $OUT_DIR/"
