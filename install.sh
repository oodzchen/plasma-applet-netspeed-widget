#!/usr/bin/env bash

set -e

APPLET_ID="org.kde.netspeedWidget"
TARGET_DIR="$HOME/.local/share/plasma/plasmoids/$APPLET_ID"

echo "Installing Netspeed Widget ($APPLET_ID) to $TARGET_DIR ..."

# Remove old installation completely
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"

# Copy package contents
cp -rf ./package/* "$TARGET_DIR/"

# Remove Plasma cache to make sure plasmashell reloads metadata
if command -v kpackagetool6 &>/dev/null; then
    echo "Registering with kpackagetool6..."
    kpackagetool6 --type Plasma/Applet --upgrade package 2>/dev/null || kpackagetool6 --type Plasma/Applet --install package 2>/dev/null || true
fi

echo "Clearing QML/Plasma cache..."
rm -rf ~/.cache/plasma* ~/.cache/plasmashell* 2>/dev/null || true

if systemctl --user is-active --quiet plasma-plasmashell 2>/dev/null; then
    echo "Restarting plasma-plasmashell to apply changes..."
    systemctl --user restart plasma-plasmashell
fi

echo "Successfully installed $APPLET_ID for Plasma 6!"
