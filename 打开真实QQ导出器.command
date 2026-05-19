#!/bin/bash
set -euo pipefail
WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
STATUS_BINDER="$WORKDIR/scripts/bind-qq-qce-statusbar.sh"
APP="$WORKDIR/QCEStatusBar.app"

"$STATUS_BINDER"
open "$APP"
