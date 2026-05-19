#!/bin/bash
set -euo pipefail
WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_BUILDER="$WORKDIR/qce-statusbar/build.sh"
APP="$WORKDIR/QCEStatusBar.app"

"$APP_BUILDER"
open "$APP"
