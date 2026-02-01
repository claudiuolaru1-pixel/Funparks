#!/usr/bin/env bash
set -euo pipefail
# Usage: scripts/capture_screenshots.sh <device_id> [locale]
# Example: ./scripts/capture_screenshots.sh emulator-5554 en
DEVICE=${1:-}
LOCALE=${2:-en}
if [ -z "$DEVICE" ]; then
  echo "Please pass a device id (flutter devices)"; exit 1;
fi
flutter -d "$DEVICE" test integration_test/screenshot_test.dart --dart-define=APP_LOCALE=$LOCALE
echo "Screenshots saved under build/integration_test/"
