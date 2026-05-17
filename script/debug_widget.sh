#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA_DIR="$ROOT_DIR/.build/xcode"

cd "$ROOT_DIR"

"$ROOT_DIR/script/setup.sh"

xcodebuild \
  -project "$ROOT_DIR/WordClocks.xcodeproj" \
  -scheme WordClocksWidgetsExtension \
  -configuration Debug \
  -destination "platform=macOS" \
  -derivedDataPath "$DERIVED_DATA_DIR" \
  build

open "$ROOT_DIR/WordClocks.xcodeproj"

cat <<'MESSAGE'
Built the widget extension.

To inspect it in Xcode:
1. Select the WordClocksWidgetsExtension scheme.
2. Run it and choose the WidgetKit host when Xcode prompts.
3. Use the macOS widget gallery to add "Three Word Clock" to the desktop.
MESSAGE
