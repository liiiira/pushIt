#!/usr/bin/env sh
# Local gate: run before every push (docs/CONVENTIONS.md §10).
set -eu
cd "$(dirname "$0")/.."

echo '==> gen-l10n'
flutter gen-l10n
echo '==> format'
dart format --output=none --set-exit-if-changed .
echo '==> analyze'
flutter analyze --fatal-infos
echo '==> test'
flutter test

echo 'All checks passed.'
