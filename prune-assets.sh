#!/usr/bin/env bash
# Lists images in assets/uploads that nothing in content/ references.
# Dry-run by default; pass --delete to remove them. Usage: ./prune-assets.sh [--delete]
set -euo pipefail
cd "$(dirname "$0")"
shopt -s nullglob nocaseglob

delete=${1:-}
orphans=()
for f in assets/uploads/*.{png,jpg,jpeg,gif,webp,svg,avif}; do
  # ponytail: full public path, not basename — "demo.png" must not match "hanoi-demo.png"
  grep -rqF "/$f" content/ || orphans+=("$f")
done

if [ ${#orphans[@]} -eq 0 ]; then
  echo "✓ no unused images"
  exit 0
fi

for f in "${orphans[@]}"; do
  if [ "$delete" = --delete ]; then
    rm -- "$f"
    echo "  deleted — $f"
  else
    echo "  unused  — $f"
  fi
done

if [ "$delete" = --delete ]; then
  echo "✓ removed ${#orphans[@]} unused image(s)"
else
  echo
  echo "${#orphans[@]} unused image(s). Re-run with --delete to remove them."
fi
