# Changelog

## [4.1.0] — 2026-04-08

### Changed
- Removed fullstack-dev routing wrapper (no longer needed — stellar-coding-agent can be invoked directly via `Skill(command="stellar-coding-agent")`)
- setup.sh no longer patches fullstack-dev; instead restores it to original if a wrapper from a previous version exists
- setup.sh version bumped to v4.1.0
- Removed `fullstack-dev-SKILL.md` from repository

### Why
The platform recognizes `stellar-coding-agent` as a valid skill in `<available_skills>`, making direct invocation reliable. The wrapper caused problems because the platform overwrites `fullstack-dev/SKILL.md` on invoke, silently destroying the routing bridge.

## [4.0.1] — 2026-04-08

### Fixed
- 3 broken references in `procedure/phases.md` pointing to deleted `workflow/` files — now point to correct v4.0 locations
- Old "GATE 2 section" terminology in phases.md replaced with "Phase References table"
- Banned `tail` command reference in error-resolution.md replaced with direct file read instruction
- Inconsistent relative path in problem-spec.md corrected to full path

## [4.0.0] — 2026-04-07

### Breaking Changes
- Complete framework redesign from "4 gates" to phase state machine
- Templates moved from `workflow/` to `procedure/templates/`
- Code constraints moved from `workflow/gates.md` to `constraints/`
- Knowledge files rewritten with professional tone and severity tags

### Added
- Phase state machine (IDLE → SPECIFY → PLAN → IMPLEMENT → VERIFY → DELIVER)
- Artifact chain with Traceability IDs for drift prevention
- Structured decision tree for error resolution
- Complexity tiers (Simple / Standard / Complex)
- Severity classification system ([CRITICAL], [REQUIRED], [RECOMMENDED])
- Incident report template for error documentation
- Verification report template with evidence capture
- CHANGELOG.md for version tracking
- Purpose sections in all documents

### Removed
- "Honesty Clause" (self-defeating — replaced by QA attestation integrity statement)
- All-caps emphasis repetition throughout documents
- Informal language ("gotchas", "ban list", "just do it")
- Duplicate content between SKILL.md and gates.md
- `workflow/gates.md`, `workflow/plan-template.md`, `workflow/review-checklist.md`

### Changed
- "Delivery Confirmation" → "QA Attestation" with structured format
- GATE 4 enhanced: user approval required before destructive recovery actions
- `knowledge/gotchas.md` → `knowledge/platform-constraints.md`
- All documents use calm, professional tone with severity tags

## [3.4.0] — 2026-04-07
- QA Attestation format (structured compliance report replacing informal delivery confirmation)

## [3.3.0] — 2026-04-07
- GATE 4: Added user approval requirement for destructive recovery actions

## [3.2.0] — 2026-04-07
- Initial deployment from setup.sh
