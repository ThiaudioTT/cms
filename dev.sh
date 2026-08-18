#!/usr/bin/env bash
# Runs the CMS locally and opens the admin in your browser. decap-server (port 8081) writes
# to this working tree; the static server (port 8080) serves the admin page. Ctrl-C stops both.
set -euo pipefail
cd "$(dirname "$0")"
trap 'kill 0' EXIT INT TERM

npx --yes decap-server &
python3 -m http.server 8080 --bind 127.0.0.1 --directory . >/dev/null &

# Wait for both ports before opening, or Decap boots without seeing the proxy and offers a
# GitHub login instead of the local backend.
(
  until (exec 3<>/dev/tcp/127.0.0.1/8081) 2>/dev/null && (exec 3<>/dev/tcp/127.0.0.1/8080) 2>/dev/null; do
    sleep 0.5
  done
  xdg-open http://127.0.0.1:8080/admin/ >/dev/null 2>&1 || true
) &

echo "CMS → http://127.0.0.1:8080/admin/"
wait
