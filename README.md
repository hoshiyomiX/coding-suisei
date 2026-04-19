<div align="center">

# ☄️ stellar-coding-agent

**Deterministic coding workflow for LLM agents**

[![Version](https://img.shields.io/badge/version-5.0.0-blue.svg)](CHANGELOG.md)

Structures coding tasks as a **phase state machine** with traceability IDs, artifact templates, and source state verification. Designed for the [z.ai](https://z.ai) platform.

```text
IDLE → SPECIFY → PLAN → IMPLEMENT → VERIFY → DELIVER
  ↑                                        │
  └──── Error Recovery ◄───────────────────┘
```

</div>

---

## Quick Start

```bash
# 1. Clone into your project
cd ~/my-project
git clone https://github.com/hoshiyomiX/stellar-coding-agent.git _sc
cp -r _sc/skill/stellar-coding-agent skill/
cp _sc/setup.sh setup.sh
cp _sc/boot.sh boot.sh
rm -rf _sc

# 2. Install (copies skill/ → platform skills/)
bash setup.sh

# 3. Bootstrap each new session (self-heals + starts dev server)
bash boot.sh
```

Invoke in any session:

```
Skill(command="stellar-coding-agent")
```

Look for `☄️ STELLAR · v5.0.0 · ACTIVE` — confirms the framework loaded.

## What Each Command Does

| Command | Purpose |
|---------|---------|
| `bash setup.sh` | One-time install: copies `skill/` (git) → `skills/` (platform). Run after cloning. |
| `bash boot.sh` | Per-session bootstrap: self-heals skill files if wiped, deploys splash page, starts dev server. |

## Uninstall

```bash
rm -rf ~/my-project/skills/stellar-coding-agent ~/my-project/skill ~/my-project/setup.sh ~/my-project/boot.sh
```

---

## How It Works

The framework provides **tools, not rules**. Each phase produces an artifact the next phase consumes, creating a chain that prevents skipping straight to code.

| Phase | Output | Why |
|-------|--------|-----|
| **SPECIFY** | Problem specification | Forces precise thinking before writing code |
| **PLAN** | Implementation plan with Traceability IDs | Maps requirements to code locations |
| **IMPLEMENT** | Annotated code | Each block references its Traceability ID |
| **VERIFY** | Evidence-based report | Automated checks + edge case tracing |
| **DELIVER** | Summary + compliance report | Traceable record of what was done |

**Traceability IDs** (`IMPL-001`, `IMPL-002`, ...) chain through every phase — requirement → code → verification. If something is dropped, the gap is visible.

### Source State Verification (SSV)

Before analyzing git repositories, the framework verifies data freshness:

```bash
git fetch → compare HEAD to origin → sync if behind → proceed
```

Prevents stale-checkout analysis (the failure that inspired this feature).

### Error Recovery

Structured 5-step decision tree: **capture → classify → identify actions → fix → re-verify**. Git operations have explicit safety rules — `git fetch` before `git pull`, no force push without user instruction, stop all git ops if infrastructure blocks.

### Session Persistence

The z.ai platform may wipe the `skills/` directory on session reset. `boot.sh` handles this automatically by copying git-tracked `skill/` → `skills/` before starting the dev server. No manual re-install needed.

---

## File Structure

```
stellar-coding-agent/
├── boot.sh                           # Session bootstrap (self-heal + dev server)
├── setup.sh                          # One-time installer
├── skill/stellar-coding-agent/       # Git-tracked source (copied to skills/ on install)
│   ├── SKILL.md                      # Core framework (phases, SSV, error recovery, PCR)
│   ├── CHANGELOG.md                  # Version history
│   ├── procedure/
│   │   ├── phases.md                 # Phase definitions with entry/exit criteria
│   │   ├── templates/
│   │   │   ├── problem-spec.md       # SPECIFY artifact
│   │   │   ├── implementation-plan.md # PLAN artifact (Traceability IDs)
│   │   │   ├── verification-report.md # VERIFY artifact (evidence capture)
│   │   │   └── incident-report.md    # Error documentation
│   │   └── decision-trees/
│   │       └── error-resolution.md   # 5-step structured decision tree
│   ├── constraints/
│   │   ├── code-standards.md         # Function, file, import, quality standards
│   │   └── type-safety.md            # Type system constraints with examples
│   ├── knowledge/
│   │   ├── architecture.md           # Runtime environment, directory layout, service topology
│   │   ├── conventions.md            # Coding conventions, state management, import order
│   │   ├── platform-constraints.md   # Sandbox-specific limitations (gateway, routes, SDK)
│   │   └── error-patterns.md         # Common errors with cause → fix mapping
│   └── memory-template.md            # Template for user preference storage
└── skills/stellar-coding-agent/      # Platform-managed (auto-healed by boot.sh)
    └── assets/
        └── page.tsx                  # Custom splash page (closeable + minimizable)
```

---

## Philosophy (v5.0.0)

> **Stop telling the LLM what it MUST do. Start giving it tools it WANTS to use.**

v5.0.0 is a philosophical reset based on an honest audit:

- **What works**: Traceability IDs, templates, SSV, error decision tree — they work because they're useful, not because they're mandatory
- **What doesn't work**: Compliance enforcement language ("must", "mandatory", "do not skip") — has no measurable effect on LLM behavior regardless of wording
- **What's honest**: The framework cannot guarantee compliance, force behavior, or persist across sessions. It's text in a skill file. The user is the final judge of quality.

---

## Version History

| Version | Summary |
|---------|---------|
| [**v5.0.0**](CHANGELOG.md) | Philosophical reset. Removed compliance theater, kept useful tools. Added `boot.sh` self-heal. |
| [v4.6.0](CHANGELOG.md) | Source State Verification (SSV). Evidence tiers in attestation. |
| [v4.5.0](CHANGELOG.md) | Coexistence mode with fullstack-dev. *(Removed in v5.0.0)* |
| [v4.4.0](CHANGELOG.md) | Git error classification and safety rules. |
| [v4.3.0](CHANGELOG.md) | OUTCOME gate, evidence requirement, defect counter. |
| [v4.0.0](CHANGELOG.md) | Complete redesign: phase state machine, artifact templates, traceability IDs. |
