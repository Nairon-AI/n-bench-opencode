# Flux Usage Guide

Task tracking for AI agents. All state lives in `.flux/`.

## CLI

```bash
.flux/bin/fluxctl --help              # All commands
.flux/bin/fluxctl <cmd> --help        # Command help
```

## File Structure

```
.flux/
├── bin/fluxctl         # CLI (this install)
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
.flux/bin/fluxctl list               # All epics + tasks grouped
.flux/bin/fluxctl epics              # All epics with progress
.flux/bin/fluxctl tasks              # All tasks
.flux/bin/fluxctl tasks --epic fn-1  # Tasks for epic
.flux/bin/fluxctl tasks --status todo # Filter by status

# View
.flux/bin/fluxctl show fn-1          # Epic with all tasks
.flux/bin/fluxctl show fn-1.2        # Single task
.flux/bin/fluxctl cat fn-1           # Epic spec (markdown)
.flux/bin/fluxctl cat fn-1.2         # Task spec (markdown)

# Status
.flux/bin/fluxctl ready --epic fn-1  # What's ready to work on
.flux/bin/fluxctl validate --all     # Check structure
.flux/bin/fluxctl state-path         # Show runtime state directory
.flux/bin/fluxctl migrate-state --clean  # Optional migration + cleanup

# Create
.flux/bin/fluxctl epic create --title "..."
.flux/bin/fluxctl task create --epic fn-1 --title "..."

# Work
.flux/bin/fluxctl start fn-1.2       # Claim task
.flux/bin/fluxctl done fn-1.2 --summary-file s.md --evidence-json e.json
```

## Workflow

1. `.flux/bin/fluxctl epics` - list all epics
2. `.flux/bin/fluxctl ready --epic fn-N` - find available tasks
3. `.flux/bin/fluxctl start fn-N.M` - claim task
4. Implement the task
5. `.flux/bin/fluxctl done fn-N.M --summary-file ... --evidence-json ...` - complete

## Evidence JSON Format

```json
{"commits": ["abc123"], "tests": ["npm test"], "prs": []}
```

## More Info

- Human docs: docs/fluxctl.md
- CLI reference: `.flux/bin/fluxctl --help`
