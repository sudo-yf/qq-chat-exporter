#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKSPACE_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
APP_DIR="$WORKSPACE_ROOT/QCEStatusBar.app"
BIN_DIR="$APP_DIR/Contents/MacOS"
RES_DIR="$APP_DIR/Contents/Resources"
SRC="$SCRIPT_DIR/QCEStatusBar.swift"
PLIST="$APP_DIR/Contents/Info.plist"

if [ -x "$BIN_DIR/QCEStatusBar" ] && [ "$BIN_DIR/QCEStatusBar" -nt "$SRC" ]; then
  echo "Built $APP_DIR"
  exit 0
fi

rm -rf "$APP_DIR"
mkdir -p "$BIN_DIR" "$RES_DIR"

cat > "$PLIST" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleExecutable</key><string>QCEStatusBar</string>
  <key>CFBundleIdentifier</key><string>io.nexu.qce.statusbar</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleName</key><string>QCEStatusBar</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
EOF

swiftc -parse-as-library -O -framework Cocoa "$SRC" -o "$BIN_DIR/QCEStatusBar"
chmod +x "$BIN_DIR/QCEStatusBar"
codesign --force --deep --sign - "$APP_DIR" >/dev/null 2>&1 || true
xattr -dr com.apple.quarantine "$APP_DIR" >/dev/null 2>&1 || true
echo "Built $APP_DIR"
