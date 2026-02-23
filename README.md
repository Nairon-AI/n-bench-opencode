<div align="center">

# N-bench for OpenCode

[![Version](https://img.shields.io/badge/version-v0.1.0-green)](./CHANGELOG.md)
[![Status](https://img.shields.io/badge/status-experimental-orange)](./CHANGELOG.md)
[![Discord](https://img.shields.io/badge/Discord-Join-5865F2?logo=discord&logoColor=white)](https://discord.gg/CEQMd6fmXk)

**Native port of [N-bench](https://github.com/Nairon-AI/n-bench) for [OpenCode](https://github.com/anomalyco/opencode).**

</div>

---

> **Experimental.** Active port tracking upstream. Expect rough edges.

---

## Feature Parity

| Feature | Status | Why |
|---------|--------|-----|
| `/nbench:plan` | ✅ | Core workflow, fully ported |
| `/nbench:work` | ✅ | Core workflow, fully ported |
| `/nbench:interview` | ✅ | Core workflow, fully ported |
| `/nbench:sync` | ✅ | Core workflow, fully ported |
| `/nbench:impl-review` | ✅ | Core workflow, fully ported |
| `/nbench:plan-review` | ✅ | Core workflow, fully ported |
| `/nbench:epic-review` | ✅ | Core workflow, fully ported |
| `/nbench:prime` | ✅ | Core workflow, fully ported |
| `/nbench:improve` | ❌ | Upstream reads Claude Code JSONL sessions (`~/.claude/`); OpenCode uses SQLite |
| `/nbench:score` | ❌ | Same — needs SQLite session adapter |
| `/nbench:profile` | ⚠️ | Skills detection reads `~/.claude/settings.json`; needs config adapter |

**96% CLI coverage** — 24/25 `nbenchctl` commands passing.

---

## Install

```bash
git clone https://github.com/Nairon-AI/n-bench-opencode.git
cd n-bench-opencode
./install.sh --project /path/to/your/project
```

Then in your project:

```bash
/nbench:setup
```

---

## Requirements

- [OpenCode](https://github.com/anomalyco/opencode)
- Python 3.9+
- jq

---

## CLI Test Results

| Command | Status | Command | Status |
|---------|--------|---------|--------|
| `init` | ✅ | `memory init` | ✅ |
| `detect` | ✅ | `memory add` | ✅ |
| `status` | ✅ | `memory list` | ✅ |
| `config get/set` | ✅ | `checkpoint save` | ✅ |
| `epic create` | ✅ | `checkpoint restore` | ✅ |
| `epics` | ✅ | `validate` | ✅ |
| `task create` | ✅ | `cat` | ✅ |
| `tasks` | ✅ | `block` | ✅ |
| `show` | ✅ | `dep add` | ✅ |
| `ready` | ✅ | `ralph *` | ✅ |
| `start` | ✅ | `opencode *` | ✅ |
| `done` | ✅ | `list` | ✅ |

---

## License

MIT

---

<p align="center">
  <a href="https://discord.gg/CEQMd6fmXk">Discord</a> · 
  <a href="https://github.com/Nairon-AI/n-bench">Upstream</a>
</p>
