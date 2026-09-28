#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="$1"

if [ -z "$VERSION" ]; then
    if [ -f "$SCRIPT_DIR/package/metadata.json" ]; then
        VERSION="$(jq -r '.KPlugin.Version // empty' "$SCRIPT_DIR/package/metadata.json" 2>/dev/null || grep -oP '"Version":\s*"\K[^"]+' "$SCRIPT_DIR/package/metadata.json" || true)"
    fi
fi

if [ -z "$VERSION" ]; then
    echo "Usage: $0 [version]"
    exit 1
fi

OUTPUT_FILE="$SCRIPT_DIR/netspeed-widget-$VERSION.plasmoid"

if [ -e "$OUTPUT_FILE" ]; then
    echo "Warning: File \`netspeed-widget-$VERSION.plasmoid\` already exists, overwriting..."
    rm -f "$OUTPUT_FILE"
fi

pushd "$SCRIPT_DIR/package" > /dev/null

zip -r "$OUTPUT_FILE" *

popd > /dev/null

echo "Successfully packaged to $OUTPUT_FILE"
