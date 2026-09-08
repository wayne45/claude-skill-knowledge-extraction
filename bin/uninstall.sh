#!/bin/bash
# Knowledge Extraction - Uninstall Script
# Removes skill symlinks and env var from Claude Code settings.
# Does NOT delete knowledge entries in kb/entries/.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
SKILL_LINK="$CLAUDE_DIR/skills/knowledge-extraction"
DONE_LINK="$CLAUDE_DIR/skills/done"

echo "=== Knowledge Extraction Uninstaller ==="
echo ""

# 1. Remove skill symlinks
echo "[1/2] Removing skills..."

remove_skill() {
    local link_path="$1"
    local name="$2"
    if [[ -L "$link_path" ]]; then
        rm "$link_path"
        echo "  -> Removed $name symlink"
    elif [[ -e "$link_path" ]]; then
        echo "  -> Warning: $link_path exists but is not a symlink. Skipping."
    else
        echo "  -> $name not installed, nothing to remove"
    fi
}

remove_skill "$SKILL_LINK" "knowledge-extraction"
remove_skill "$DONE_LINK" "done"

# 2. Update settings.json
echo "[2/2] Updating Claude Code settings..."

if [[ ! -f "$SETTINGS_FILE" ]]; then
    echo "  -> No settings.json found, nothing to update"
else
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required. Install with: brew install jq"
        exit 1
    fi

    UPDATED=$(jq '
        del(.env.KNOWLEDGE_SOURCE_DIR)
        ' "$SETTINGS_FILE")

    echo "$UPDATED" > "$SETTINGS_FILE"
    echo "  -> Removed KNOWLEDGE_SOURCE_DIR"
fi

echo ""
echo "=== Uninstall Complete ==="
echo ""
echo "Note: Knowledge entries in $REPO_DIR/kb/entries/ were preserved."
echo "      Delete them manually if no longer needed."