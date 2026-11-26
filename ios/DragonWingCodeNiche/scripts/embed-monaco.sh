#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="${1:?Usage: embed-monaco.sh /path/to/App.app}"
SOURCE="$ROOT/Resources/Monaco/monaco/vs"
DEST="$APP_PATH/Monaco/monaco/vs"

test -s "$ROOT/Resources/Monaco/index.html"
test -s "$SOURCE/loader.js"
mkdir -p "$APP_PATH/Monaco/monaco"
rm -rf "$DEST"
ditto "$SOURCE" "$DEST"
test -s "$DEST/loader.js"
echo "Embedded Monaco assets:"
du -sh "$DEST"
