---
name: flux-opencode-interview
description: Interview user in-depth about an epic, task, or spec file to extract complete implementation details. Use when user wants to flesh out a spec, refine requirements, or clarify a feature before building. Triggers on /flux:interview with Flux IDs (fn-1, fn-1.2) or file paths.
---

# Flux interview

Conduct an extremely thorough interview about a task/spec and write refined details back.

**IMPORTANT**: This plugin uses `.flux/` for ALL task tracking. Do NOT use markdown TODOs, plan files, TodoWrite, or other tracking methods. All task state must be read and written via `fluxctl`.

**CRITICAL: fluxctl is BUNDLED — NOT installed globally.** `which fluxctl` will fail (expected). Always use:
```bash
ROOT="$(git rev-parse --show-toplevel)"
OPENCODE_DIR="$ROOT/.opencode"
NBENCHCTL="$OPENCODE_DIR/bin/fluxctl"
$NBENCHCTL <command>
```

## Pre-check: Local setup version

If `.flux/meta.json` exists and has `setup_version`, compare to local OpenCode version:
```bash
SETUP_VER=$(jq -r '.setup_version // empty' .flux/meta.json 2>/dev/null)
OPENCODE_VER=$(cat "$OPENCODE_DIR/version" 2>/dev/null || echo "unknown")
if [[ -n "$SETUP_VER" && "$OPENCODE_VER" != "unknown" && "$SETUP_VER" != "$OPENCODE_VER" ]]; then
  echo "Flux updated to v${OPENCODE_VER}. Run /flux:setup to refresh local scripts (current: v${SETUP_VER})."
fi
```
Continue regardless (non-blocking).

**Role**: technical interviewer, spec refiner
**Goal**: extract complete implementation details through deep questioning (40+ questions typical)

## Input

Full request: $ARGUMENTS

Accepts:
- **Flux epic ID** `fn-N`: Fetch with `fluxctl show`, write back with `fluxctl epic set-plan`
- **Flux task ID** `fn-N.M`: Fetch with `fluxctl show`, write back with `fluxctl task set-description/set-acceptance`
- **File path** (e.g., `docs/spec.md`): Read file, interview, rewrite file
- **Empty**: Prompt for target

Examples:
- `/flux:interview fn-1`
- `/flux:interview fn-1.3`
- `/flux:interview docs/oauth-spec.md`

If empty, ask: "What should I interview you about? Give me a Flux ID (e.g., fn-1) or file path (e.g., docs/spec.md)"

## Setup

```bash
ROOT="$(git rev-parse --show-toplevel)"
OPENCODE_DIR="$ROOT/.opencode"
NBENCHCTL="$OPENCODE_DIR/bin/fluxctl"
```

## Detect Input Type

1. **Flux epic ID pattern**: matches `fn-\d+` (e.g., fn-1, fn-12)
   - Fetch: `$NBENCHCTL show <id> --json`
   - Read spec: `$NBENCHCTL cat <id>`

2. **Flux task ID pattern**: matches `fn-\d+\.\d+` (e.g., fn-1.3, fn-12.5)
   - Fetch: `$NBENCHCTL show <id> --json`
   - Read spec: `$NBENCHCTL cat <id>`
   - Also get epic context: `$NBENCHCTL cat <epic-id>`

3. **File path**: anything else with a path-like structure or .md extension
   - Read file contents
   - If file doesn't exist, ask user to provide valid path

4. **New idea text**: everything else
   - Create a new epic stub and refine requirements
   - Do NOT create tasks (that's /flux:plan)

## Interview Process

Ask questions in **plain text** (no question tool). Group 5-8 questions per message. Expect 40+ total for complex specs. Wait for answers before continuing.

Rules:
- Keep questions short and concrete
- Offer 2-4 options when helpful
- Include “Not sure” when ambiguous
- Number questions for easy replies

Example:
```
1) Primary user goal?
2) Platforms: web, iOS, Android, desktop?
3) Auth required? (yes/no/unknown)
4) Performance targets? (p95 ms)
5) Edge cases you already know?
```

## Question Categories

Read [questions.md](questions.md) for all question categories and interview guidelines.

## NOT in scope (defer to /flux:plan)

- Research scouts (codebase analysis)
- File/line references
- Task creation (interview refines requirements, plan creates tasks)
- Task sizing (S/M/L)
- Dependency ordering
- Phased implementation details

## Write Refined Spec

After interview complete, write everything back — scope depends on input type.

### For NEW IDEA (text input, no Flux ID)

Create epic with interview output. **Do NOT create tasks** — that's `/flux:plan`'s job.

```bash
$NBENCHCTL epic create --title "..." --json
$NBENCHCTL epic set-plan <id> --file - --json <<'EOF'
# Epic Title

## Problem
Clear problem statement

## Key Decisions
Decisions made during interview (e.g., "Use OAuth not SAML", "Support mobile + web")

## Edge Cases
- Edge case 1
- Edge case 2

## Open Questions
Unresolved items that need research during planning

## Acceptance
- [ ] Criterion 1
- [ ] Criterion 2
EOF
```

Then suggest: "Run `/flux:plan fn-N` to research best practices and create tasks."

### For Flow Epic ID

**First check if tasks exist:**
```bash
$NBENCHCTL tasks --epic <id> --json
```

**If tasks exist:** Only update the epic spec (add edge cases, clarify requirements). **Do NOT touch task specs** — plan already created them.

**If no tasks:** Update epic spec, then suggest `/flux:plan`.

```bash
$NBENCHCTL epic set-plan <id> --file - --json <<'EOF'
# Epic Title

## Problem
Clear problem statement

## Key Decisions
Decisions made during interview

## Edge Cases
- Edge case 1
- Edge case 2

## Open Questions
Unresolved items

## Acceptance
- [ ] Criterion 1
- [ ] Criterion 2
EOF
```

### For Flow Task ID

**First check if task has existing spec from planning:**
```bash
$NBENCHCTL cat <id>
```

**If task has substantial planning content** (file refs, sizing, approach):
- **Do NOT overwrite** — planning detail would be lost
- Only add new acceptance criteria discovered in interview:
  ```bash
  $NBENCHCTL task set-acceptance <id> --file /tmp/acc.md --json
  ```
- Or suggest interviewing the epic instead: `/flux:interview <epic-id>`

**If task is minimal** (just title, empty or stub description):
- Update task with interview findings
- Focus on **requirements**, not implementation details

```bash
# Preferred: combined set-spec (2 writes instead of 4)
$NBENCHCTL task set-spec <id> --description /tmp/desc.md --acceptance /tmp/acc.md --json
```

Description should capture:
- What needs to be accomplished (not how)
- Edge cases discovered in interview
- Constraints and requirements

Do NOT add: file/line refs, sizing, implementation approach — that's plan's job.

### For File Path

Rewrite the file with refined spec:
- Preserve any existing structure/format
- Add sections for areas covered in interview
- Include edge cases, acceptance criteria
- Keep it requirements-focused (what, not how)

This is typically a pre-epic doc. After interview, suggest `/flux:plan <file>` to create epic + tasks.

## Completion

Show summary:
- Number of questions asked
- Key decisions captured
- What was written (Flux ID updated / file rewritten)
- Suggest next step: `/flux:plan` or `/flux:work`

## Notes

- This process should feel thorough - user should feel they've thought through everything
- Quality over speed - don't rush to finish
