#!/usr/bin/env bash

DEST="$HOME/.local/share/plasma/plasmoids/org.kde.netspeedWidget"

mkdir -p "$DEST"
cp -rf ./package/* "$DEST/"

if command -v kpackagetool6 &>/dev/null; then
    kpackagetool6 --type Plasma/Applet --upgrade package 2>/dev/null || kpackagetool6 --type Plasma/Applet --install package 2>/dev/null || true
fi

echo "Installed netspeedWidget to $DEST"
