---
description: Remove flux files from project
---

# Flux Uninstall

Ask the user to confirm in normal chat text:

**Question 1:** "Remove flux from this project?"
- "Yes, uninstall"
- "Cancel"

If cancel → stop.

**Question 2:** "Keep your .flux/ tasks and epics?"
- "Yes, keep tasks" → only remove .flux/bin/, .flux/usage.md
- "No, remove everything" → remove entire .flux/

## Execute removal

Run these bash commands as needed:

```bash
# If keeping tasks:
rm -rf .flux/bin .flux/usage.md

# If removing everything:
rm -rf .flow

# Always check for Ralph:
rm -rf scripts/ralph
```

For CLAUDE.md and AGENTS.md: if file exists, remove everything between `<!-- BEGIN NBENCH -->` and `<!-- END NBENCH -->` (inclusive).

## Report

```
Removed:
- .flux/bin/, .flux/usage.md (or entire .flux/)
- scripts/ralph/ (if existed)
- Flux sections from docs (if existed)
```
