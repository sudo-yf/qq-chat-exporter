#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKSPACE_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
QCE_DIR="$WORKSPACE_ROOT/NapCat-QCE-macOS-arm64"
QQ_APP="$QCE_DIR/QQ-QCE.app"
MACOS_DIR="$QQ_APP/Contents/MacOS"
QQ_BIN="$MACOS_DIR/QQ"
REAL_QQ_BIN="$MACOS_DIR/QQ.real"
STATUS_APP="$WORKSPACE_ROOT/QCEStatusBar.app"
STATUS_BUILDER="$WORKSPACE_ROOT/qce-statusbar/build.sh"
WRAPPER_MARKER="QCE_STATUSBAR_BINDING_WRAPPER"

if [ ! -d "$QQ_APP" ]; then
  echo "[QCE] QQ-QCE.app not found: $QQ_APP" >&2
  exit 1
fi

if [ ! -x "$STATUS_BUILDER" ]; then
  echo "[QCE] Status bar builder not found: $STATUS_BUILDER" >&2
  exit 1
fi

if [ ! -e "$REAL_QQ_BIN" ]; then
  if [ ! -x "$QQ_BIN" ]; then
    echo "[QCE] QQ executable not found: $QQ_BIN" >&2
    exit 1
  fi
  if grep -q "$WRAPPER_MARKER" "$QQ_BIN" 2>/dev/null; then
    echo "[QCE] QQ-QCE.app is already wrapped, but QQ.real is missing: $REAL_QQ_BIN" >&2
    echo "[QCE] Please restore a clean QQ-QCE.app before binding again." >&2
    exit 1
  fi
  mv "$QQ_BIN" "$REAL_QQ_BIN"
fi

cat > "$QQ_BIN" <<'EOF'
#!/bin/bash
set -euo pipefail
# QCE_STATUSBAR_BINDING_WRAPPER

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
QCE_DIR="$( cd "$SCRIPT_DIR/../../.." && pwd )"
WORKSPACE_ROOT="$( cd "$QCE_DIR/.." && pwd )"
STATUS_APP="$WORKSPACE_ROOT/QCEStatusBar.app"
STATUS_BUILDER="$WORKSPACE_ROOT/qce-statusbar/build.sh"
REAL_QQ_BIN="$SCRIPT_DIR/QQ.real"
LOG_FILE="$QCE_DIR/qce-statusbar-bind.log"

if [ "${QCE_STATUSBAR_OWNER:-}" = "1" ]; then
  exec -a "$SCRIPT_DIR/QQ" "$REAL_QQ_BIN" "$@"
fi

{
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] QQ-QCE.app opened; delegating to QCEStatusBar.app"
} >> "$LOG_FILE" 2>/dev/null || true

if [ -x "$STATUS_BUILDER" ]; then
  "$STATUS_BUILDER" >> "$LOG_FILE" 2>&1 || true
fi

if [ -d "$STATUS_APP" ]; then
  open -g "$STATUS_APP" >> "$LOG_FILE" 2>&1 || true
  exit 0
fi

osascript -e 'display alert "QCE 菜单栏启动器缺失" message "请在项目根目录双击“打开真实QQ导出器.command”。"' >/dev/null 2>&1 || true
exit 1
EOF

chmod +x "$QQ_BIN" "$REAL_QQ_BIN"

if ! grep -q "$WRAPPER_MARKER" "$QQ_BIN"; then
  echo "[QCE] Failed to install QQ-QCE status bar binding wrapper." >&2
  exit 1
fi

"$STATUS_BUILDER"
if [ ! -d "$STATUS_APP" ]; then
  echo "[QCE] Failed to build status bar app: $STATUS_APP" >&2
  exit 1
fi
codesign --force --deep --sign - "$QQ_APP" >/dev/null 2>&1 || true
xattr -dr com.apple.quarantine "$QQ_APP" "$STATUS_APP" >/dev/null 2>&1 || true

echo "[QCE] QQ-QCE.app is now bound to QCEStatusBar.app"
