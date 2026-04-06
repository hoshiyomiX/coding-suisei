# ☄️ coding-suisei Patch

**Persistent coding workflow skill for the Clawd platform.**

Quality-gated coding workflow that enforces structured development processes — understand before coding, write with constraints, verify before delivery. Deployed via `setup.sh`.

---

## What It Does

1. **Deploys `coding-suisei` skill** — a quality-gated coding workflow with:
   - 4 mandatory quality gates (Understand → Write → Verify → Error Stop)
   - Project knowledge base (architecture, conventions, gotchas, error patterns)
   - Workflow templates (plan template, review checklist, gates)
   - Trigger confirmation marker (☄️) to verify skill loaded

2. **Patches `fullstack-dev`** with a routing wrapper:
   - Web dev tasks (Next.js, React, UI) → original fullstack-dev flow
   - General coding tasks (Python, algorithms, scripts, debugging) → delegates to `coding-suisei`

---

## Quick Install

```bash
git clone https://github.com/hoshiyomiX/coding-agent-patch.git /tmp/cap
cd /tmp/cap && bash setup.sh
```

Setup is **idempotent** — safe to re-run. It will:
- Create/overwrite `coding-suisei` skill files
- Patch `fullstack-dev/SKILL.md` with routing wrapper
- Back up original `fullstack-dev/SKILL.md` as `SKILL.md.original`
- Migrate memory from old `coding-agent` if present

---

## Trigger Marker

`☄️` — when the skill loads, the LLM **must** output this emoji as its very first response. If you see ☄️, the patch is active.

---

## How to Invoke coding-suisei

The platform uses hardcoded skill descriptions for trigger matching. `coding-suisei` is **not** in the platform's built-in whitelist, so it relies on two paths to get invoked:

### Path 1: Direct invocation (most reliable)

Use the skill name as a prefix in your prompt:

```
coding-suisei: buat fungsi python merge sort
coding-suisei: refactor kode react component ini
coding-suisei: debug error TypeError Cannot read properties of undefined
```

### Path 2: Through fullstack-dev wrapper

Start the session with a web dev keyword (Next.js, React, dashboard, UI), then on subsequent prompts the wrapper will route general coding tasks to coding-suisei automatically.

| Prompt Pattern | Invokes | Reliability |
|---|---|---|
| `coding-suisei: <task>` | coding-suisei directly | ~90% |
| `gunakan coding-suisei untuk <task>` | coding-suisei directly | ~85% |
| `☄️ <coding task>` | coding-suisei (marker match) | ~60% |
| `buat dashboard dengan Next.js` | fullstack-dev → wrapper | ~90% |
| `buat fungsi python merge sort` | ❌ may not trigger any skill | ~10% |

> **Recommendation**: Always prefix with `coding-suisei:` for general coding tasks.

---

## Architecture

### Installed Structure

```
~/my-project/skills/
├── coding-suisei/                  # Deployed skill
│   ├── SKILL.md                    # Core: quality gates + trigger confirmation (v3.0.0)
│   ├── knowledge/                  # Tier 1 Knowledge Base
│   │   ├── architecture.md         # Sandbox environment constraints & project structure
│   │   ├── conventions.md          # Naming, imports, file patterns, code style
│   │   ├── gotchas.md              # Platform-specific quirks & non-obvious behaviors
│   │   └── error-patterns.md       # Common errors → causes → fixes lookup table
│   ├── workflow/                   # Tier 1 Workflow Templates
│   │   ├── gates.md                # Mandatory coding constraints (no `any`, <50 lines, etc.)
│   │   ├── plan-template.md        # Structured plan format for complex tasks
│   │   └── review-checklist.md     # Pre-delivery verification checklist
│   ├── memory-template.md          # Template for ~/code/memory.md
│   ├── state.md                    # Multi-task state tracking
│   ├── criteria.md                 # Acceptance criteria template
│   └── _migrated_from_coding_agent # Migration marker (auto-created)
│
└── fullstack-dev/                  # Patched with routing wrapper
    ├── SKILL.md                    # Wrapper: routes web dev ↔ coding-suisei
    └── SKILL.md.original           # Platform original (backup for rollback)
```

### Routing Flow

```
User Prompt
    │
    ▼
Platform matches <available_skills> description
    │
    ├── Matches "fullstack-dev" ──► SKILL.md loaded
    │                                   │
    │                                   ▼
    │                            ROUTING DECISION
    │                                   │
    │                    ┌──────────────┴──────────────┐
    │                    ▼                              ▼
    │            Web Development              General Coding
    │            (Next.js, React)              (Python, scripts, etc.)
    │                    │                              │
    │                    ▼                              ▼
    │            Fullstack Dev               Skill('coding-suisei')
    │            Handler                     ☄️ loaded
    │
    └── Matches "coding-suisei" ──► SKILL.md loaded
                                     ☄️ confirmed
                                     Quality Gates active
```

---

## Quality Gates

The core feature of coding-suisei. Four mandatory gates that the LLM must follow for every coding task:

| Gate | Name | What It Does |
|------|------|-------------|
| **GATE 1** | Understand Before Coding | Restate problem, identify edge cases, list affected files, create plan if complex |
| **GATE 2** | Write with Constraints | Follow coding constraints (no `any`, <50 line functions, no magic numbers), load knowledge files |
| **GATE 3** | Verify Before Delivery | Run linter, check types, mental trace with sample inputs, run tests |
| **GATE 4** | Error Stop Protocol | STOP on any error, diagnose root cause, fix root not symptom, re-verify |

### Coding Constraints (from `workflow/gates.md`)

- No `any` type in TypeScript — use `unknown` + narrowing
- Functions under 50 lines, single responsibility
- No magic numbers — use named constants
- No `console.log` in production code
- Explicit return types on all functions
- No circular imports
- Strict import ordering: external → internal → relative → types

---

## Knowledge Base

Four reference files the LLM loads contextually:

| File | Loaded When |
|------|------------|
| `knowledge/architecture.md` | Starting a new feature or modifying project structure |
| `knowledge/conventions.md` | Writing any code (naming, file structure, patterns) |
| `knowledge/gotchas.md` | Working with the sandbox environment or platform APIs |
| `knowledge/error-patterns.md` | Debugging errors or unexpected behavior |

### Error Patterns Sample (from `knowledge/error-patterns.md`)

| Error | Common Cause | Fix |
|-------|-------------|-----|
| `Module not found` | Package not installed | `bun add <package>` |
| `Port 3000 already in use` | Previous dev server running | `lsof -ti:3000 \| xargs kill` |
| `ECONNREFUSED` | Using absolute URL | Change to relative: `/api/...?XTransformPort=...` |
| `PrismaClient not generated` | Schema changed but not pushed | `bun run db:push` |
| `Too many re-renders` | setState in render body | Move to useEffect or event handler |

---

## What This Is (Honest)

This is a **coding workflow standard** — a set of quality constraints injected into the LLM context when the skill is invoked. It is not an autonomous agent. It cannot execute code, make independent decisions, or persist memory on its own.

**What it DOES**: forces the LLM to follow structured quality gates, load project knowledge, and avoid common coding mistakes.

**What it does NOT**: execute code autonomously, access external services, modify its own files, or take action without user awareness.

---

## Version History

| Version | Changes |
|---------|---------|
| **v3.0.0** | Renamed `coding-agent` → `coding-suisei`, added Tier 1 upgrades (Quality Gates, Knowledge Base, Error Pattern Library, Workflow Templates), changed trigger marker to ☄️ |
| v2.2 | Fixed repo structure (independent git), removed bootstrap `Invoke Skill()` instruction from setup.sh |
| v2.0 | Initial fullstack-dev routing wrapper + coding-agent skill |

---

## Rollback

```bash
# Restore original fullstack-dev
cp ~/my-project/skills/fullstack-dev/SKILL.md.original ~/my-project/skills/fullstack-dev/SKILL.md

# Remove coding-suisei
rm -rf ~/my-project/skills/coding-suisei
```

---

## Troubleshooting

| Problem | Solution |
|---------|---------|
| ☄️ does not appear | Skill not invoked. Use `coding-suisei:` prefix, or start session with web dev keyword first |
| setup.sh refused by LLM | This was fixed in v2.2 — the script no longer contains `Invoke Skill()` instructions |
| fullstack-dev routing doesn't delegate | Ensure fullstack-dev was invoked first in the session (web dev keyword), then wrapper is active for subsequent prompts |
| General coding prompt triggers nothing | Use `coding-suisei:` prefix. Platform trigger matching is unreliable for ambiguous prompts |
| `coding-agent` still appears | Run setup.sh again — it will migrate memory and create marker file |

---

## Repository Structure

```
coding-agent-patch/
├── README.md                            # This file
├── setup.sh                             # Idempotent install script (v3.0)
└── skill/
    ├── coding-suisei/
    │   ├── SKILL.md                     # Core skill definition
    │   ├── knowledge/                   # 4 knowledge files
    │   ├── workflow/                    # 3 workflow templates
    │   ├── memory-template.md
    │   ├── state.md
    │   └── criteria.md
    └── fullstack-dev-SKILL.md           # Routing wrapper (patches fullstack-dev)
```
