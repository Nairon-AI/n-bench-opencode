---
description: Remove nbench files from project
---

# N-bench Uninstall

Ask the user to confirm in normal chat text:

**Question 1:** "Remove nbench from this project?"
- "Yes, uninstall"
- "Cancel"

If cancel → stop.

**Question 2:** "Keep your .nbench/ tasks and epics?"
- "Yes, keep tasks" → only remove .nbench/bin/, .nbench/usage.md
- "No, remove everything" → remove entire .nbench/

## Execute removal

Run these bash commands as needed:

```bash
# If keeping tasks:
rm -rf .nbench/bin .nbench/usage.md

# If removing everything:
rm -rf .flow

# Always check for Ralph:
rm -rf scripts/ralph
```

For CLAUDE.md and AGENTS.md: if file exists, remove everything between `<!-- BEGIN NBENCH -->` and `<!-- END NBENCH -->` (inclusive).

## Report

```
Removed:
- .nbench/bin/, .nbench/usage.md (or entire .nbench/)
- scripts/ralph/ (if existed)
- N-bench sections from docs (if existed)
```
