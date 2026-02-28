---
name: flux-opencode-work
description: Execute a Flux epic or task systematically with git setup, task tracking, quality checks, and commit workflow. Use when implementing a plan or working through a spec. Triggers on /flux:work with Flux IDs (fn-1, fn-1.2).
---

# Flux work

Execute a plan systematically. Focus on finishing.

Follow this skill and linked workflows exactly. Deviations cause drift, bad gates, retries, and user frustration.

**IMPORTANT**: This plugin uses `.flux/` for ALL task tracking. Do NOT use markdown TODOs, plan files, TodoWrite, or other tracking methods. All task state must be read and written via `fluxctl`.

**CRITICAL: fluxctl is BUNDLED — NOT installed globally.** `which fluxctl` will fail (expected). Always use:
```bash
ROOT="$(git rev-parse --show-toplevel)"
OPENCODE_DIR="$ROOT/.opencode"
NBENCHCTL="$OPENCODE_DIR/bin/fluxctl"
$NBENCHCTL <command>
```

**Hard requirements (non-negotiable):**
- You MUST run `fluxctl done` for each completed task and verify the task status is `done`.
- You MUST stage with `git add -A` (never list files). This ensures `.flux/` and `scripts/ralph/` (if present) are included.
- Do NOT claim completion until `fluxctl show <task>` reports `status: done`.
- Do NOT invoke `/flux:impl-review` until tests/Quick commands are green.

**Role**: execution lead, plan fidelity first.
**Goal**: complete every task in order with tests.

## Ralph Mode Rules (always follow)

If `REVIEW_RECEIPT_PATH` is set or `NBENCH_RALPH=1`:
- **Must** use `fluxctl done` and verify task status is `done` before committing.
- **Must** stage with `git add -A` (never list files).
- **Do NOT** use TodoWrite for tracking.

## Input

Full request: $ARGUMENTS

Accepts:
- Flux epic ID `fn-N` to work through all tasks
- Flux task ID `fn-N.M` to work on single task
- Markdown spec file path (creates epic from file, then executes)
- Idea text (creates minimal epic + single task, then executes)
- Chained instructions like "then review with /flux:impl-review"

Examples:
- `/flux:work fn-1`
- `/flux:work fn-1.3`
- `/flux:work docs/my-feature-spec.md`
- `/flux:work Add rate limiting`
- `/flux:work fn-1 then review via /flux:impl-review`

If no input provided, ask for it.

## FIRST: Parse Options or Ask Questions

Check available backends and configured preference:
```bash
HAVE_RP=0;
if command -v rp-cli >/dev/null 2>&1; then
  HAVE_RP=1;
elif [[ -x /opt/homebrew/bin/rp-cli || -x /usr/local/bin/rp-cli ]]; then
  HAVE_RP=1;
fi;

# Check configured backend (priority: env > config)
CONFIGURED_BACKEND="${FLOW_REVIEW_BACKEND:-}";
if [[ -z "$CONFIGURED_BACKEND" ]]; then
  CONFIGURED_BACKEND="$($NBENCHCTL config get review.backend --json 2>/dev/null | jq -r '.value // empty')";
fi
```

**MUST RUN the detection command above** and use its result. Do **not** assume rp-cli is missing without running it.

### Option Parsing (skip questions if found in arguments)

Parse the arguments for these patterns. If found, use them and skip corresponding questions:

**Branch mode**:
- `--branch=current` or `--current` or "current branch" or "stay on this branch" → current branch
- `--branch=new` or `--new-branch` or "new branch" or "create branch" → new branch
- `--branch=worktree` or `--worktree` or "isolated worktree" or "worktree" → isolated worktree

**Review mode**:
- `--review=opencode` or "opencode review" or "use opencode" → OpenCode review (GPT-5.2, reasoning high)
- `--review=rp` or "review with rp" or "rp chat" or "repoprompt review" → RepoPrompt chat (via `fluxctl rp chat-send`)
- `--review=export` or "export review" or "external llm" → export for external LLM
- `--review=none` or `--no-review` or "no review" or "skip review" → no review

### If options NOT found in arguments

**IMPORTANT**: Ask setup questions in **plain text only**. **Do NOT use the question tool.** This is required for voice dictation (e.g., "1a 2b").

**Skip review question if**: Ralph mode (`NBENCH_RALPH=1`) OR backend already configured (`CONFIGURED_BACKEND` not empty). In these cases, only ask branch question:

```
Quick setup: Where to work?
a) Current branch  b) New branch  c) Isolated worktree

(Reply: "a", "current", or just tell me)
```

**Otherwise**, output questions based on available backends:

**If rp-cli available:**
```
Quick setup before starting:

1. **Branch** — Where to work?
   a) Current branch
   b) New branch
   c) Isolated worktree

2. **Review** — Run Carmack-level review after?
   a) Yes, OpenCode review (GPT-5.2, reasoning high)
   b) Yes, RepoPrompt chat (macOS, visual builder)
   c) Yes, export for external LLM (ChatGPT, Claude web)
   d) No

(Reply: "1a 2a", "current branch, opencode review", or just tell me naturally)
```

**If rp-cli not available:**
```
Quick setup before starting:

1. **Branch** — Where to work?
   a) Current branch
   b) New branch
   c) Isolated worktree

2. **Review** — Run Carmack-level review after?
   a) Yes, OpenCode review (GPT-5.2, reasoning high)
   b) Yes, export for external LLM
   c) No

(Reply: "1a 2a", "current branch, opencode", or just tell me naturally)
```

Wait for response. Parse naturally — user may reply terse or ramble via voice.

**Defaults when empty/ambiguous:**
- Branch = `new`
- Review = configured backend if set, else `opencode`, else `rp` if available, else `none`

**Defaults when no review backend available:**
- Branch = `new`
- Review = `none`

**Do NOT read files or write code until user responds.**

## Workflow

After setup questions answered, read `.opencode/skill/flux-opencode-work/phases.md` and execute each phase in order.
If user chose review:
- Option 2a: run `/flux:impl-review` after Phase 6, fix issues until it passes
- Option 2b: run `/flux:impl-review` with export mode after Phase 6

## Guardrails

- Don't start without asking branch question (unless NBENCH_RALPH=1)
- Don't start without plan/epic
- Don't skip tests
- Don't leave tasks half-done
- Never use TodoWrite for task tracking
- Never create plan files outside `.flux/`
