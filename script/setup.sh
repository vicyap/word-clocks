#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v xcodegen >/dev/null 2>&1; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "xcodegen is required, but Homebrew is not installed." >&2
    echo "Install XcodeGen manually, then rerun this script." >&2
    exit 1
  fi

  brew bundle --file "$ROOT_DIR/Brewfile"
fi

xcodegen generate --spec "$ROOT_DIR/project.yml"
