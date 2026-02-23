<div align="center">

# N-bench for OpenCode

[![Version](https://img.shields.io/badge/version-v0.1.0-green)](./CHANGELOG.md)
[![Status](https://img.shields.io/badge/status-experimental-orange)](./CHANGELOG.md)
[![Discord](https://img.shields.io/badge/Discord-Join-5865F2?logo=discord&logoColor=white)](https://discord.gg/CEQMd6fmXk)

**Plan-first development for OpenCode. Native port of N-bench.**

</div>

---

> **Experimental.** This is an active port tracking the upstream N-bench plugin. Expect rough edges.

---

## What Is This?

N-bench brings structured, plan-first development to [OpenCode](https://github.com/anomalyco/opencode). Instead of diving straight into code, you:

1. **Interview** — Clarify requirements upfront
2. **Plan** — Break work into dependency-ordered tasks
3. **Build** — Execute tasks with full context re-anchoring
4. **Review** — Catch issues before they compound

Everything lives in your repo (`.nbench/` directory). No external services. Uninstall by deleting the directory.

---

## Quick Start

### Install

```bash
# Clone this repo
git clone https://github.com/Nairon-AI/n-bench-opencode.git

# Install to your project
cd n-bench-opencode
./install.sh --project /path/to/your/project
```

### Initialize

In your project with OpenCode:

```bash
/nbench:setup
```

This creates `.nbench/` with the CLI and configuration.

### Basic Usage

```bash
# Plan a feature
/nbench:plan Add user authentication

# Execute tasks
/nbench:work fn-1.1
/nbench:work fn-1.2

# Review implementation
/nbench:impl-review
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/nbench:setup` | Initialize N-bench in your project |
| `/nbench:interview <topic>` | Deep-dive requirements gathering |
| `/nbench:plan <feature>` | Create epic with dependency-ordered tasks |
| `/nbench:work <task-id>` | Execute a task with context reload |
| `/nbench:sync` | Sync specs after implementation drift |
| `/nbench:impl-review` | Review current implementation |
| `/nbench:epic-review <epic>` | Review epic completion |
| `/nbench:plan-review` | Review plan before execution |
| `/nbench:prime` | Assess codebase agent-readiness |
| `/nbench:improve` | Analyze sessions, recommend tools |
| `/nbench:score` | Compute AI-native capability score |
| `/nbench:profile` | Export/share your SDLC profile |

---

## How It Works

### Epic-Task Model

Every unit of work belongs to an epic (`fn-N`). Tasks are `fn-N.M` and inherit context from the epic spec.

```
fn-1/                    # Epic directory
├── spec.md              # Requirements and context
├── plan.md              # Task breakdown
├── fn-1.1.md            # Task 1 spec
├── fn-1.2.md            # Task 2 spec
└── status.json          # Progress tracking
```

### Re-anchoring

Before every task, N-bench reloads:
- Epic spec and plan
- Task description and acceptance criteria
- Git state and recent changes
- Dependencies and blockers

This prevents context drift across long sessions.

### Reviews

Cross-model reviews catch blind spots. Configure your preferred backend:

```bash
nbenchctl config set review.backend opencode  # or: rp, none
```

---

## Directory Structure

```
.nbench/
├── bin/
│   ├── nbenchctl        # CLI wrapper
│   └── nbenchctl.py     # CLI implementation
├── config.json          # Project configuration
├── epics/
│   └── fn-1/            # Epic directories
└── usage.md             # Quick reference
```

---

## Requirements

- [OpenCode](https://github.com/anomalyco/opencode)
- Python 3.9+
- jq (for JSON processing)

---

## Upstream

This is a port of [N-bench](https://github.com/Nairon-AI/n-bench) for OpenCode.

The canonical Claude Code plugin has more features and faster updates. Use this port if you prefer OpenCode.

---

## Troubleshooting

**"No .nbench/ found"**
Run `/nbench:setup` first to initialize.

**Tasks not appearing**
Check `nbenchctl list` to see current state. Run `nbenchctl validate --fix` to repair issues.

**Review backend errors**
Ensure your review backend is configured: `nbenchctl config get review.backend`

---

## License

MIT

---

<p align="center">
  <a href="https://discord.gg/CEQMd6fmXk">Discord</a> · 
  <a href="https://github.com/Nairon-AI/n-bench">Upstream</a>
</p>
