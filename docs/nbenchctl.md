# nbenchctl CLI Reference

CLI for `.nbench/` task tracking. Agents must use nbenchctl for all writes.

> **Note:** This is the full human reference. Agents should read `.nbench/usage.md` (created by `/nbench:setup`).

## Available Commands

```
init, detect, epic, task, dep, show, epics, tasks, list, cat, ready, next, start, done, block, validate, config, memory, prep-chat, rp, opencode, codex, checkpoint, status, state-path, migrate-state
```

## Multi-User Safety

Works out of the box for parallel branches. No setup required.

- **ID allocation**: Scans existing files to determine next ID (merge-safe)
- **Soft claims**: Tasks have `assignee` field to prevent duplicate work
- **Actor resolution**: `FLOW_ACTOR` env → git email → git name → `$USER` → "unknown"
- **Local validation**: `nbenchctl validate --all` catches issues before commit

**Optional**: Add CI gate with `docs/ci-workflow-example.yml` to block bad PRs.

## Runtime State (Worktrees)

Runtime task state (status, assignee, evidence) lives in `.git/flow-state/` and is shared across worktrees.
Definition files (title, deps, specs) remain in `.nbench/` and are tracked in git.

State directory resolution:
1. `FLOW_STATE_DIR` env (override)
2. `git --git-common-dir` + `/flow-state` (worktree-aware)
3. `.nbench/state` fallback (non-git)

Useful commands:
```bash
nbenchctl state-path            # Show resolved state directory
nbenchctl migrate-state         # Migrate existing repo (optional)
nbenchctl migrate-state --clean # Migrate + remove runtime from tracked files
```

## File Structure

```
.nbench/
├── meta.json          # {schema_version, next_epic}
├── epics/fn-N.json    # Epic state
├── specs/fn-N.md      # Epic spec (markdown)
├── tasks/fn-N.M.json  # Task state
├── tasks/fn-N.M.md    # Task spec (markdown)
├── memory/            # Agent memory (reserved)
├── bin/               # (optional) Local nbenchctl install via /nbench:setup
│   ├── nbenchctl
│   └── nbenchctl.py
└── usage.md           # (optional) CLI reference via /nbench:setup
```

Runtime state (status, assignee, evidence) is stored in `.git/flow-state/` (not tracked).

Flowctl accepts schema v1 and v2; new fields are optional and defaulted.

New fields:
- Epic JSON: `plan_review_status`, `plan_reviewed_at`, `depends_on_epics`, `branch_name`
- Task JSON: `priority`

## ID Format

- Epic: `fn-N` (e.g., `fn-1`, `fn-42`)
- Task: `fn-N.M` (e.g., `fn-1.3`, `fn-42.7`)

## Commands

### init

Initialize `.nbench/` directory.

```bash
nbenchctl init [--json]
```

### detect

Check if `.nbench/` exists and is valid.

```bash
nbenchctl detect [--json]
```

Output:
```json
{"success": true, "exists": true, "valid": true, "path": "/repo/.flow"}
```

### epic create

Create new epic.

```bash
nbenchctl epic create --title "Epic title" [--branch "fn-1-epic"] [--json]
```

Output:
```json
{"success": true, "id": "fn-1", "title": "Epic title", "spec_path": ".nbench/specs/fn-1.md"}
```

### epic set-plan

Overwrite epic spec from file.

```bash
nbenchctl epic set-plan fn-1 --file plan.md [--json]
```

### epic set-plan-review-status

Set plan review status and timestamp.

```bash
nbenchctl epic set-plan-review-status fn-1 --status ship|needs_work|unknown [--json]
```

### epic set-branch

Set epic branch_name.

```bash
nbenchctl epic set-branch fn-1 --branch "fn-1-epic" [--json]
```

### epic close

Close epic (requires all tasks done).

```bash
nbenchctl epic close fn-1 [--json]
```

### task create

Create task under epic.

```bash
nbenchctl task create --epic fn-1 --title "Task title" [--deps fn-1.2,fn-1.3] [--acceptance-file accept.md] [--priority 10] [--json]
```

Output:
```json
{"success": true, "id": "fn-1.4", "epic": "fn-1", "title": "Task title", "depends_on": ["fn-1.2", "fn-1.3"]}
```

### task set-description

Set task description section.

```bash
nbenchctl task set-description fn-1.2 --file desc.md [--json]
```

### task set-acceptance

Set task acceptance section.

```bash
nbenchctl task set-acceptance fn-1.2 --file accept.md [--json]
```

### task set-spec

Set task spec (full replacement or section patches).

Full replacement:
```bash
nbenchctl task set-spec fn-1.2 --file spec.md [--json]
```

Section patches:
```bash
nbenchctl task set-spec fn-1.2 --description desc.md --acceptance accept.md [--json]
```

`--description` and `--acceptance` are optional; supply one or both. Use `--file -` for stdin.

### task reset

Reset task to `todo` status, clearing assignee and completion data.

```bash
nbenchctl task reset fn-1.2 [--cascade] [--json]
```

Use `--cascade` to also reset dependent tasks within the same epic.

### dep add

Add dependency to task.

```bash
nbenchctl dep add fn-1.3 fn-1.2 [--json]
```

Dependencies must be within same epic.

### show

Show epic or task details.

```bash
nbenchctl show fn-1 [--json]     # Epic with tasks
nbenchctl show fn-1.2 [--json]   # Task only
```

Epic output includes `tasks` array with id/title/status/priority/depends_on.

### epics

List all epics.

```bash
nbenchctl epics [--json]
```

Output:
```json
{"success": true, "epics": [{"id": "fn-1", "title": "...", "status": "open", "tasks": 5, "done": 2}], "count": 1}
```

Human-readable output shows progress: `[open] fn-1: Title (2/5 tasks done)`

### tasks

List tasks, optionally filtered.

```bash
nbenchctl tasks [--json]                    # All tasks
nbenchctl tasks --epic fn-1 [--json]        # Tasks for specific epic
nbenchctl tasks --status todo [--json]      # Filter by status
nbenchctl tasks --epic fn-1 --status done   # Combine filters
```

Status options: `todo`, `in_progress`, `blocked`, `done`

Output:
```json
{"success": true, "tasks": [{"id": "fn-1.1", "epic": "fn-1", "title": "...", "status": "todo", "priority": null, "depends_on": []}], "count": 1}
```

### list

List all epics with their tasks grouped together.

```bash
nbenchctl list [--json]
```

Human-readable output:
```
Flow Status: 2 epics, 5 tasks (2 done)

[open] fn-1: Add auth system (1/3 done)
    [done] fn-1.1: Create user model
    [in_progress] fn-1.2: Add login endpoint
    [todo] fn-1.3: Add logout endpoint

[open] fn-2: Add caching (1/2 done)
    [done] fn-2.1: Setup Redis
    [todo] fn-2.2: Cache API responses
```

JSON output:
```json
{"success": true, "epics": [...], "tasks": [...], "epic_count": 2, "task_count": 5}
```

### cat

Print spec markdown (no JSON mode).

```bash
nbenchctl cat fn-1      # Epic spec
nbenchctl cat fn-1.2    # Task spec
```

### ready

List tasks ready to start, in progress, and blocked.

```bash
nbenchctl ready --epic fn-1 [--json]
```

Output:
```json
{
  "success": true,
  "epic": "fn-1",
  "actor": "user@example.com",
  "ready": [{"id": "fn-1.3", "title": "...", "depends_on": []}],
  "in_progress": [{"id": "fn-1.1", "title": "...", "assignee": "user@example.com"}],
  "blocked": [{"id": "fn-1.4", "title": "...", "blocked_by": ["fn-1.2"]}]
}
```

### next

Select next plan/work unit.

```bash
nbenchctl next [--epics-file epics.json] [--require-plan-review] [--json]
```

Output:
```json
{"status":"plan|work|none","epic":"fn-12","task":"fn-12.3","reason":"needs_plan_review|resume_in_progress|ready_task|none|blocked_by_epic_deps","blocked_epics":{"fn-12":["fn-3"]}}
```

### start

Start task (set status=in_progress). Sets assignee to current actor.

```bash
nbenchctl start fn-1.2 [--force] [--note "..."] [--json]
```

Validates:
- Status is `todo` (or `in_progress` if resuming own task)
- Status is not `blocked` unless `--force`
- All dependencies are `done`
- Not claimed by another actor

Use `--force` to skip checks and take over from another actor.
Use `--note` to add a claim note (auto-set on takeover).

### done

Complete task with summary and evidence. Requires `in_progress` status.

```bash
nbenchctl done fn-1.2 --summary-file summary.md --evidence-json evidence.json [--force] [--json]
```

Use `--force` to skip status check.

Evidence JSON format:
```json
{"commits": [], "tests": ["test_foo"], "prs": ["#42"]}
```

### block

Block a task and record a reason in the task spec.

```bash
nbenchctl block fn-1.2 --reason-file reason.md [--json]
```

### validate

Validate epic structure (specs, deps, cycles).

```bash
nbenchctl validate --epic fn-1 [--json]
nbenchctl validate --all [--json]
```

Single epic output:
```json
{"success": false, "epic": "fn-1", "valid": false, "errors": ["..."], "warnings": [], "task_count": 5}
```

All epics output:
```json
{
  "success": false,
  "valid": false,
  "epics": [{"epic": "fn-1", "valid": true, ...}],
  "total_epics": 2,
  "total_tasks": 10,
  "total_errors": 1
}
```

Checks:
- Epic/task specs exist
- Task specs have required headings
- Task statuses are valid (`todo`, `in_progress`, `blocked`, `done`)
- Dependencies exist and are within epic
- No dependency cycles
- Done status consistency

Exits with code 1 if validation fails (for CI use).

### config

Manage project configuration stored in `.nbench/config.json`.

```bash
# Get a config value
nbenchctl config get memory.enabled [--json]
nbenchctl config get review.backend [--json]
nbenchctl config get planSync.enabled [--json]
nbenchctl config get planSync.crossEpic [--json]

# Set a config value
nbenchctl config set memory.enabled true [--json]
nbenchctl config set review.backend opencode [--json]  # rp, opencode, or none
nbenchctl config set planSync.enabled true [--json]
nbenchctl config set planSync.crossEpic true [--json]

# Toggle boolean config
nbenchctl config toggle memory.enabled [--json]
```

**Available settings:**

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `memory.enabled` | bool | `false` | Enable memory system |
| `planSync.enabled` | bool | `false` | Enable plan-sync after task completion |
| `planSync.crossEpic` | bool | `false` | Also scan other open epics for stale references |
| `review.backend` | string | auto | Default review backend (`rp`, `opencode`, `none`) |

Auto-detect priority: `FLOW_REVIEW_BACKEND` env → config → available CLI.

### memory

Manage persistent learnings in `.nbench/memory/`.

```bash
# Initialize memory directory
nbenchctl memory init [--json]

# Add entries
nbenchctl memory add --type pitfall "Always use nbenchctl rp wrappers" [--json]
nbenchctl memory add --type convention "Tests in __tests__ dirs" [--json]
nbenchctl memory add --type decision "SQLite for simplicity" [--json]

# Query
nbenchctl memory list [--json]
nbenchctl memory search "pattern" [--json]
nbenchctl memory read --type pitfalls [--json]
```

Types: `pitfall`, `convention`, `decision`

### prep-chat

Generate properly escaped JSON for RepoPrompt chat. Avoids shell escaping issues with complex prompts.
Optional legacy positional arg is ignored; do not pass epic/task IDs.

```bash
# Write message to file (avoids escaping issues)
cat > /tmp/prompt.md << 'EOF'
Your multi-line prompt with "quotes", $variables, and `backticks`.
EOF

# Generate JSON
nbenchctl prep-chat \
  --message-file /tmp/prompt.md \
  --mode chat \
  [--chat-id "<id>"] \
  [--new-chat] \
  [--chat-name "Review Name"] \
  [--selected-paths file1.ts file2.ts] \
  [-o /tmp/payload.json]

# Prefer nbenchctl rp chat-send (uses this internally)
nbenchctl rp chat-send --window W --tab T --message-file /tmp/prompt.md
```

Options:
- `--message-file FILE` (required): File containing the message text
- `--mode {chat,ask,review,plan,edit}`: Chat mode (default: chat)
- `--chat-id ID`: Continue existing chat
- `--new-chat`: Start a new chat session
- `--chat-name NAME`: Name for the new chat
- `--selected-paths FILE...`: Files to include in context (for follow-ups)
- `-o, --output FILE`: Write JSON to file (default: stdout)

Output (stdout or file):
```json
{"message": "...", "mode": "chat", "new_chat": true, "chat_name": "...", "selected_paths": ["..."]}
```

### rp

RepoPrompt wrappers (preferred for reviews).

Requires RepoPrompt 1.6.0+ for `--response-type review`.

**Primary entry point** (recommended; picks window + creates builder tab):

```bash
eval "$(nbenchctl rp setup-review --repo-root "$REPO_ROOT" --summary "Review implementation..." --response-type review)"
# Returns: W=<window> T=<tab> CHAT_ID=<id>

# If rp-cli supports --create, it will auto-open a window when none matches:
eval "$(nbenchctl rp setup-review --repo-root "$REPO_ROOT" --summary "..." --response-type review --create)"
```

**Post-setup commands** (use $W/$T from setup-review):

```bash
nbenchctl rp prompt-get --window "$W" --tab "$T"
nbenchctl rp prompt-set --window "$W" --tab "$T" --message-file /tmp/review-prompt.md
nbenchctl rp select-add --window "$W" --tab "$T" path/to/file
nbenchctl rp chat-send --window "$W" --tab "$T" --message-file /tmp/review-prompt.md --chat-id "$CHAT_ID" --mode review
nbenchctl rp prompt-export --window "$W" --tab "$T" --out /tmp/export.md
```

**Low-level commands** (prefer setup-review instead):

```bash
nbenchctl rp windows [--json]
nbenchctl rp pick-window --repo-root "$REPO_ROOT"
nbenchctl rp ensure-workspace --window "$W" --repo-root "$REPO_ROOT"
nbenchctl rp builder --window "$W" --summary "Review a plan to ..."
nbenchctl rp builder --window "$W" --summary "Review implementation..." --response-type review
```

### opencode

OpenCode CLI wrappers (default for reviews in this port).

**Requirements:**
```bash
opencode --version
```

**Model:** Uses the `opencode-reviewer` agent defined in `.opencode/opencode.json`.

**Commands:**
```bash
# Implementation review (reviews code changes for a task)
nbenchctl opencode impl-review <task-id> --base <branch> [--receipt <path>] [--json]
# Example: nbenchctl opencode impl-review fn-1.3 --base main --receipt /tmp/impl-fn-1.3.json

# Plan review (reviews epic spec before implementation)
nbenchctl opencode plan-review <epic-id> [--receipt <path>] [--json]
# Example: nbenchctl opencode plan-review fn-1 --receipt /tmp/plan-fn-1.json
```

**Receipt schema (Ralph-compatible):**
```json
{
  "type": "impl_review",
  "id": "fn-1.3",
  "mode": "opencode",
  "verdict": "SHIP",
  "timestamp": "2026-01-16T01:23:45Z"
}
```

### codex

OpenAI Codex CLI wrappers — legacy alternative to RepoPrompt.

**Requirements:**
```bash
npm install -g @openai/codex
codex auth
```

**Model:** Uses GPT 5.2 High by default (no user config needed). Override with `FLOW_CODEX_MODEL` env var.

**Commands:**

```bash
# Verify codex is available
nbenchctl codex check [--json]

# Implementation review (reviews code changes for a task)
nbenchctl codex impl-review <task-id> --base <branch> [--receipt <path>] [--json]
# Example: nbenchctl codex impl-review fn-1.3 --base main --receipt /tmp/impl-fn-1.3.json

# Plan review (reviews epic spec before implementation)
nbenchctl codex plan-review <epic-id> --base <branch> [--receipt <path>] [--json]
# Example: nbenchctl codex plan-review fn-1 --base main --receipt /tmp/plan-fn-1.json
```

**How it works:**

1. **Gather context hints** — Analyzes changed files, extracts symbols (functions, classes), finds references in unchanged files
2. **Build review prompt** — Uses same Carmack-level criteria as RepoPrompt (7 criteria each for plan/impl)
3. **Run codex** — Executes `codex exec` with the prompt (or `codex exec resume` for session continuity)
4. **Parse verdict** — Extracts `<verdict>SHIP|NEEDS_WORK|MAJOR_RETHINK</verdict>` from output
5. **Write receipt** — If `--receipt` provided, writes JSON for Ralph gating

**Context hints example:**
```
Changed files: src/auth.py, src/handlers.py
Symbols: authenticate(), UserSession, validate_token()
References: src/middleware.py:45 (calls authenticate), tests/test_auth.py:12
```

**Review criteria (identical to RepoPrompt):**

| Review | Criteria |
|--------|----------|
| Plan | Completeness, Feasibility, Clarity, Architecture, Risks, Scope, Testability, Consistency |
| Impl | Correctness, Simplicity, DRY, Architecture, Edge Cases, Tests, Security |

**Receipt schema (Ralph-compatible):**
```json
{
  "type": "impl_review",
  "id": "fn-1.3",
  "mode": "codex",
  "verdict": "SHIP",
  "session_id": "thread_abc123",
  "timestamp": "2026-01-11T10:30:00Z"
}
```

**Session continuity:** Receipt includes `session_id` (thread_id from codex). Subsequent reviews read the existing receipt and resume the conversation, maintaining full context across fix → re-review cycles.

### checkpoint

Save and restore epic state (used during review-fix cycles).

```bash
# Save epic state to .nbench/.checkpoint-fn-1.json
nbenchctl checkpoint save --epic fn-1 [--json]

# Restore epic state from checkpoint
nbenchctl checkpoint restore --epic fn-1 [--json]

# Delete checkpoint
nbenchctl checkpoint delete --epic fn-1 [--json]
```

Checkpoints preserve full epic + task state. Useful when compaction occurs during plan-review cycles.

### status

Show `.nbench/` state summary.

```bash
nbenchctl status [--json]
```

Output:
```json
{"success": true, "epic_count": 2, "task_count": 5, "done_count": 2, "active_runs": []}
```

Human-readable output shows epic/task counts and any active Ralph runs.

### state-path

Show resolved runtime state directory (worktree-aware).

```bash
nbenchctl state-path [--json]
nbenchctl state-path --task fn-1.2 [--json]
```

Example output:
```json
{"success": true, "state_dir": "/repo/.git/flow-state", "source": "git-common-dir", "task_state_path": "/repo/.git/flow-state/tasks/fn-1.2.state.json"}
```

Source values:
- `env` — `FLOW_STATE_DIR` environment variable
- `git-common-dir` — `git --git-common-dir` (shared across worktrees)
- `fallback` — `.nbench/state` (non-git or old git)

`task_state_path` is included only when `--task` is provided.

### migrate-state

Migrate existing repos to the shared runtime state model.

```bash
nbenchctl migrate-state [--clean] [--json]
```

Options:
- `--clean` — Remove runtime fields from tracked JSON files after migration (recommended for cleaner git diffs)

What it does:
1. Scans `.nbench/tasks/*.json` for runtime fields
2. Writes runtime state to `.git/flow-state/tasks/*.state.json`
3. With `--clean`: removes runtime fields from the original JSON files

**When to use:**
- After upgrading to 0.17.0+ if you want parallel worktree support
- To clean up git diffs (runtime changes no longer tracked)

**Not required** for normal operation — the merged read path handles backward compatibility automatically.

## Ralph Receipts

Review receipts are **not** managed by nbenchctl. They are written by the review skills when `REVIEW_RECEIPT_PATH` is set (Ralph sets this env var).

See: [Ralph deep dive](ralph.md)

## JSON Output

All commands support `--json` (except `cat`). Wrapper format:

```json
{"success": true, ...}
{"success": false, "error": "message"}
```

Exit codes: 0=success, 1=error.

## Error Handling

- Missing `.nbench/`: "Run 'nbenchctl init' first"
- Invalid ID format: "Expected format: fn-N (epic) or fn-N.M (task)"
- File conflicts: Refuses to overwrite existing epics/tasks
- Dependency violations: Same-epic only, must exist, no cycles
- Status violations: Can't start non-todo, can't close with incomplete tasks
