# Memory Setup

## Initial Setup

```bash
mkdir -p /home/z/my-project/skills/stellar-coding-agent
touch /home/z/my-project/skills/stellar-coding-agent/memory.md
```

## memory.md Template

Copy to `/home/z/my-project/skills/stellar-coding-agent/memory.md`:

```markdown
# Code Memory

## Preferences
<!-- User's coding workflow preferences -->
<!-- Examples: always run tests, prefer TypeScript, commit after each feature -->

## Never
<!-- Things that don't work for this user -->
<!-- Examples: inline styles, console.log debugging, large PRs -->

## Patterns
<!-- Approaches that work well + incident log entries. Two entry types: -->

<!-- User patterns (added on explicit request): -->
<!--   TDD: for complex logic -->

<!-- Incident log (added automatically by Error Handling step 5, no judgment): -->
<!--   [2026-04-15] error: Runtime | cause: null access on user.profile | fix: added optional chaining -->

## Session Digest
<!-- Written automatically by DELIVER action 1. One line per completed task. No evaluation. -->
<!-- Format: [YYYY-MM-DD HH:MM] task: <description> | outcome: PASS/FAIL | files: <n> | incidents: <n> -->

---
Last updated: YYYY-MM-DD
```

## Storage Rules

- **Only save** user preferences when user explicitly asks ("Remember I prefer X", "Always do Y")
- **Don't save** one-off requests, project-specific requirements, or temporary preferences
- **Ask before saving** a user preference: "Should I remember this preference?"
- **Session Digest and incident log entries are written automatically** by the phase machine — they do not require user approval
- **Only modify** `memory.md` — never modify other skill files
