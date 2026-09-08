#!/bin/bash
# Knowledge Extraction - Install Script
# Installs the knowledge-extraction and done skills into Claude Code.
# Idempotent: safe to run multiple times.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
SKILLS_DIR="$CLAUDE_DIR/skills"
SKILL_LINK="$SKILLS_DIR/knowledge-extraction"
DONE_LINK="$SKILLS_DIR/done"
KB_DIR="$REPO_DIR/kb/entries"

SAVE_SCRIPT="$REPO_DIR/src/scripts/knowledge-save.sh"

echo "=== Knowledge Extraction Installer ==="
echo "Repo: $REPO_DIR"
echo ""

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required. Install with: brew install jq"
    exit 1
fi

# 1. Create kb directory
echo "[1/4] Creating knowledge base directory..."
mkdir -p "$KB_DIR"
echo "  -> $KB_DIR"

# 2. Make scripts executable
echo "[2/4] Setting script permissions..."
chmod +x "$SAVE_SCRIPT"
echo "  -> $SAVE_SCRIPT"

# 3. Create skill symlinks
echo "[3/4] Installing skills..."
mkdir -p "$SKILLS_DIR"

install_skill() {
    local link_path="$1"
    local target="$2"
    local name="$3"
    if [[ -L "$link_path" ]]; then
        rm "$link_path"
    fi
    if [[ -d "$link_path" ]]; then
        echo "  -> Warning: $link_path is a directory, not a symlink. Skipping $name."
    else
        ln -s "$target" "$link_path"
        echo "  -> Symlinked $link_path -> $target"
    fi
}

install_skill "$SKILL_LINK" "$REPO_DIR/src/skill" "knowledge-extraction"
install_skill "$DONE_LINK" "$REPO_DIR/src/skill-done" "done"

# 4. Update settings.json
echo "[4/4] Updating Claude Code settings..."

if [[ ! -f "$SETTINGS_FILE" ]]; then
    echo '{}' > "$SETTINGS_FILE"
fi

KB_PATH="$REPO_DIR/kb"

UPDATED=$(jq \
    --arg kb_path "$KB_PATH" \
    '
    .env.KNOWLEDGE_SOURCE_DIR = $kb_path
    ' "$SETTINGS_FILE")

echo "$UPDATED" > "$SETTINGS_FILE"
echo "  -> Added KNOWLEDGE_SOURCE_DIR=$KB_PATH"

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Usage:"
echo "  - Session end: Type /done to extract knowledge then exit"
echo "  - Manual:      Type /knowledge-extraction in any Claude Code session"
echo "  - Knowledge:   Saved to $KB_DIR/"
echo "  - Uninstall:   bash $SCRIPT_DIR/uninstall.sh"
