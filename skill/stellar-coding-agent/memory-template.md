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
<!-- Approaches that work well. Format: "pattern: context" -->
<!-- Examples: TDD: for complex logic, screenshots: for UI work -->

---
Last updated: YYYY-MM-DD
```

## Storage Rules

- **Only save** when user explicitly asks ("Remember I prefer X", "Always do Y")
- **Don't save** one-off requests, project-specific requirements, or temporary preferences
- **Ask before saving**: "Should I remember this preference?"
- **Only modify** `memory.md` — never modify other skill files
