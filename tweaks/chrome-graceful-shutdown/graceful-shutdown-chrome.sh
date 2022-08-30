#!/usr/bin/env bash
set -euo pipefail
PID="$(/usr/bin/pkill --oldest --signal 0 --echo -f /app/extra/chrome | grep -Eo '[0-9]+')"
kill -TERM "$PID" && wait "$PID"
