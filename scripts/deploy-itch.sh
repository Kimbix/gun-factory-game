#!/usr/bin/env bash
set -euo pipefail

GODOT="${GODOT:-godot}"
BUTLER="${BUTLER:-butler}"

ITCH_USER="meatboxdev"
ITCH_GAME="kimbixs-secret-factory-game-project"
ITCH_CHANNEL="linux"
DISCORD_WEBHOOK_FILE="$(dirname "$0")/../.discord_webhook"
if [ -f "$DISCORD_WEBHOOK_FILE" ]; then
  DISCORD_WEBHOOK=$(cat "$DISCORD_WEBHOOK_FILE")
else
  DISCORD_WEBHOOK=""
fi

BUILD_DIR="bin"

VERSION=$(cat version.txt)
EXPORT_PATH="$BUILD_DIR/game_prototype_$VERSION.x86_64"

echo ""
echo "=== Deploying $ITCH_USER/$ITCH_GAME:$ITCH_CHANNEL (version: $VERSION) ==="
echo ""

echo "$VERSION" > version.txt

echo "--- Exporting Linux build ---"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
$GODOT --headless --export-release "Linux Prototype Build" "$EXPORT_PATH"

echo ""
echo "--- Pushing to itch.io ---"
$BUTLER push "$BUILD_DIR" "$ITCH_USER/$ITCH_GAME:$ITCH_CHANNEL" --userversion "$VERSION"

echo ""
echo "--- Notifying Discord ---"
curl -sf -X POST "$DISCORD_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{\"content\":\"Build $VERSION is up at <https://meatboxdev.itch.io/kimbixs-secret-factory-game-project>\"}" \
  && echo "Discord notified" || echo "Discord notification failed (webhook might be invalid)"

echo ""
echo "=== Done! ==="
