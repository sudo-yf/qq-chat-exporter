#!/bin/bash
set -euo pipefail
WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
QCE_DIR="$WORKDIR/NapCat-QCE-macOS-arm64"

osascript -e 'tell application id "io.nexu.qce.statusbar" to quit' >/dev/null 2>&1 || true
cd "$QCE_DIR"
./stop-qce-real.sh || true
pkill -f "$WORKDIR/QCEStatusBar.app/Contents/MacOS/QCEStatusBar" >/dev/null 2>&1 || true
echo
echo "菜单栏 QCE 已关闭。"
echo "按任意键关闭窗口。"
read -r -n 1 _ || true
