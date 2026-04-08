# ☄️ stellar-coding-agent

**A deterministic coding workflow skill for [z.ai](https://z.ai) — GLM-5 & GLM-5-Turbo.**

Structures LLM-assisted coding as a phase state machine with mandatory artifact templates, traceability IDs, and structured verification. Produces consistent output across sessions.

Invoke directly: `Skill(command="stellar-coding-agent")`

---

## Quick Install

```bash
git clone https://github.com/hoshiyomiX/stellar-coding-agent.git /tmp/cap
cd /tmp/cap && bash setup.sh
```

After install, invoke in any session:

```
Skill(command="stellar-coding-agent")
```

You should see ☄️ as the first response — this confirms the framework is active.

---

## What Changed in v4.1

| Change | Reason |
|--------|--------|
| Removed fullstack-dev routing wrapper | The platform overwrites `fullstack-dev/SKILL.md` on invoke, silently destroying the bridge. Direct invocation of `stellar-coding-agent` is reliable without it. |
| setup.sh restores fullstack-dev to original | Cleans up wrapper from previous versions if present. |

---

## Architecture

```
stellar-coding-agent/
├── SKILL.md                              Core: phase state machine + QA attestation
├── CHANGELOG.md                          Version history
├── procedure/                            Workflow process
│   ├── phases.md                         Phase definitions with entry/exit criteria
│   ├── templates/
│   │   ├── problem-spec.md               SPECIFY artifact (7 required fields)
│   │   ├── implementation-plan.md        PLAN artifact (Traceability IDs)
│   │   ├── verification-report.md        VERIFY artifact (evidence capture)
│   │   └── incident-report.md            Error documentation (side-effect gating)
│   └── decision-trees/
│       └── error-resolution.md           5-step structured decision tree
├── constraints/                          Code quality rules
│   ├── code-standards.md                 Function, file, import, quality standards
│   └── type-safety.md                    Type system constraints with examples
├── knowledge/                            Platform-specific reference
│   ├── architecture.md                   Runtime environment, directory layout, service topology
│   ├── conventions.md                    Coding conventions, state management, import order
│   ├── platform-constraints.md           Sandbox-specific limitations (gateway, routes, SDK)
│   └── error-patterns.md                 Common errors with cause → fix mapping
└── memory-template.md                    Template for user preference storage
```

---

## Phase State Machine

```
IDLE → SPECIFY → PLAN → IMPLEMENT → VERIFY → DELIVER
              ↑                              │
              └────── Error Recovery ◄────────┘
```

Each phase produces a mandatory artifact. The next phase consumes it. This artifact chain prevents drift — you can't skip a step because the next step's input won't exist.

### SPECIFY — Problem Specification

Produces a structured specification with 7 required fields: Request (verbatim), Functional Requirement, Technical Constraints, Identified Edge Cases, Affected Files, Risk Level, Dependencies.

### PLAN — Implementation Plan

Maps requirements to ordered steps with Traceability IDs (`IMPL-001`, `IMPL-002`...). These IDs chain through code → verification, creating a verifiable audit trail.

### IMPLEMENT — Code Writing

Each code block references its Traceability ID. Self-review runs before transition to VERIFY.

### VERIFY — Structured Verification

Evidence-based report: automated checks with actual output, traceability verification, edge case testing, review checklist.

### Error Recovery

5-step decision tree: capture → classify → identify recovery actions → apply fix → re-verify. User approval required before any side-effect-bearing action (git changes, file deletions, destructive operations).

---

## QA Attestation

After delivering code:

```
QA Compliance
├─ G1 Specify     : PASS
├─ G2 Plan        : PASS
├─ G3 Implement   : PASS
├─ G4 Verify      : PASS
└─ G5 Error Stop  : N/A
```

---

## v3.x vs v4.x Comparison

| Aspect | v3.x | v4.x |
|--------|------|------|
| Workflow model | "4 mandatory gates" (imperative) | Phase state machine (declarative) |
| Step completion | "Demonstrate understanding" (vague) | Mandatory artifact templates (concrete) |
| Drift prevention | None | Traceability IDs chain spec → code → verification |
| Error handling | "Diagnose and fix" (open-ended) | 5-step decision tree with forced diagnostic output |
| Verification | "Run linter" (binary) | Evidence report with actual command output |
| Code rules | Duplicated across files | Single source of truth in `constraints/` |
| Tone | Mixed shouting and slang | Calm, professional, severity-tagged |

---

## How to Invoke

```
Skill(command="stellar-coding-agent")
```

Look for ☄️ as the first response. If you don't see it, the skill wasn't loaded — try again or re-run `setup.sh`.

---

## Uninstall

```bash
rm -rf ~/my-project/skills/stellar-coding-agent
```

---

## Version History

| Version | Changes |
|---------|---------|
| **v4.1.0** | Removed fullstack-dev wrapper. Direct invocation only. setup.sh restores fullstack-dev to original. |
| v4.0.1 | Fixed 3 broken internal references from v4.0 migration |
| v4.0.0 | Complete redesign: phase state machine, artifact templates, traceability IDs, severity tags |
| v3.4.0 | QA Attestation format |
| v3.3.0 | User approval for destructive recovery actions |
| v3.2.0 | Token optimization, knowledge base, error patterns |

---

## Repository Structure

```
stellar-coding-agent/
├── README.md
├── setup.sh
└── skill/
    └── stellar-coding-agent/
        ├── SKILL.md
        ├── CHANGELOG.md
        ├── procedure/
        │   ├── phases.md
        │   ├── templates/
        │   │   ├── problem-spec.md
        │   │   ├── implementation-plan.md
        │   │   ├── verification-report.md
        │   │   └── incident-report.md
        │   └── decision-trees/
        │       └── error-resolution.md
        ├── constraints/
        │   ├── code-standards.md
        │   └── type-safety.md
        ├── knowledge/
        │   ├── architecture.md
        │   ├── conventions.md
        │   ├── platform-constraints.md
        │   └── error-patterns.md
        └── memory-template.md
```
