# ☄️ coding-suisei

**A quality-gated coding workflow skill patch for [z.ai](https://z.ai) web — GLM-5 & GLM-5-Turbo.**

Enhances the built-in `coding-agent` skill with mandatory quality gates, a project knowledge base, platform-specific error patterns, and a `fullstack-dev` routing wrapper — all deployed via a single `setup.sh` script.

---

## Target Platform

This patch targets the **z.ai web** interface (https://z.ai) running on the following models:

| Model | Role | Notes |
|-------|------|-------|
| **GLM-5** | Primary | Full coding sessions, complex reasoning, architecture design |
| **GLM-5-Turbo** | Fast tasks | Quick fixes, simple scripts, shorter interactions |

### How z.ai Skills Work

z.ai web uses a **hardcoded skill whitelist** (`<available_skills>`) to match user prompts to skills. When a match is found, the platform loads the corresponding `SKILL.md` file from the `skills/` directory, injecting its content into the LLM context. Key behaviors discovered through testing:

1. **Trigger matching is platform-controlled** — The `<available_skills>` block is injected by the platform, and the LLM matches user prompts against skill descriptions listed there. Custom skill descriptions in `SKILL.md` on disk do **not** expand the trigger keywords.

2. **Post-invoke disk load** — Once a skill is invoked (via `Skill(command='X')`), the platform loads the `SKILL.md` from `~/my-project/skills/X/SKILL.md` on disk. This is where patched content takes effect.

3. **Skills directory persists** — Files in `~/my-project/skills/` survive between sessions, so patches installed via `setup.sh` remain active until explicitly removed.

4. **First-prompt bootstrap** — For the `fullstack-dev` routing wrapper to become active, the first prompt in a session must match the built-in `fullstack-dev` description (keywords like Next.js, React, dashboard, UI). Once loaded, the wrapper can route subsequent prompts to `coding-suisei`.

---

## What This Patch Does

```
                        ┌─────────────────────────────────────────┐
                        │          z.ai web (GLM-5 / Turbo)        │
                        │                                         │
                        │   User Prompt                           │
                        │       │                                 │
                        │       ▼                                 │
                        │   <available_skills> matching           │
                        │       │                                 │
  ┌─────────────────────┼───────────────┐                         │
  │                     ▼               │                         │
  │        fullstack-dev (built-in)     │                         │
  │               │                     │                         │
  │               ▼                     │                         │
  │      ROUTING DECISION               │                         │
  │       ┌─────────┴─────────┐         │                         │
  │       ▼                   ▼         │                         │
  │   Web Dev            General Code   │                         │
  │   (Next.js/React)    (Python/etc)   │                         │
  │       │                   │         │                         │
  │       ▼                   ▼         │                         │
  │   Original          Skill('coding-  │                         │
  │   Handler           suisei') ☄️     │                         │
  │                     │               │                         │
  └─────────────────────┼───────────────┘                         │
                        │                                         │
                        ▼                                         │
              ┌──────────────────┐                               │
              │   coding-suisei  │  Quality Gates + Knowledge     │
              │   SKILL.md       │  Base + Error Patterns         │
              │   (from disk)    │                                │
              └──────────────────┘                               │
                        │                                         │
                        ▼                                         │
                 Better Code Output                               │
                        │                                         │
                        └─────────────────────────────────────────┘
```

### Component 1: `coding-suisei` Skill

A replacement for the built-in `coding-agent` that enforces structured quality constraints on every coding task. See the [comparison table](#default-coding-agent-vs-coding-suisei) below for the full list of differences.

### Component 2: `fullstack-dev` Routing Wrapper

Patches the built-in `fullstack-dev` skill's `SKILL.md` with a routing decision layer that separates web development tasks from general coding tasks, delegating the latter to `coding-suisei`.

---

## Default `coding-agent` vs `coding-suisei`

| Aspect | Default `coding-agent` (v1.0.4) | `coding-suisei` (v3.0.0) |
|--------|-------------------------------|--------------------------|
| **Workflow** | Soft guidance: "Plan Before Code", "Verify Everything" | **4 mandatory quality gates** enforced as hard constraints (GATE 1→2→3→4) |
| **Error Handling** | "Report error to user, suggest fixes, wait" | **Error Stop Protocol**: STOP immediately, diagnose root cause, fix root not symptom, re-verify |
| **Code Quality** | No specific constraints | **Hard constraints**: no `any`, functions <50 lines, no magic numbers, no `console.log`, explicit return types |
| **Knowledge Base** | None — no reference files for environment specifics | **4 files**: architecture (sandbox layout), conventions (naming, imports), gotchas (platform quirks), error patterns (error→fix lookup) |
| **Workflow Templates** | Basic `planning.md` (step format) + `execution.md` (progress tracking) | **Structured templates**: plan template with risk assessment, code review checklist (structure/type/error/security/performance/cleanliness), gates with enforcement |
| **Verification** | "Suggest running tests", "suggest taking screenshot" | **Pre-delivery checklist**: lint, type check, mental trace, test run, then review checklist with 20+ items |
| **Trigger Confirmation** | None — no way to verify skill loaded | **☄️ mandatory first output** — user sees ☄️ and knows the skill is active |
| **Import Order** | Not specified | **Strict enforced order**: external → internal → relative → types |
| **Code Smell Ban** | Not specified | **Explicit ban list**: console.log, silent catch, callback hell, copy-paste logic, commented-out code, TODO without context, hardcoded strings, boolean params |
| **Platform Awareness** | Generic — no sandbox-specific knowledge | **z.ai-specific**: Caddy gateway routing, `?XTransformPort=` pattern, single `/` route, `z-ai-web-dev-sdk` backend-only, `skills/` persistence |
| **Error Pattern Library** | None | **Lookup table**: 15+ common errors with cause→fix mapping (Module not found, ECONNREFUSED, hydration mismatch, etc.) |
| **Debug Flow** | "Report to user, wait" | **Structured flow**: read error → check dev.log → identify layer → match patterns → isolate |
| **Scope Statement** | Generic "guidance, not execution" | **Honest description**: explicitly states what it is (workflow standard) and what it isn't (autonomous agent) |
| **File Count** | 6 files (SKILL.md + 5 reference) | **12 files** (SKILL.md + 4 knowledge + 3 workflow + 4 reference) |

### What `coding-agent` Does Well (Kept in coding-suisei)

- User-controlled execution (no autonomous actions)
- Preference storage in `~/code/memory.md` (only when explicitly requested)
- Multi-task state tracking with request labels
- Progress file output when requested

### What `coding-suisei` Adds On Top

- Mandatory quality gates that cannot be skipped
- Platform-specific knowledge (z.ai sandbox constraints, gateway routing)
- Hard coding constraints (no `any`, 50-line limit, import order)
- Error pattern library with root cause analysis
- Structured code review checklist (6 categories, 20+ items)
- Trigger confirmation marker (☄️) for reliability verification
- Plan template with risk assessment and dependency tracking

---

## Quick Install

```bash
git clone https://github.com/hoshiyomiX/coding-suisei.git /tmp/cap
cd /tmp/cap && bash setup.sh
```

Setup is **idempotent** — safe to re-run any time. It will:
- Create/overwrite `coding-suisei` skill files in `~/my-project/skills/coding-suisei/`
- Patch `fullstack-dev/SKILL.md` with routing wrapper
- Back up original `fullstack-dev/SKILL.md` as `SKILL.md.original`
- Migrate preferences from old `coding-agent` if present

---

## Trigger Marker

`☄️` — when `coding-suisei` loads, the LLM **must** output this emoji as its very first response before any other content. If you see ☄️, the patch is active and quality gates are enforced.

---

## How to Invoke coding-suisei

Because `coding-suisei` is not in the z.ai built-in whitelist, it relies on two paths to get invoked:

### Path 1: Direct invocation (most reliable ~90%)

Use the skill name as a prefix in your prompt:

```
coding-suisei: buat fungsi python merge sort
coding-suisei: refactor kode react component ini
coding-suisei: debug error TypeError Cannot read properties of undefined
```

### Path 2: Through fullstack-dev wrapper (~70-90%)

Start the session with a web dev keyword to trigger `fullstack-dev`, then on subsequent prompts the routing wrapper delegates general coding tasks to `coding-suisei`:

```
# First prompt — triggers fullstack-dev (loads wrapper)
> buat dashboard dengan Next.js

# Second prompt — wrapper routes to coding-suisei
> coding-suisei: buat fungsi helper untuk format tanggal
```

| Prompt Pattern | Invokes | Reliability |
|---|---|---|
| `coding-suisei: <task>` | coding-suisei directly | ~90% |
| `gunakan coding-suisei untuk <task>` | coding-suisei directly | ~85% |
| `☄️ <coding task>` | coding-suisei (marker match) | ~60% |
| `buat dashboard dengan Next.js` (first prompt) | fullstack-dev → wrapper loaded | ~90% |
| General coding (after wrapper loaded) | fullstack-dev → routes to coding-suisei | ~80% |
| `buat fungsi python merge sort` (cold session) | ❌ may not trigger any skill | ~10% |

> **Recommendation**: Always prefix with `coding-suisei:` for general coding tasks. The z.ai trigger matching is unreliable for ambiguous prompts without a skill name.

---

## Installed Structure

```
~/my-project/skills/
├── coding-suisei/                      # Deployed skill
│   ├── SKILL.md                        # Core: quality gates + trigger confirmation
│   │                                   #   version 3.0.0
│   ├── knowledge/                      # Tier 1 Knowledge Base
│   │   ├── architecture.md             # z.ai sandbox constraints, directory layout,
│   │   │                               #   service communication (Caddy gateway)
│   │   ├── conventions.md              # Naming rules, import order, TypeScript patterns,
│   │   │                               #   React patterns, CSS/styling rules
│   │   ├── gotchas.md                  # Platform quirks: single route, no localhost,
│   │   │                               #   XTransformPort, skills/ persistence, Prisma limits
│   │   └── error-patterns.md           # 15+ error→cause→fix entries organized by category
│   │                                   #   (runtime, build/lint, React, WebSocket)
│   ├── workflow/                       # Tier 1 Workflow Templates
│   │   ├── gates.md                    # Hard constraints: function limits, type rules,
│   │   │                               #   file rules, code smell ban list, import order
│   │   ├── plan-template.md            # Structured plan: problem, approach, files,
│   │   │                               #   dependencies, steps, risk assessment, verification
│   │   └── review-checklist.md         # 6-category review: structure, type safety,
│   │                                   #   error handling, security, performance, cleanliness
│   ├── memory-template.md              # Template for ~/code/memory.md preferences
│   ├── state.md                        # Multi-task request tracking
│   ├── criteria.md                     # When to save/never save user preferences
│   └── _migrated_from_coding_agent     # Migration marker (auto-created)
│
└── fullstack-dev/                      # Patched with routing wrapper
    ├── SKILL.md                        # Wrapper: ROUTING DECISION layer that separates
    │                                   #   web dev (original handler) from general coding
    │                                   #   (delegates to coding-suisei via Skill())
    └── SKILL.md.original               # z.ai platform original (backup for rollback)
```

---

## Quality Gates

The core differentiator. Four gates that the LLM must follow **in order** for every coding task. These are not suggestions — they are hard constraints.

### GATE 1: Understand Before Coding

Forces the LLM to demonstrate comprehension before writing any code. This prevents the common pattern of rushing to implement without fully understanding requirements.

- Restate the problem in your own words
- Identify edge cases and constraints
- List files that will be created or modified
- If the task is complex (3+ files, schema change, new endpoint), create a structured plan using the plan template with risk assessment

### GATE 2: Write with Constraints

Applies hard coding constraints during implementation. The LLM loads context-specific knowledge files as needed.

- Read `workflow/gates.md` for mandatory coding constraints
- Read `knowledge/conventions.md` for naming, imports, and patterns
- Read `knowledge/error-patterns.md` for environment-specific gotchas
- Each function must have a single responsibility
- Each function must include error handling

### GATE 3: Verify Before Delivery

Enforces verification before presenting code to the user. Not a "suggest testing" approach — an actual checklist.

- Run `bun run lint` (or equivalent linter)
- Check for type errors
- Trace through the code mentally with sample inputs
- If tests exist, run them
- Run through the full review checklist (6 categories, 20+ items)

### GATE 4: Error Stop Protocol

Forces a complete stop on any error instead of the common "continue past errors and fix later" pattern.

- **STOP** — do not continue past errors
- Diagnose the root cause (read logs, check stack traces, check `dev.log`)
- Fix the root cause, not the symptom
- Re-verify from GATE 3

---

## Knowledge Base

Four reference files that the LLM loads contextually based on the task type. Each file targets a specific category of platform-specific knowledge.

### `knowledge/architecture.md`

Covers the z.ai sandbox environment: directory layout, service communication via Caddy gateway, single-port constraint, and key facts (Bun runtime, Next.js 16, TypeScript 5 strict).

### `knowledge/conventions.md`

Defines naming rules (PascalCase components, camelCase utilities, UPPER_SNAKE constants), strict import order, TypeScript patterns (interfaces vs types, `unknown` over `any`), React patterns (`use client`/`use server`, state management), and styling rules.

### `knowledge/gotchas.md`

Documents non-obvious platform behaviors: `localhost` not accessible to users, `bun run build` not supported, `?XTransformPort=` requirement for cross-service communication, single `/` route limitation, `z-ai-web-dev-sdk` backend-only, `skills/` directory persistence between sessions.

### `knowledge/error-patterns.md`

A lookup table of 15+ common errors organized by category (runtime, build/lint, React, WebSocket) with cause and fix for each. Includes a structured debug flow: read error → check dev.log → identify layer → match pattern → isolate.

---

## Error Patterns Sample

| Error | Category | Cause | Fix |
|-------|----------|-------|-----|
| `Module not found` | Runtime | Package not installed | `bun add <package>` |
| `Port 3000 already in use` | Runtime | Previous dev server running | `lsof -ti:3000 \| xargs kill` |
| `ECONNREFUSED` | Runtime | Using absolute URL | Use relative: `/api/...?XTransformPort=...` |
| `XTransformPort` timeout | Runtime | Wrong port or service down | Check service running, verify port |
| `Type 'X' not assignable` | Build/Lint | Missing type annotation | Add explicit return type, use Zod |
| `Too many re-renders` | React | setState in render body | Move to useEffect or handler |
| `Hydration mismatch` | React | Server/client render diff | Move dynamic content to `'use client'` |
| `socket.io connection failed` | WebSocket | Using direct URL | Use `io('/?XTransformPort=<port>')` |

---

## What This Is (Honest)

This is a **coding workflow standard** — a set of quality constraints injected into the LLM context when the skill is invoked. It is not an autonomous agent, not a code executor, and not a persistent runtime. It is a text file (`SKILL.md`) that tells the LLM how to behave when writing code.

**What it DOES**: forces the LLM to follow structured quality gates, load project-specific knowledge, avoid common coding mistakes, and verify code before delivery.

**What it does NOT**: execute code autonomously, access external services, modify its own files, make independent decisions, or take action without user awareness.

---

## Version History

| Version | Changes |
|---------|---------|
| **v3.0.0** | Renamed `coding-agent` → `coding-suisei`. Added Tier 1 upgrades: 4 mandatory quality gates, project knowledge base (4 files), error pattern library, workflow templates (plan + review + gates), trigger confirmation marker (☄️). Added `fullstack-dev` routing wrapper. |
| v2.2 | Fixed repo structure (independent git), removed bootstrap `Invoke Skill()` instruction from setup.sh (was triggering LLM refusal). |
| v2.0 | Initial `fullstack-dev` routing wrapper + `coding-agent` skill patch. |

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

| Problem | Cause | Solution |
|---------|-------|---------|
| ☄️ does not appear | Skill not invoked by z.ai | Use `coding-suisei:` prefix, or start session with a web dev keyword to load the fullstack-dev wrapper first |
| setup.sh refused by LLM | AI manipulation detection | Fixed in v2.2 — script no longer contains `Invoke Skill()` instructions |
| fullstack-dev routing doesn't delegate to coding-suisei | Wrapper not loaded yet | The wrapper only activates after fullstack-dev is invoked in the current session. Start with a web dev keyword first |
| General coding prompt triggers nothing | z.ai trigger matching is unreliable for non-whitelisted skills | Always use `coding-suisei:` prefix for guaranteed invocation |
| `coding-agent` still appears in output | Old skill cached or wrapper not active | Run `setup.sh` again. The fullstack-dev wrapper should delegate to coding-suisei, not coding-agent |
| Skills disappear after session | Session cleanup | This shouldn't happen — `skills/` directory persists. If it does, re-run setup.sh |

---

## Repository Structure

```
coding-suisei/
├── README.md                            # This file
├── setup.sh                             # Idempotent install script (v3.0)
└── skill/
    ├── coding-suisei/
    │   ├── SKILL.md                     # Core skill definition (quality gates + trigger)
    │   ├── knowledge/                   # 4 knowledge base files
    │   │   ├── architecture.md
    │   │   ├── conventions.md
    │   │   ├── gotchas.md
    │   │   └── error-patterns.md
    │   ├── workflow/                    # 3 workflow template files
    │   │   ├── gates.md
    │   │   ├── plan-template.md
    │   │   └── review-checklist.md
    │   ├── memory-template.md
    │   ├── state.md
    │   └── criteria.md
    └── fullstack-dev-SKILL.md           # Routing wrapper (patches fullstack-dev)
```
