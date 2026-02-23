# N-bench Work Phases

(Branch question already asked in SKILL.md before reading this file)

**CRITICAL**: If you are about to create:
- a markdown TODO list,
- a task list outside `.nbench/`,
- or any plan files outside `.nbench/`,

**STOP** and instead:
- create/update tasks in `.nbench/` using `nbenchctl`,
- record details in the epic/task spec markdown.

## Setup

**CRITICAL: nbenchctl is BUNDLED — NOT installed globally.** `which nbenchctl` will fail (expected). Always use:

```bash
ROOT="$(git rev-parse --show-toplevel)"
OPENCODE_DIR="$ROOT/.opencode"
NBENCHCTL="$OPENCODE_DIR/bin/nbenchctl"
```

## Phase 1: Resolve Input

Detect input type in this order (first match wins):

1. **N-bench task ID** `fn-N.M` or `fn-N-xxx.M` (e.g., fn-1.3, fn-1-abc.2)
2. **N-bench epic ID** `fn-N` or `fn-N-xxx` (e.g., fn-1, fn-1-abc)
3. **Spec file** `.md` path that exists on disk
4. **Idea text** everything else

---

**N-bench task ID (fn-N.M or fn-N-xxx.M)**:
- Read task: `$NBENCHCTL show <id> --json`
- Read spec: `$NBENCHCTL cat <id>`
- Get epic from task data for context: `$NBENCHCTL show <epic-id> --json && $NBENCHCTL cat <epic-id>`

**N-bench epic ID (fn-N or fn-N-xxx)**:
- Read epic: `$NBENCHCTL show <id> --json`
- Read spec: `$NBENCHCTL cat <id>`
- Get first ready task: `$NBENCHCTL ready --epic <id> --json`

**Spec file start (.md path that exists)**:
1. Check file exists: `test -f "<path>"` — if not, treat as idea text
2. Initialize: `$NBENCHCTL init --json`
3. Read file and extract title from first `# Heading` or use filename
4. Create epic: `$NBENCHCTL epic create --title "<extracted-title>" --json`
5. Set spec from file: `$NBENCHCTL epic set-plan <epic-id> --file <path> --json`
6. Create single task: `$NBENCHCTL task create --epic <epic-id> --title "Implement <title>" --json`
7. Continue with epic-id

**Spec-less start (idea text)**:
1. Initialize: `$NBENCHCTL init --json`
2. Create epic: `$NBENCHCTL epic create --title "<idea>" --json`
3. Create single task: `$NBENCHCTL task create --epic <epic-id> --title "Implement <idea>" --json`
4. Continue with epic-id

## Phase 2: Apply Branch Choice

Based on user's answer from setup questions:

- **Worktree**: use `skill: nbench-opencode-worktree-kit`
- **New branch**:
  ```bash
  git checkout main && git pull origin main
  git checkout -b <branch>
  ```
- **Current branch**: proceed (user already confirmed)

## Phase 3: Prime / Re-anchor Context (EVERY task)

**MANDATORY: This phase runs before EVERY task. No exceptions. No optimizations.**

Per Anthropic's long-running agent guidance: agents must re-anchor from sources of truth to prevent drift. Even if you "remember" the context, re-read it. The reads are cheap; drift is expensive.

**Also run this phase after context compaction** (if you notice the conversation was summarized).

### Re-anchor Checklist (run ALL before each task)

**You MUST run every command below. Do not skip or combine.**

```bash
# 1. Find next task
$NBENCHCTL ready --epic <epic-id> --json

# 2. Re-read epic (EVERY time)
$NBENCHCTL show <epic-id> --json
$NBENCHCTL cat <epic-id>

# 3. Re-read task spec (EVERY time)
$NBENCHCTL show <task-id> --json
$NBENCHCTL cat <task-id>

# 4. Check git state (EVERY time)
git status
git log -5 --oneline

# 5. Validate structure (EVERY time)
$NBENCHCTL validate --epic <epic-id> --json

# 6. Check memory (if enabled)
$NBENCHCTL config get memory.enabled --json
```

**If memory.enabled is true**, also run:
- subagent_type: `memory-scout`
- prompt: `<task-id>: <task-title>`

This retrieves relevant project learnings before implementation.

If no ready tasks after step 1, all done → go to Phase 6.

After step 5, run the smoke command from epic spec's "Quick commands" section.

**Why every time?** Context windows compress. You forget details. The spec is the truth. 30 seconds of re-reading prevents hours of rework.

**Anti-pattern**: Running steps 2-5 only on the first task. The whole point is EVERY task gets fresh context.

## Phase 4: Execute Task Loop

**For each task** (one at a time):

1. **Start task**:
   ```bash
   $NBENCHCTL start <task-id> --json
   ```

2. **Implement + test thoroughly**:
   - Read task spec for requirements
   - Write code
   - Run tests (including epic spec "Quick commands")
   - Verify acceptance criteria
   - If any command fails, fix before proceeding

3. **If you discover new work**:
   - Draft new task title + acceptance checklist
   - Create immediately:
     ```bash
     # Write acceptance to temp file first
     $NBENCHCTL task create --epic <epic-id> --title "Found: <issue>" --deps <current-task-id> --acceptance-file <temp-md> --json
     ```
   - Re-run `$NBENCHCTL ready --epic <epic-id> --json` to see updated order

4. **Commit implementation** (code changes only):
   ```bash
   git add -A   # never list files; include .nbench/ and scripts/ralph/ if present
   git status --short
   git commit -m "<type>: <short summary of what was done>"
   COMMIT_HASH="$(git rev-parse HEAD)"
   echo "Commit: $COMMIT_HASH"
   ```

5. **Complete task** (records done status + evidence):
   Write done summary to temp file (required format):
   ```
   - What changed (1-3 bullets)
   - Why (1-2 bullets)
   - Verification (tests/commands run)
   - Follow-ups (optional, max 2 bullets)
   ```

   Write evidence to temp JSON file **with the commit hash from step 4**:
   ```json
   {"commits":["<COMMIT_HASH>"],"tests":["npm test"],"prs":[]}
   ```

   Then:
   ```bash
   $NBENCHCTL done <task-id> --summary-file <summary.md> --evidence-json <evidence.json> --json
   ```

   **FORBIDDEN**: `nbenchctl task edit` (no such command).  
   If you need to update task text, edit the markdown file directly and use `nbenchctl done` with summary/evidence.

   Verify the task is actually marked done:
   ```bash
   $NBENCHCTL show <task-id> --json
   ```
   If status is not `done`, stop and re-run `nbenchctl done` before proceeding.

6. **Amend commit** to include .nbench/ updates:
   ```bash
   git add -A
   git commit --amend --no-edit
   ```

7. **Verify task completion**:
   ```bash
   $NBENCHCTL validate --epic <epic-id> --json
   git status
   ```
   Ensure working tree is clean.

8. **Loop**: Return to Phase 3 for next task.

## Phase 5: Quality

After all tasks complete (or periodically for large epics):

- Run relevant tests
- Run lint/format per repo
- If change is large/risky, run the quality auditor subagent via the task tool:
  - subagent_type: `quality-auditor`
  - prompt: "Review recent changes"
- Fix critical issues

## Phase 6: Ship

**Verify all tasks done**:
```bash
$NBENCHCTL show <epic-id> --json
$NBENCHCTL validate --epic <epic-id> --json
```

**Final commit** (if any uncommitted changes):
```bash
   git add -A
git status
git diff --staged
git commit -m "<final summary>"
```

**Do NOT close the epic here** unless the user explicitly asked.
Ralph closes done epics at the end of the loop.

Then push + open PR if user wants.

## Phase 7: Review (if chosen at start)

If user chose "Yes" to review in setup questions or `--review=opencode` / `--review=rp` was passed:

**CRITICAL: You MUST invoke the `/nbench:impl-review` skill. Do NOT improvise your own review format.**

The impl-review skill:
- Auto-detects backend (OpenCode or RepoPrompt) based on config/availability
- Uses the correct prompt template requiring `<verdict>SHIP|NEEDS_WORK|MAJOR_RETHINK</verdict>`
- Handles the fix loop internally

Steps:
1. Invoke `/nbench:impl-review` (this loads the skill with its workflow.md)
2. If review returns NEEDS_WORK or MAJOR_RETHINK:
   - **Immediately fix the issues** (do NOT ask for confirmation — user already consented)
   - Commit fixes
   - Re-run tests/Quick commands
   - Re-run `/nbench:impl-review`
3. Repeat until review returns SHIP

**Anti-pattern**: Sending your own review prompts directly without invoking the skill.
The skill has the correct format; improvised prompts ask for "LGTM" which breaks automation.

**No human gates here** — the review-fix-review loop is fully automated.

## Definition of Done

Confirm before ship:
- All tasks have status "done"
- `$NBENCHCTL validate --epic <id>` passes
- Tests pass
- Lint/format pass
- Docs updated if needed
- Working tree is clean

## Example loop

```
Prime → Task A → test → done → commit → Prime → Task B → ...
```
