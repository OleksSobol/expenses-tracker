#!/usr/bin/env bash
# Auto-increments build number in pubspec.yaml, then runs flutter build apk.
# Usage: ./build.sh [extra flutter build apk flags]

set -e

PUBSPEC="pubspec.yaml"

# Extract current build number (the part after '+')
current=$(grep '^version:' "$PUBSPEC" | sed 's/.*+//')
next=$((current + 1))

# Replace the build number in pubspec.yaml
sed -i "s/^\(version:.*+\)${current}$/\1${next}/" "$PUBSPEC"

echo "Build number: $current → $next"

flutter build apk "$@"
