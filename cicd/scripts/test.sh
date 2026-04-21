#!/usr/bin/env bash
# Run the full test matrix for the suite.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "=== Backend analyze ==="
dart analyze "$ROOT/backend"

if [ -d "$ROOT/backend/test" ]; then
  echo "=== Backend tests ==="
  dart test "$ROOT/backend"
else
  echo "No backend/test directory; skipping."
fi

echo "=== Frontend analyze + test ==="
(
  cd "$ROOT/frontend"
  flutter pub get
  flutter analyze
  flutter test
)

echo "All checks passed."
