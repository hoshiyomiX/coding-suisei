# Changelog

## [5.0.0] — 2026-04-13

### Philosophy Change

v5.0.0 is a philosophical reset based on an honest audit of the framework's effectiveness. The audit found that compliance enforcement language ("Do not skip phases", "mandatory", "must") has no measurable effect on LLM behavior — the same LLM follows or ignores the framework regardless of how strongly it's worded. Meanwhile, the tools that work (traceability IDs, templates, SSV) work because they're useful, not because they're mandatory.

**Design principle**: Stop telling the LLM what it MUST do. Start giving it tools it WANTS to use.

### Removed
- **Coexistence with fullstack-dev** — 18-line section that the user explicitly rejected as "nonsense" because it doesn't solve the persistence problem. The framework is technology-agnostic; whether fullstack-dev is active or not is the LLM's concern, not this file's.
- **Implementation Rules** — Duplicated knowledge/constraints files when standalone and conflicted with fullstack-dev when coexisting. The Phase References table and constraints/ directory already serve this purpose.
- **Complexity Tiers** — A classification table that prescribed workflow abbreviations based on file count. In practice, the agent already adapts naturally. Formal tiers added rules that were sometimes followed and sometimes ignored, with no quality difference.
- **Scope section** — Five rules about what the framework "does not" do. Unnecessary boundary declaration — the framework's scope is self-evident from its content.
- **QA Attestation → Process Compliance Report (PCR)** — Renamed to be honest about what it is. "QA" implies independent quality assurance; the attestation is self-graded. The honesty note (retained) already acknowledged this, but the name contradicted it.
- **Evidence tiers, status value definitions, delivery gate rules** — Detailed specification of attestation mechanics that added 30+ lines. The attestation block format is self-explanatory; surrounding it with rules didn't improve accuracy.

### Changed
- SKILL.md rewritten: 181 lines → ~95 lines (~48% reduction)
- Activation banner updated to v5.0.0, replaced phase/template counts with feature names
- New "Limitations" section at top: explicitly states what the framework cannot do (guarantee compliance, force behavior, persist across sessions)
- Compliance language removed: "Do not skip phases", "mandatory", "Do not omit" replaced with "use them when they help, abbreviate when they don't"
- Phase descriptions condensed from full paragraphs to single-purpose sentences
- Error recovery section simplified from numbered sub-steps to essential rules
- Git rules retained but shortened — removed redundant decision tree reference when the full tree already exists in the referenced file

### Fixed
- **State diagram inconsistency** — phases.md had error arrow from VERIFY→SPECIFY; SKILL.md had DELIVER→SPECIFY. Consolidated to one canonical version: "On error: stop, diagnose, fix, return to VERIFY" with SPECIFY as the alternative for specification gaps.
- **memory-template.md path mismatch** — Template referenced `~/code/memory.md` but phases.md referenced `skills/stellar-coding-agent/memory.md`. Fixed to single canonical path: `/home/z/my-project/skills/stellar-coding-agent/memory.md`.
- **phases.md path reference** — Changed `Check memory.md in this skill directory` to avoid future path drift.

### Honest Assessment
This refactor does not solve the persistence problem (impossible within platform architecture). It does not improve compliance rates (nothing in a text file can). What it does is: stop lying about what the framework can do, remove 86 lines of dead weight that diluted attention from the parts that actually work, and make the framework shorter and clearer so the useful tools (traceability IDs, templates, SSV, decision tree) are more likely to be read and used.

## [4.6.0] — 2026-04-13

### Added
- Source State Verification (SSV) — new section in SKILL.md mandating git fetch + comparison before any analysis/audit task on git repositories
- Source State field in problem-spec template — records branch, HEAD SHA, and verification status
- Source integrity check in verification-report Review Checklist
- Stale Local Data error pattern in error-patterns.md ([CRITICAL] severity)
- Stale-data recovery path (#5) in error-resolution decision tree Git section
- Cross-session git state awareness flag in IDLE phase (action 3.5)
- Evidence tiers in QA Attestation — code-creation vs code-analysis/audit tasks have different evidence requirements; analysis tasks must include source state verification

### Changed
- SPECIFY phase: entry criteria now includes source state verification; action 7.5 added for SSV
- VERIFY phase: action 1b added for source integrity check on analysis tasks
- IDLE phase: action 3.5 added for cross-session git state uncertainty flag

### Why
A stale local git clone caused a false-negative audit — the agent analyzed outdated files, claimed 20 applied fixes were absent, and delivered a confidently incorrect report. SSV closes this gap at every level: SKILL.md (mandate), SPECIFY (gate), VERIFY (defense-in-depth), templates (record), knowledge base (pattern recognition), and decision tree (recovery path).

## [4.5.0] — 2026-04-12

### Added
- Coexistence Mode — new "Coexistence with fullstack-dev" section defining how this framework layers with the platform-provided fullstack-dev skill
- IMPLEMENT phase defers technology-specific decisions to fullstack-dev when it is active; falls back to own `constraints/` and `knowledge/` files when standalone

### Why
fullstack-dev persists across sessions (system prompt level) and provides deep Next.js technical expertise. This framework provides orthogonal process governance. Rather than duplicating fullstack-dev's technical rules and risking conflicting instructions, the framework recognized fullstack-dev's presence and deferred to it for IMPLEMENT-phase decisions. (Removed in v5.0.0 — user identified this as unnecessary and the section was removed.)

## [4.4.2] — 2026-04-11

### Changed
- QA Attestation is now required after every task, not just coding tasks
- Non-coding tasks (conversation, questions, feedback) mark phases as N/A but still output the attestation block

### Why
The Activation section had an escape hatch: "If the user's request is not a coding task, the phase machine does not apply." This allowed skipping the attestation entirely on non-coding tasks — the exact failure mode the user wanted to detect. Making it mandatory for all tasks means: no attestation = framework was not followed.
