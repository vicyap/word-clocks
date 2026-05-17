#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA_DIR="$ROOT_DIR/.build/xcode"
BUILT_APP="$DERIVED_DATA_DIR/Build/Products/Debug/WordClocksMac.app"
DIST_DIR="$ROOT_DIR/dist"
DIST_APP="$DIST_DIR/WordClocksMac.app"
APP_NAME="WordClocksMac"
BUNDLE_ID="com.vicyap.WordClocks"
MODE="${1:-run}"

if [ "$#" -gt 1 ]; then
  echo "Usage: $0 [run|--debug|--logs|--telemetry|--verify]" >&2
  exit 2
fi

cd "$ROOT_DIR"

"$ROOT_DIR/script/setup.sh"

pkill -x "$APP_NAME" >/dev/null 2>&1 || true

xcodebuild \
  -project "$ROOT_DIR/WordClocks.xcodeproj" \
  -scheme WordClocksMac \
  -configuration Debug \
  -destination "platform=macOS" \
  -derivedDataPath "$DERIVED_DATA_DIR" \
  build

mkdir -p "$DIST_DIR"
rm -rf "$DIST_APP"
ditto "$BUILT_APP" "$DIST_APP"
/System/Library/Frameworks/CoreServices.framework/Versions/Current/Frameworks/LaunchServices.framework/Versions/Current/Support/lsregister \
  -f \
  -R \
  -trusted \
  "$DIST_APP"

open_app() {
  /usr/bin/open -n "$DIST_APP"
}

case "$MODE" in
  run)
    open_app
    ;;
  --debug|debug)
    lldb -- "$DIST_APP/Contents/MacOS/$APP_NAME"
    ;;
  --logs|logs)
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --telemetry|telemetry)
    open_app
    /usr/bin/log stream --info --style compact --predicate "subsystem == \"$BUNDLE_ID\""
    ;;
  --verify|verify)
    open_app
    for _ in {1..20}; do
      if pgrep -x "$APP_NAME" >/dev/null 2>&1; then
        echo "$APP_NAME is running."
        exit 0
      fi
      sleep 0.25
    done

    echo "$APP_NAME did not start within the verification window." >&2
    exit 1
    ;;
  *)
    echo "Usage: $0 [run|--debug|--logs|--telemetry|--verify]" >&2
    exit 2
    ;;
esac
