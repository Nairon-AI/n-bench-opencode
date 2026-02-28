---
name: flux-opencode-scope
description: Combined requirements gathering and planning using Double Diamond process. Guides through Problem Space (discover/define) then Solution Space (research/plan). Default is quick mode (~10 min). Use --deep for thorough scoping (~45 min).
---

# Flux Scope

Turn a rough idea into a well-defined epic with tasks using the Double Diamond process.

**Double Diamond Flow:**
```
PROBLEM SPACE                    SOLUTION SPACE
┌────────────────────┐          ┌────────────────────┐
│ DISCOVER   DEFINE  │          │ RESEARCH   PLAN    │
│ (diverge) (converge)│    →    │ (diverge) (converge)│
│     ◇        ▽     │          │     ◇        ▽     │
└────────────────────┘          └────────────────────┘
     ~5-20 min                       ~5-25 min
```

**Modes**:
- **Quick (default)**: ~10 min total. MVP-focused problem exploration + short plan.
- **Deep (`--deep`)**: ~45 min total. Thorough discovery + standard/deep plan.

> "Understand the problem before solving it. Most failed features solve the wrong problem."

**IMPORTANT**: This plugin uses `.flux/` for ALL task tracking. Do NOT use markdown TODOs or other tracking methods. All task state must be read and written via `fluxctl`.

**CRITICAL: fluxctl is BUNDLED.** Always use:
```bash
FLOWCTL="${OPENCODE_PLUGIN_ROOT}/scripts/fluxctl"
$FLOWCTL <command>
```

## Input

Full request: $ARGUMENTS

**Options**:
- `--quick` (default): MVP-focused, ~10 min total
- `--deep`: Thorough scoping, ~45 min total

Accepts:
- Feature/bug description in natural language
- File path to spec document

Examples:
- `/flux:scope Add OAuth login for users`
- `/flux:scope Add user notifications --deep`
- `/flux:scope docs/feature-spec.md`

If empty, ask: "What should I scope? Describe the feature or bug in 1-5 sentences."

## Detect Mode

Parse arguments for `--deep` flag. Default is quick mode.

```
SCOPE_MODE = "--deep" in arguments ? "deep" : "quick"
```

## Setup

```bash
FLOWCTL="${OPENCODE_PLUGIN_ROOT}/scripts/fluxctl"
$FLOWCTL init --json
```

---

# PHASE 1: PROBLEM SPACE

## Step 1: Core Desire (Diverge)

**Goal**: Understand WHY this is being requested.

**CRITICAL**: Use `mcp_question` tool for all questions.

### Quick Mode Questions (pick 2-3):
- "Why do we need this? What's the business driver?"
- "What happens if we don't build this?"
- "Who asked for this and what triggered it?"

### Deep Mode Questions (ask all):
- "Why does the stakeholder want this?"
- "What's the underlying business need?"
- "What happens if we don't build this?"
- "Is this solving a symptom or root cause?"
- "What's the opportunity cost of building this?"

**Output**: Capture core desire in working memory.

## Step 2: Reasoning Chain (Diverge)

**Goal**: Validate the logic from problem to proposed solution.

### Quick Mode (1-2 questions):
- "The ask is X. Is X actually the right solution to the underlying problem?"

### Deep Mode (3-4 questions):
- "What assumptions are we making?"
- "Does the reasoning hold? Walk me through the logic."
- "What would have to be true for this to be the right approach?"
- "Are there simpler alternatives we haven't considered?"

**Output**: Capture assumptions and reasoning validation.

## Step 3: User Perspective (Diverge)

**Goal**: Understand how users will experience this.

### Quick Mode (1-2 questions):
- "How would users react to this? What's their current workaround?"

### Deep Mode (3-4 questions):
- "Who are the users affected by this?"
- "What's their current workaround?"
- "What would delight them vs. just satisfy them?"
- "How will they discover and learn this feature?"

**Output**: Capture user perspective.

## Step 4: Blind Spots (Diverge)

**Goal**: Surface what might be missing.

### Quick Mode (1 question):
- "What are we not thinking about? Who else is affected?"

### Deep Mode (2-3 questions):
- "What are we not thinking about?"
- "Who else is affected by this change?"
- "What related problems exist that we might be ignoring?"

**Output**: Capture blind spots.

## Step 5: Risks (Diverge)

**Goal**: Identify what could go wrong.

### Quick Mode (1 question):
- "What's the biggest risk or what could go wrong?"

### Deep Mode (3-4 questions):
- "What could go wrong with this direction?"
- "What are the risks of building this?"
- "What are the risks of NOT building this?"
- "What's the rollback plan if this fails?"

**Output**: Capture risks.

## Step 6: Problem Statement (Converge)

**Goal**: Synthesize into one clear problem statement.

Present synthesis:
```
Based on our discussion:
- Core need: [summary]
- Key assumptions: [list]
- User impact: [summary]
- Main risk: [summary]

Proposed problem statement:
"[One sentence problem statement]"

Does this capture it? What would you change?
```

Use `mcp_question` to confirm or refine.

**Output**: Final problem statement.

---

# PHASE 2: SOLUTION SPACE

## Step 7: Create Epic

Create the epic with the problem statement:

```bash
$FLOWCTL epic create --title "<Short title from problem statement>" --json
```

Write the problem space findings to the epic spec.

## Step 8: Research (Diverge)

**Check configuration:**
```bash
$FLOWCTL config get memory.enabled --json
$FLOWCTL config get scouts.github --json
```

**Run scouts in parallel**:

| Scout | Purpose | Required |
|-------|---------|----------|
| `flux:repo-scout` | Grep/Glob/Read patterns | YES |
| `flux:practice-scout` | Best practices + pitfalls | YES |
| `flux:docs-scout` | External documentation | YES |
| `flux:github-scout` | Cross-repo patterns | IF scouts.github |
| `flux:memory-scout` | Project memory | IF memory.enabled |
| `flux:epic-scout` | Dependencies on open epics | YES |
| `flux:docs-gap-scout` | Docs needing updates | YES |

Must capture:
- File paths + line refs
- Existing code to reuse
- Similar patterns / prior work
- External docs links
- Project conventions

## Step 9: Task Creation (Converge)

**Task sizing rule**:

| Size | Files | Acceptance Criteria | Action |
|------|-------|---------------------|--------|
| **S** | 1-2 | 1-3 | Combine with related work |
| **M** | 3-5 | 3-5 | Target size |
| **L** | 5+ | 5+ | Split into M tasks |

Create tasks under the epic:

```bash
$FLOWCTL task create --epic <epic-id> --title "<Task title>" --json
$FLOWCTL task create --epic <epic-id> --title "<Task title>" --deps <dep1> --json
```

## Step 10: Validate

```bash
$FLOWCTL validate --epic <epic-id> --json
```

Fix any errors before completing.

---

## Completion

Show summary:

```
Epic <epic-id> created: "<title>"

Problem Statement:
"<one sentence>"

Tasks: N total | Sizes: Xs S, Ym M

Next steps:
1) Start work: /flux:work <epic-id>
2) Review the plan: /flux:plan-review <epic-id>
```

## Philosophy

> "The constraint used to be 'can we build it.' Now it's 'do we know what we're building.'"

**The bottleneck has flipped.** Agents can prototype faster than any team ever could. Execution is cheap. Clarity is the constraint.

The Double Diamond forces you to:
1. **Diverge** on the problem — explore broadly
2. **Converge** on the problem — commit to one clear statement
3. **Diverge** on solutions — research options, consider alternatives
4. **Converge** on solution — create actionable tasks

Quick mode gets you enough to start. Deep mode is for high-stakes or ambiguous features. Both give you clarity before execution.
