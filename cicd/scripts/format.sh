#!/usr/bin/env bash
# Format all Dart sources in the suite.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "Formatting backend..."
dart format "$ROOT/backend"

echo "Formatting frontend..."
( cd "$ROOT/frontend" && dart format lib )

echo "Done."
