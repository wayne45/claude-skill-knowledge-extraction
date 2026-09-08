#!/bin/bash
# Knowledge Extraction - Save Script
# Creates a knowledge entry markdown file with YAML frontmatter.
# Content is read from stdin; metadata is passed as arguments.

set -euo pipefail

# Defaults
DATE=""
PROJECT=""
CATEGORY=""
SEVERITY="medium"
TAGS=""
CONFIDENCE="confirmed"
RELATED_FILES=""
SOURCE_COMMITS=""
USER_FEEDBACK=""
TITLE=""
SLUG=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --date) DATE="$2"; shift 2 ;;
        --project) PROJECT="$2"; shift 2 ;;
        --category) CATEGORY="$2"; shift 2 ;;
        --severity) SEVERITY="$2"; shift 2 ;;
        --tags) TAGS="$2"; shift 2 ;;
        --confidence) CONFIDENCE="$2"; shift 2 ;;
        --related-files) RELATED_FILES="$2"; shift 2 ;;
        --source-commits) SOURCE_COMMITS="$2"; shift 2 ;;
        --user-feedback) USER_FEEDBACK="$2"; shift 2 ;;
        --title) TITLE="$2"; shift 2 ;;
        --slug) SLUG="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

if [[ -z "$DATE" || -z "$CATEGORY" || -z "$TITLE" || -z "$SLUG" ]]; then
    echo "Error: --date, --category, --title, and --slug are required" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENTRIES_DIR="${KNOWLEDGE_SOURCE_DIR:-$REPO_DIR/kb}/raw/sources"
mkdir -p "$ENTRIES_DIR"

DATE_COMPACT="${DATE//-/}"

FILENAME="${CATEGORY}_${SLUG}_${DATE_COMPACT}.md"
FILEPATH="$ENTRIES_DIR/$FILENAME"

# Build YAML frontmatter
{
    echo "---"
    echo "date: $DATE"
    [[ -n "$PROJECT" ]] && echo "project: $PROJECT"

    # Tags as YAML array
    if [[ -n "$TAGS" ]]; then
        echo -n "tags: ["
        IFS=',' read -ra TAG_ARRAY <<< "$TAGS"
        FIRST=true
        for tag in "${TAG_ARRAY[@]}"; do
            tag=$(echo "$tag" | xargs)
            if $FIRST; then
                echo -n "$tag"
                FIRST=false
            else
                echo -n ", $tag"
            fi
        done
        echo "]"
    fi

    echo "category: $CATEGORY"
    echo "severity: $SEVERITY"
    echo "confidence: $CONFIDENCE"
    [[ -n "$USER_FEEDBACK" ]] && echo "user_feedback: \"$USER_FEEDBACK\""

    # Related files as YAML array
    if [[ -n "$RELATED_FILES" ]]; then
        echo "related_files:"
        IFS=',' read -ra FILE_ARRAY <<< "$RELATED_FILES"
        for f in "${FILE_ARRAY[@]}"; do
            f=$(echo "$f" | xargs)
            echo "  - $f"
        done
    fi

    # Source commits as YAML array
    if [[ -n "$SOURCE_COMMITS" ]]; then
        echo "source_commits:"
        IFS=',' read -ra COMMIT_ARRAY <<< "$SOURCE_COMMITS"
        for c in "${COMMIT_ARRAY[@]}"; do
            c=$(echo "$c" | xargs)
            echo "  - $c"
        done
    fi

    echo "---"
    echo ""
} > "$FILEPATH"

# Append content from stdin
cat >> "$FILEPATH"

echo "$FILEPATH"
