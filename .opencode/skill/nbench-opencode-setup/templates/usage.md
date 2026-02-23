# N-bench Usage Guide

Task tracking for AI agents. All state lives in `.nbench/`.

## CLI

```bash
.nbench/bin/nbenchctl --help              # All commands
.nbench/bin/nbenchctl <cmd> --help        # Command help
```

## File Structure

```
.nbench/
├── bin/nbenchctl         # CLI (this install)
├── epics/fn-N.json     # Epic metadata
├── specs/fn-N.md       # Epic specifications
├── tasks/fn-N.M.json   # Task metadata
├── tasks/fn-N.M.md     # Task specifications
├── memory/             # Context memory
└── meta.json           # Project metadata
```

Runtime state (status, assignee, evidence) is stored in `.git/flow-state/` (not tracked).

## IDs

- Epics: `fn-N` (e.g., fn-1, fn-2)
- Tasks: `fn-N.M` (e.g., fn-1.1, fn-1.2)

## Common Commands

```bash
# List
.nbench/bin/nbenchctl list               # All epics + tasks grouped
.nbench/bin/nbenchctl epics              # All epics with progress
.nbench/bin/nbenchctl tasks              # All tasks
.nbench/bin/nbenchctl tasks --epic fn-1  # Tasks for epic
.nbench/bin/nbenchctl tasks --status todo # Filter by status

# View
.nbench/bin/nbenchctl show fn-1          # Epic with all tasks
.nbench/bin/nbenchctl show fn-1.2        # Single task
.nbench/bin/nbenchctl cat fn-1           # Epic spec (markdown)
.nbench/bin/nbenchctl cat fn-1.2         # Task spec (markdown)

# Status
.nbench/bin/nbenchctl ready --epic fn-1  # What's ready to work on
.nbench/bin/nbenchctl validate --all     # Check structure
.nbench/bin/nbenchctl state-path         # Show runtime state directory
.nbench/bin/nbenchctl migrate-state --clean  # Optional migration + cleanup

# Create
.nbench/bin/nbenchctl epic create --title "..."
.nbench/bin/nbenchctl task create --epic fn-1 --title "..."

# Work
.nbench/bin/nbenchctl start fn-1.2       # Claim task
.nbench/bin/nbenchctl done fn-1.2 --summary-file s.md --evidence-json e.json
```

## Workflow

1. `.nbench/bin/nbenchctl epics` - list all epics
2. `.nbench/bin/nbenchctl ready --epic fn-N` - find available tasks
3. `.nbench/bin/nbenchctl start fn-N.M` - claim task
4. Implement the task
5. `.nbench/bin/nbenchctl done fn-N.M --summary-file ... --evidence-json ...` - complete

## Evidence JSON Format

```json
{"commits": ["abc123"], "tests": ["npm test"], "prs": []}
```

## More Info

- Human docs: docs/nbenchctl.md
- CLI reference: `.nbench/bin/nbenchctl --help`
