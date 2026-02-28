---
name: flux-opencode
description: "Manage .flux/ tasks and epics. Triggers: 'show me my tasks', 'list epics', 'what tasks are there', 'add a task', 'create task', 'what's ready', 'task status', 'show fn-1'. NOT for /flux:plan or /flux:work."
---

# Flux Task Management

Quick task operations in `.flux/`. For planning features use `/flux:plan`, for executing use `/flux:work`.

## Setup

**CRITICAL: fluxctl is BUNDLED — NOT installed globally.** `which fluxctl` will fail (expected). Always use:

```bash
ROOT="$(git rev-parse --show-toplevel)"
OPENCODE_DIR="$ROOT/.opencode"
NBENCHCTL="$OPENCODE_DIR/bin/fluxctl"
```

Then run commands with `$NBENCHCTL <command>`.

**Discover all commands/options:**
```bash
$NBENCHCTL --help
$NBENCHCTL <command> --help   # e.g., $NBENCHCTL task --help
```

## Quick Reference

```bash
# Check if .flow exists
$NBENCHCTL detect --json

# Initialize (if needed)
$NBENCHCTL init --json

# List everything (epics + tasks grouped)
$NBENCHCTL list --json

# List all epics
$NBENCHCTL epics --json

# List all tasks (or filter by epic/status)
$NBENCHCTL tasks --json
$NBENCHCTL tasks --epic fn-1 --json
$NBENCHCTL tasks --status todo --json

# View epic with all tasks
$NBENCHCTL show fn-1 --json
$NBENCHCTL cat fn-1              # Spec markdown

# View single task
$NBENCHCTL show fn-1.2 --json
$NBENCHCTL cat fn-1.2            # Task spec

# What's ready to work on?
$NBENCHCTL ready --epic fn-1 --json

# Create task under existing epic
$NBENCHCTL task create --epic fn-1 --title "Fix bug X" --json

# Set task description (from file)
echo "Description here" > /tmp/desc.md
$NBENCHCTL task set-description fn-1.2 --file /tmp/desc.md --json

# Set acceptance criteria (from file)
echo "- [ ] Criterion 1" > /tmp/accept.md
$NBENCHCTL task set-acceptance fn-1.2 --file /tmp/accept.md --json

# Start working on task
$NBENCHCTL start fn-1.2 --json

# Mark task done
echo "What was done" > /tmp/summary.md
echo '{"commits":["abc123"],"tests":["npm test"],"prs":[]}' > /tmp/evidence.json
$NBENCHCTL done fn-1.2 --summary-file /tmp/summary.md --evidence-json /tmp/evidence.json --json

# Validate structure
$NBENCHCTL validate --epic fn-1 --json
$NBENCHCTL validate --all --json
```

## Common Patterns

### "Add a task for X"

1. Find relevant epic:
   ```bash
   # List all epics
   $NBENCHCTL epics --json

   # Or show a specific epic to check its scope
   $NBENCHCTL show fn-1 --json
   ```

2. Create task:
   ```bash
   $NBENCHCTL task create --epic fn-N --title "Short title" --json
   ```

3. Add description:
   ```bash
   cat > /tmp/desc.md << 'EOF'
   **Bug/Feature:** Brief description

   **Details:**
   - Point 1
   - Point 2
   EOF
   $NBENCHCTL task set-description fn-N.M --file /tmp/desc.md --json
   ```

4. Add acceptance:
   ```bash
   cat > /tmp/accept.md << 'EOF'
   - [ ] Criterion 1
   - [ ] Criterion 2
   EOF
   $NBENCHCTL task set-acceptance fn-N.M --file /tmp/accept.md --json
   ```

### "What tasks are there?"

```bash
# All epics
$NBENCHCTL epics --json

# All tasks
$NBENCHCTL tasks --json

# Tasks for specific epic
$NBENCHCTL tasks --epic fn-1 --json

# Ready tasks for an epic
$NBENCHCTL ready --epic fn-1 --json
```

### "Show me task X"

```bash
$NBENCHCTL show fn-1.2 --json   # Metadata
$NBENCHCTL cat fn-1.2           # Full spec
```

### Create new epic (rare - usually via /flux:plan)

```bash
$NBENCHCTL epic create --title "Epic title" --json
# Returns: {"success": true, "id": "fn-N", ...}
```

## ID Format

- Epic: `fn-N` (e.g., `fn-1`, `fn-42`)
- Task: `fn-N.M` (e.g., `fn-1.1`, `fn-42.7`)

## Notes

- Run `$NBENCHCTL --help` to discover all commands and options
- All writes go through fluxctl (don't edit JSON/MD files directly)
- `--json` flag gives machine-readable output
- For complex planning/execution, use `/flux:plan` and `/flux:work`
