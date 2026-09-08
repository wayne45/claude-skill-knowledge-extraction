# Knowledge Extraction

A Claude Code skill that collects knowledge from sessions on demand. Type `/done` before exiting to extract pitfalls, decisions, preferences, technical notes, and repository mappings, saving them as Markdown source files for import into a knowledge base (e.g., llmwiki).

## Architecture

```
User types /done → /done skill → /knowledge-extraction skill → Claude analyzes conversation → User reviews/edits → kb/entries/*.md → llmwiki import
```

## Installation

```bash
# Requires jq (macOS: brew install jq)
bash bin/install.sh
```

This will:
- Create `done` and `knowledge-extraction` symlinks in `~/.claude/skills/`
- Add `KNOWLEDGE_SOURCE_DIR` env var to `~/.claude/settings.json`

## Usage

Before ending a session, type `/done` in Claude Code. This triggers the knowledge extraction flow:

### Flow
1. Claude analyzes the current session conversation
2. Extracts knowledge entries (pitfall / decision / preference / technical)
3. Presents entries for user review, editing, deletion, or additions
4. Saves confirmed entries to `kb/entries/`

## Entry Format

Each entry is a Markdown file with YAML frontmatter:

```yaml
---
date: {YYYY-MM-DD}
project: {project-name}
tags: [{tag1}, {tag2}]
category: {pitfall|decision|preference|technical|repository}
severity: {low|medium|high|critical}
confidence: confirmed
user_feedback: ""
related_files:
  - {path/to/file}
source_commits:
  - {commit-hash}
---

## Title

### Context / Problem
...

### Solution / Decision
...

### Lesson / Takeaway
...
```

## Categories

| Category | Description |
|----------|-------------|
| `pitfall` | Bugs, wrong assumptions, errors and their fixes |
| `decision` | Why choice A over B, trade-off analysis |
| `preference` | User's workflow and coding style preferences |
| `technical` | API usage, tool config, environment setup, useful patterns |
| `repository` | Service-to-repo mapping, what it does, repo path, key tech stack |

## Configuration

`bin/config.yaml` contains category definitions and file naming rules.

Override the knowledge base path via environment variable:
```bash
export KNOWLEDGE_SOURCE_DIR=/path/to/custom/kb
```

## Directory Structure

```
knowledge-extraction/
├── README.md
├── bin/
│   ├── install.sh          # Install script
│   ├── uninstall.sh        # Uninstall script
│   └── config.yaml         # System configuration
├── src/
│   ├── skill/              # /knowledge-extraction skill
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── entry-template.md
│   ├── skill-done/         # /done skill
│   │   └── SKILL.md
│   └── scripts/
│       └── knowledge-save.sh
└── kb/
    └── entries/            # Knowledge entries
```

## Uninstall

```bash
bash bin/uninstall.sh
```

Removes the skill and hook but preserves knowledge entries in `kb/entries/`.
