# Flow Plan Steps

**IMPORTANT**: Steps 1-3 (research, gap analysis, depth) ALWAYS run regardless of input type.

**CRITICAL**: If you are about to create:
- a markdown TODO list,
- a task list outside `.flux/`,
- or any plan files outside `.flux/`,

**STOP** and instead:
- create/update tasks in `.flux/` using `fluxctl`,
- record details in the epic/task spec markdown.

## Success criteria

- Plan references existing files/patterns with line refs
- Reuse points are explicit (centralized code called out)
- Acceptance checks are testable
- Tasks are small enough for one `/flux:work` iteration (split if not)
- **No implementation code** — specs describe WHAT, not HOW (see SKILL.md Golden Rule)
- Open questions are listed

## Task Sizing Rule

Use **T-shirt sizes** based on observable metrics — not token estimates (models can't reliably estimate tokens).

| Size | Files | Acceptance Criteria | Pattern | Action |
|------|-------|---------------------|---------|--------|
| **S** | 1-2 | 1-3 | Follows existing | ✅ Good task size |
| **M** | 3-5 | 3-5 | Adapts existing | ✅ Good task size |
| **L** | 5+ | 5+ | New/novel | ⚠️ **Split this** |

**Anchor examples** (calibrate against these):
- **S**: Fix a bug, add config, simple UI tweak
- **M**: New API endpoint with tests, new component with state
- **L**: New subsystem, architectural change → SPLIT INTO S/M TASKS

**If too large, split it:**
- ❌ Bad: "Implement Google OAuth" (L — new subsystem)
- ✅ Good:
  - "Add Google OAuth env config" (S)
  - "Configure passport-google-oauth20" (S)
  - "Create OAuth callback routes" (M)
  - "Add Google sign-in button" (S)

## Step 0: Initialize .flow

**CRITICAL: fluxctl is BUNDLED — NOT installed globally.** `which fluxctl` will fail (expected). Always use:

```bash
# Get fluxctl path
ROOT="$(git rev-parse --show-toplevel)"
OPENCODE_DIR="$ROOT/.opencode"
NBENCHCTL="$OPENCODE_DIR/bin/fluxctl"

# Ensure .flow exists
$NBENCHCTL init --json
```

## Step 1: Fast research (parallel)

**If input is a Flux ID** (fn-N or fn-N.M): First fetch it with `$NBENCHCTL show <id> --json` and `$NBENCHCTL cat <id>` to get the request context.

**Check if memory is enabled:**
```bash
$NBENCHCTL config get memory.enabled --json
```

**Based on user's choice in SKILL.md setup:**

**If user chose context-scout (RepoPrompt)**:
Run these subagents in parallel using the Task tool:
- Task flux:context-scout(<request>) - uses RepoPrompt builder for AI-powered file discovery
- Task flux:practice-scout(<request>)
- Task flux:docs-scout(<request>)
- Task flux:github-scout(<request>) - cross-repo code search via gh CLI
- Task flux:memory-scout(<request>) - **only if memory.enabled is true**
- Task flux:epic-scout(<request>) - finds dependencies on existing open epics
- Task flux:docs-gap-scout(<request>) - identifies docs that may need updates

**If user chose repo-scout (default/faster)** OR rp-cli unavailable:
Run these subagents in parallel using the Task tool:
- Task flux:repo-scout(<request>) - uses standard Grep/Glob/Read
- Task flux:practice-scout(<request>)
- Task flux:docs-scout(<request>)
- Task flux:github-scout(<request>) - cross-repo code search via gh CLI
- Task flux:memory-scout(<request>) - **only if memory.enabled is true**
- Task flux:epic-scout(<request>) - finds dependencies on existing open epics
- Task flux:docs-gap-scout(<request>) - identifies docs that may need updates

Example batch payload:
```json
{
  "tool_calls": [
    {"tool": "task", "parameters": {"description": "Context scout", "prompt": "<request>", "subagent_type": "context-scout"}},
    {"tool": "task", "parameters": {"description": "Practice scout", "prompt": "<request>", "subagent_type": "practice-scout"}},
    {"tool": "task", "parameters": {"description": "Docs scout", "prompt": "<request>", "subagent_type": "docs-scout"}}
  ]
}
```
Max 10 tool calls per batch. Split if more. Do not include external/MCP tools in batch.

Must capture:
- File paths + line refs
- Existing centralized code to reuse
- Similar patterns / prior work
- External docs links
- Project conventions (CLAUDE.md, CONTRIBUTING, etc)
- Architecture patterns and data flow (especially with context-scout)
- Epic dependencies (from epic-scout)
- Doc updates needed (from docs-gap-scout) - add to task acceptance criteria

## Step 2: Stakeholder & scope check

Before diving into gaps, identify who's affected:
- **End users** — What changes for them? New UI, changed behavior?
- **Developers** — New APIs, changed interfaces, migration needed?
- **Operations** — New config, monitoring, deployment changes?

This shapes what the plan needs to cover. A pure backend refactor needs different detail than a user-facing feature.

## Step 3: Flow gap check

Run the gap analyst subagent:
- Task flux:flux-gap-analyst(<request>, research_findings)

Fold gaps + questions into the plan.

## Step 4: Pick depth

Default to standard unless complexity demands more or less.

**SHORT** (bugs, small changes)
- Problem or goal
- Acceptance checks
- Key context

**STANDARD** (most features)
- Overview + scope
- Approach
- Risks / dependencies
- Acceptance checks
- Test notes
- References
- Mermaid diagram if data model changes

**DEEP** (large/critical)
- Detailed phases
- Alternatives considered
- Non-functional targets
- Architecture/data flow diagram (mermaid)
- Rollout/rollback
- Docs + metrics
- Risks + mitigations

## Step 5: Write to .flow

**Efficiency note**: Use stdin (`--file -`) with heredocs to avoid temp files. Use `task set-spec` to set description + acceptance in one call.

**Route A - Input was an existing Flux ID**:

1. If epic ID (fn-N):
   ```bash
   # Use stdin heredoc (no temp file needed)
   $NBENCHCTL epic set-plan <id> --file - --json <<'EOF'
   <plan content here>
   EOF
   ```
   - Set epic dependencies from epic-scout (if any):
     ```bash
     # For each dependency found by epic-scout:
     $NBENCHCTL epic add-dep <epic-id> <dependency-epic-id> --json
     ```
   - Report findings at end of planning (no user prompt needed):
     ```
     Epic dependencies set:
     - fn-N → fn-2 (Auth): Uses authService from fn-2.1
     - fn-N → fn-5 (DB): Extends User model
     ```
   - Create/update child tasks as needed

2. If task ID (fn-N.M):
   ```bash
   # Combined set-spec: description + acceptance in one call
   # Write to temp files only if content has single quotes
   $NBENCHCTL task set-spec <id> --description /tmp/desc.md --acceptance /tmp/acc.md --json
   ```

**Route B - Input was text (new idea)**:

1. Create epic:
   ```bash
   $NBENCHCTL epic create --title "<Short title>" --json
   ```
   This returns the epic ID (e.g., fn-1).

2. Set epic branch_name (deterministic):
   - Default: `fn-N` (use epic ID)
   ```bash
   $NBENCHCTL epic set-branch <epic-id> --branch "<epic-id>" --json
   ```
   - If user specified a branch, use that instead.

3. Write epic spec (use stdin heredoc):
   ```bash
   # Include: Overview, Scope, Approach, Quick commands (REQUIRED), Acceptance, References
   # Add mermaid diagram if data model or architecture changes
   $NBENCHCTL epic set-plan <epic-id> --file - --json <<'EOF'
   # Epic Title

   ## Overview
   ...

   ## Quick commands
   ```bash
   # At least one smoke test command
   ```

   ## Acceptance
   ...
   EOF
   ```

4. Set epic dependencies (from epic-scout findings):
   ```bash
   # For each dependency found by epic-scout:
   $NBENCHCTL epic add-dep <epic-id> <dependency-epic-id> --json
   ```

5. Create child tasks:
   ```bash
   # For each task:
   $NBENCHCTL task create --epic <epic-id> --title "<Task title>" --json
   ```

6. Write task specs (use combined set-spec):
   ```bash
   # For each task - single call sets both sections
   # Write description and acceptance to temp files, then:
   $NBENCHCTL task set-spec <task-id> --description /tmp/desc.md --acceptance /tmp/acc.md --json
   ```

   **Task spec content** (remember: NO implementation code):
   ```markdown
   ## Description
   [What to build, not how to build it]

   **Size:** S/M (L tasks should be split)
   **Files:** list expected files

   ## Approach
   - Follow pattern at `src/example.ts:42`
   - Reuse `existingHelper()` from `lib/utils.ts`

   ## Key context
   [Only for recent API changes, surprising patterns, or non-obvious gotchas]

   ## Acceptance
   - [ ] Criterion 1
   - [ ] Criterion 2
   ```

   **Doc updates**: If docs-gap-scout flagged updates, add them to relevant task acceptance criteria.

   **Doc updates**: If docs-gap-scout flagged updates, add them to task acceptance criteria (e.g., "Update README usage section").

7. Add dependencies:
   ```bash
   # If task B depends on task A:
   $NBENCHCTL dep add <task-B-id> <task-A-id> --json
   ```

8. Output current state:
   ```bash
   $NBENCHCTL show <epic-id> --json
   $NBENCHCTL cat <epic-id>
   ```

## Step 6: Validate

```bash
$NBENCHCTL validate --epic <epic-id> --json
```

Fix any errors before proceeding.

## Step 7: Review (if chosen at start)

If user chose "Yes" to review in SKILL.md setup question:
1. Invoke `/flux:plan-review` with the epic ID
2. If review returns "Needs Work" or "Major Rethink":
   - **Re-anchor EVERY iteration** (do not skip):
     ```bash
     $NBENCHCTL show <epic-id> --json
     $NBENCHCTL cat <epic-id>
     ```
   - **Immediately fix the issues** (do NOT ask for confirmation — user already consented)
   - Re-run `/flux:plan-review`
3. Repeat until review returns "Ship"

**No human gates here** — the review-fix-review loop is fully automated.

**Why re-anchor every iteration?** Per Anthropic's long-running agent guidance: context compresses, you forget details. Re-read before each fix pass.

## Step 8: Offer next steps

Show epic summary with size breakdown and offer options:

```
Epic fn-N created: "<title>"
Tasks: M total | Sizes: Ns S, Nm M

Next steps:
1) Start work: `/flux:work fn-N`
2) Refine via interview: `/flux:interview fn-N`
3) Review the plan: `/flux:plan-review fn-N`
4) Go deeper on specific tasks (tell me which)
5) Simplify (reduce detail level)
```

If user selects 4 or 5:
- **Go deeper**: Ask which task(s), then add more context/research to those specific tasks
- **Simplify**: Remove non-essential sections, tighten acceptance criteria, merge small tasks

Loop back to options after changes until user selects 1, 2, or 3.
