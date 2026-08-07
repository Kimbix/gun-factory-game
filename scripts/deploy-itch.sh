#!/usr/bin/env bash
set -euo pipefail

GODOT="${GODOT:-godot}"
BUTLER="${BUTLER:-butler}"

ITCH_USER="meatboxdev"
ITCH_GAME="kimbixs-secret-factory-game-project"
LINUX_CHANNEL="linux"
WINDOWS_CHANNEL="windows"
DISCORD_WEBHOOK_FILE="$(dirname "$0")/../.discord_webhook"
if [ -f "$DISCORD_WEBHOOK_FILE" ]; then
  DISCORD_WEBHOOK=$(cat "$DISCORD_WEBHOOK_FILE")
else
  DISCORD_WEBHOOK=""
fi

BUILD_DIR="bin"

VERSION=$(cat version.txt)
LINUX_EXPORT_PATH="$BUILD_DIR/linux/game_prototype_$VERSION.x86_64"
WINDOWS_EXPORT_PATH="$BUILD_DIR/windows/game_prototype_$VERSION.exe"

echo ""
echo "=== Deploying $ITCH_USER/$ITCH_GAME (version: $VERSION) ==="
echo ""

echo "$VERSION" > version.txt

echo "--- Exporting Linux build ---"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/linux" "$BUILD_DIR/windows"
$GODOT --headless --export-release "Linux Prototype Build" "$LINUX_EXPORT_PATH"

echo "--- Exporting Windows build ---"
$GODOT --headless --export-release "Windows Desktop" "$WINDOWS_EXPORT_PATH"

echo ""
echo "--- Pushing to itch.io ---"
$BUTLER push "$BUILD_DIR/linux" "$ITCH_USER/$ITCH_GAME:$LINUX_CHANNEL" --userversion "$VERSION"
$BUTLER push "$BUILD_DIR/windows" "$ITCH_USER/$ITCH_GAME:$WINDOWS_CHANNEL" --userversion "$VERSION"

echo ""
echo "--- Notifying Discord ---"
curl -sf -X POST "$DISCORD_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{\"content\":\"Build $VERSION is up at <https://meatboxdev.itch.io/kimbixs-secret-factory-game-project>\"}" \
  && echo "Discord notified" || echo "Discord notification failed (webhook might be invalid)"

echo ""
echo "=== Done! ==="
