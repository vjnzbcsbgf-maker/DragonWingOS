#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/.vendor"
npm install --prefix "$ROOT/.vendor" --no-save --no-audit --no-fund monaco-editor@0.52.2
mkdir -p "$ROOT/Resources/Monaco/monaco"
rm -rf "$ROOT/Resources/Monaco/monaco/vs"
cp -R "$ROOT/.vendor/node_modules/monaco-editor/min/vs" "$ROOT/Resources/Monaco/monaco/vs"
test -s "$ROOT/Resources/Monaco/monaco/vs/loader.js"
