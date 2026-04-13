# Phase State Machine

Each phase produces a concrete artifact that the next phase consumes. Skipping a phase means the next phase has no input to work from, which makes the gap visible and correctable.

## State Diagram

```
IDLE → SPECIFY → PLAN → IMPLEMENT → VERIFY → DELIVER
  ↑                                        │
  └──── Error Recovery ◄───────────────────┘
```

On error: stop work, document the error, fix the root cause, return to VERIFY. If the error reveals a specification gap, return to SPECIFY instead.

---

## Phase 1: IDLE

**Purpose**: Receive the user's request and classify task complexity.

**Actions**:
1. Receive and acknowledge the request.
2. Classify complexity:
   - **Simple**: Single file, no schema change, no new dependencies.
   - **Standard**: Multiple files or a schema change.
   - **Complex**: Architectural changes, multi-service, or high risk.
3. Check `memory.md` in this skill directory for user preferences, if it exists.
4. If the task involves a git repository and the session was continued from a previous conversation (context compression boundary), flag the repository as "state-uncertain" and require Source State Verification in SPECIFY.
5. Transition to SPECIFY.

**Artifacts**: None. IDLE is a routing phase.

**Complexity tier note**: Simple tasks may abbreviate SPECIFY and PLAN into a single combined output, but must still produce all artifact fields from both templates.

---

## Phase 2: SPECIFY

**Purpose**: Produce a precise problem specification that removes ambiguity.

**Entry criteria**: Task complexity classified, user preferences loaded, source state verified (if git repository — see SSV in SKILL.md).

**Actions**:
1. Restate the request in precise technical terms.
2. Identify functional requirements.
3. Identify technical constraints. Reference `knowledge/architecture.md` for sandbox constraints.
4. Enumerate edge cases with handling strategies.
5. List all files to be created or modified with action type (create/modify).
6. Assess risk level (LOW / MEDIUM / HIGH) with justification.
7. Identify dependencies.
8. If git repository, perform Source State Verification (see SKILL.md) and record the verified state.
9. Fill out the problem specification template and present to user.

**Artifact**: `procedure/templates/problem-spec.md`

**Exit criteria**: All fields filled. User reviewed and confirmed (or task is simple enough that confirmation is implied).

**Transition**: On acceptance → PLAN. On revision → update and re-present.

---

## Phase 3: PLAN

**Purpose**: Design implementation strategy with traceable steps.

**Entry criteria**: Problem specification approved.

**Actions**:
1. Review the problem specification — confirm all requirements are accounted for.
2. Choose a solution approach (2-3 sentences).
3. Break implementation into ordered steps. Each step gets a Traceability ID (IMPL-001, IMPL-002, etc.).
4. Define verification strategy — what to check, how, and expected outcome.
5. Read relevant knowledge files based on task type (see Phase References in SKILL.md).
6. Fill out the implementation plan template and present.

**Artifact**: `procedure/templates/implementation-plan.md`

**Exit criteria**: Every requirement maps to at least one step. Every step has a Traceability ID. Verification strategy covers all edge cases.

**Transition**: On acceptance → IMPLEMENT. On revision → update and re-present.

---

## Phase 4: IMPLEMENT

**Purpose**: Write code, following the plan step by step.

**Entry criteria**: Implementation plan approved. Relevant knowledge files read.

**Actions**:
1. For each implementation step:
   a. Reference the Traceability ID in a comment or context note.
   b. Write the code.
   c. Follow constraints from `constraints/code-standards.md` and `constraints/type-safety.md`.
   d. If new dependency needed, install it before writing code that uses it.
2. Self-review using the Review Checklist in the verification report template.
3. Fix issues found during self-review before transitioning.

**Artifacts**: The code itself. Inline traceability references (each code block annotated with its Traceability ID).

**Exit criteria**: All steps completed. Self-review passes with no unresolved issues.

**Transition**: On completion → VERIFY. On error → document with incident report template, follow error-resolution decision tree.

---

## Phase 5: VERIFY

**Purpose**: Confirm implementation satisfies all requirements.

**Entry criteria**: All steps complete. Self-review performed.

**Actions**:
1. Run automated checks: lint, type check, existing tests.
2. If analyzing existing code from a git repository, verify analyzed files matched the remote state at time of analysis. If discrepancy found, return to SPECIFY.
3. Traceability verification — confirm every Traceability ID has a corresponding implementation.
4. Edge case verification — test input, expected behavior, actual behavior for each edge case from the spec.
5. Fill out the verification report template.

**Artifact**: `procedure/templates/verification-report.md`

**Exit criteria**: All checks pass (or failures documented). Every Traceability ID verified. Every edge case confirmed.

**Transition**: All pass → DELIVER. Any fail → incident report, return to IMPLEMENT (or SPECIFY if specification gap).

---

## Phase 6: DELIVER

**Purpose**: Present completed work with summary.

**Entry criteria**: Verification report shows all checks passing.

**Actions**:
1. Summarize what was implemented, referencing Traceability IDs.
2. List files created or modified.
3. Note any dependencies added.
4. Present verification report summary.
5. State caveats or follow-up items.
6. Output Process Compliance Report.

**Artifacts**: None new. Consumes verification report.

**Transition**: On acceptance → IDLE. On revision → return to appropriate phase.

---

## Error Handling

1. Stop work on the current phase.
2. Complete incident report template (`procedure/templates/incident-report.md`).
3. Follow error resolution decision tree (`procedure/decision-trees/error-resolution.md`).
4. Decision tree determines return phase — default is VERIFY, but specification gaps require SPECIFY.
