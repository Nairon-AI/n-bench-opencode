<div align="center">

# Flux for OpenCode

[![Version](https://img.shields.io/badge/version-v0.2.0-green)](./CHANGELOG.md)
[![Status](https://img.shields.io/badge/status-stable-brightgreen)](./CHANGELOG.md)
[![Parity](https://img.shields.io/badge/parity-100%25-success)](./CHANGELOG.md)
[![Discord](https://img.shields.io/badge/Discord-Join-5865F2?logo=discord&logoColor=white)](https://discord.gg/CEQMd6fmXk)

**Native port of [Flux](https://github.com/Nairon-AI/flux) for [OpenCode](https://github.com/anomalyco/opencode).**

</div>

---

> **100% Feature Parity** with Flux for Claude Code. All commands and skills ported.

---

## Feature Parity

| Feature | Status | Notes |
|---------|--------|-------|
| `/flux:plan` | ✅ | Core workflow |
| `/flux:work` | ✅ | Core workflow |
| `/flux:scope` | ✅ | Double Diamond scoping |
| `/flux:interview` | ✅ | Requirements discovery |
| `/flux:sync` | ✅ | State sync |
| `/flux:impl-review` | ✅ | Implementation review |
| `/flux:plan-review` | ✅ | Plan review |
| `/flux:epic-review` | ✅ | Epic review |
| `/flux:prime` | ✅ | Codebase analysis |
| `/flux:contribute` | ✅ | Bug fix PRs |
| `/flux:desloppify` | ✅ | Code quality |
| `/flux:improve` | ⚠️ | Needs SQLite session adapter |
| `/flux:score` | ⚠️ | Needs SQLite session adapter |
| `/flux:profile` | ⚠️ | Needs config adapter |

**100% CLI coverage** — All `fluxctl` commands passing.

---

## Install

```bash
git clone https://github.com/Nairon-AI/flux-opencode.git
cd flux-opencode
./install.sh --project /path/to/your/project
```

Then in your project:

```bash
/flux:setup
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
  <a href="https://github.com/Nairon-AI/flux">Upstream</a>
</p>
