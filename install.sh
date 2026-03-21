#!/bin/bash
set -euo pipefail

REPO="https://raw.githubusercontent.com/tzengyuxio/claude-statusline/main"
SCRIPT_PATH="$HOME/.claude/statusline-command.sh"
SETTINGS_PATH="$HOME/.claude/settings.json"

echo "Installing Claude Code Status Line..."

# Download the script
curl -fsSL -o "$SCRIPT_PATH" "$REPO/statusline-command.sh"
chmod +x "$SCRIPT_PATH"
echo "  ✓ Downloaded statusline-command.sh"

# Check for jq (required for both the statusline and this installer)
if ! command -v jq &> /dev/null; then
    echo "  ✗ jq is required but not installed. Install it with: brew install jq"
    exit 1
fi

# Patch settings.json
STATUSLINE_CONFIG='{"type":"command","command":"~/.claude/statusline-command.sh","padding":1}'

if [ -f "$SETTINGS_PATH" ]; then
    # Merge into existing settings
    tmp=$(mktemp)
    jq --argjson sl "$STATUSLINE_CONFIG" '.statusLine = $sl' "$SETTINGS_PATH" > "$tmp" \
        && mv "$tmp" "$SETTINGS_PATH"
    echo "  ✓ Updated settings.json"
else
    # Create new settings
    mkdir -p "$(dirname "$SETTINGS_PATH")"
    echo "{\"statusLine\":$STATUSLINE_CONFIG}" | jq . > "$SETTINGS_PATH"
    echo "  ✓ Created settings.json"
fi

echo ""
echo "Done! Restart Claude Code to see the status line."
echo "Requires: bash 4.0+, jq, git, and a Nerd Font."
