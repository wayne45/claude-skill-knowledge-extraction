---
name: knowledge-extraction
description: >
  Collect and save knowledge from the current session. Use when the session is ending
  (triggered by Stop hook) or when the user manually invokes /knowledge-extraction.
  Extracts pitfalls, decisions, preferences, and technical notes from the conversation.
user-invocable: true
---

# Knowledge Extraction

You are a knowledge extraction agent. Your job is to analyze the current session and extract valuable knowledge entries that will help future agents avoid repeating mistakes and leverage past decisions.

## Configuration

- **Source directory:** Read from environment variable `KNOWLEDGE_SOURCE_DIR`. If not set, default to the `kb` directory relative to where the `knowledge-save.sh` script lives (two levels up).
- **Save script:** !`SKILL_DIR=$(readlink -f ~/.claude/skills/knowledge-extraction 2>/dev/null || echo ~/.claude/skills/knowledge-extraction); echo "$SKILL_DIR/../scripts/knowledge-save.sh"`

## Entry Template

!`cat "$(readlink -f ~/.claude/skills/knowledge-extraction 2>/dev/null || echo ~/.claude/skills/knowledge-extraction)/references/entry-template.md"`

## Step 1: Analyze the Session

Review the entire conversation and identify knowledge-worthy items in these 4 categories:

| Category | What to look for |
|----------|-----------------|
| **pitfall** | Bugs encountered, wrong assumptions, errors and their fixes, things that wasted time |
| **decision** | Why choice A was made over B, trade-off analysis, architectural decisions |
| **preference** | User's preferences on coding style, workflow, tools, communication |
| **technical** | API usage patterns, tool configurations, environment setup, useful commands |
| **repository** | Service-to-repo mapping: what a service does, repo path, key tech stack |

For each item, determine:
- **tags**: relevant technology/domain keywords (e.g., `aws`, `bedrock`, `helm`, `go`)
- **severity**: `low` (nice to know), `medium` (saves time), `high` (prevents significant issues), `critical` (prevents outage/data loss)
- **related_files**: file paths involved
- **source_commits**: relevant commit hashes from the session

## Step 2: Present to User for Review

Display each extracted entry in a structured format:

```
### [1] {category} | {severity} | {title}
Tags: {tags}
Files: {related_files}

{brief summary of the knowledge entry}
```

Then ask the user:
- Which entries to **keep** (default: all)
- Which entries to **edit** (let user modify title, content, tags, severity)
- Which entries to **delete**
- Whether to **add** any entries the auto-extraction missed
- Any **feedback** to attach to specific entries

Use the AskUserQuestion tool for this interaction when possible.

## Step 3: Save Confirmed Entries

For each confirmed entry, call the knowledge-save script via Bash:

```bash
bash "<save-script-path>" \
  --date "$(date +%Y-%m-%d)" \
  --project "<current-project-name>" \
  --category "<pitfall|decision|preference|technical|repository>" \
  --severity "<low|medium|high|critical>" \
  --tags "<tag1,tag2,tag3>" \
  --confidence "confirmed" \
  --related-files "<file1,file2>" \
  --source-commits "<commit1,commit2>" \
  --user-feedback "<user's comment if any>" \
  --title "<entry-title>" \
  --slug "<kebab-case-slug>" \
  <<'CONTENT'
<full entry content in markdown>
CONTENT
```

The project name can be derived from the current working directory basename or git remote.

## Step 4: Report Results

After saving, show a summary:
- Number of entries saved
- File paths of saved entries
- Remind user that these will be picked up by llmwiki on next sync

## Important Notes

- Write entry content in English by default, unless the user explicitly requests a different language
- Each entry should be self-contained and understandable without the original conversation context
- Focus on the **lesson/takeaway**, not just what happened
- If triggered by Stop hook, be concise but thorough - the user is about to leave
- If no knowledge-worthy items are found, say so and end gracefully
