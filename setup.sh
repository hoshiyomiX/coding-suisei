#!/usr/bin/env bash
# ============================================================
#  stellar-coding-agent install v4.1.0 — phase state machine
#
#  What this does:
#    1. Deploys stellar-coding-agent skill (phase state machine workflow)
#    2. Cleans up deprecated files from previous versions
#    3. Restores fullstack-dev to original (removes old wrapper)
#
#  Usage:
#    git clone https://github.com/hoshiyomiX/stellar-coding-agent.git /tmp/cap
#    cd /tmp/cap && bash setup.sh
#
#  Invoke:
#    Skill(command="stellar-coding-agent")
#
#  Trigger marker: ☄️
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${SCRIPT_DIR}/skill"
SKILLS_DIR="${HOME}/my-project/skills"

STELLAR_DIR="${SKILLS_DIR}/stellar-coding-agent"
FULLSTACK_DIR="${SKILLS_DIR}/fullstack-dev"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
fail()  { echo -e "${RED}[FAIL]${NC}  $*"; }

echo ""
echo "============================================"
echo "  stellar-coding-agent v4.1.0"
echo "  Trigger marker: ☄️"
echo "============================================"
echo ""

if [ ! -f "${SOURCE_DIR}/stellar-coding-agent/SKILL.md" ]; then
    fail "Source files not found in ${SOURCE_DIR}/stellar-coding-agent/"
    echo "  Make sure you cloned the full repo."
    exit 1
fi

ERRORS=0

# ============================================================
# PART 1: Deploy stellar-coding-agent skill
# ============================================================
echo ""
info "=== PART 1: Deploy stellar-coding-agent skill ==="
echo ""

mkdir -p "${STELLAR_DIR}"
mkdir -p "${STELLAR_DIR}/knowledge"
mkdir -p "${STELLAR_DIR}/procedure/templates"
mkdir -p "${STELLAR_DIR}/procedure/decision-trees"
mkdir -p "${STELLAR_DIR}/constraints"
ok "Directories created"

# SKILL.md
cp "${SOURCE_DIR}/stellar-coding-agent/SKILL.md" "${STELLAR_DIR}/SKILL.md"
ok "SKILL.md deployed"

# CHANGELOG.md
if [ -f "${SOURCE_DIR}/stellar-coding-agent/CHANGELOG.md" ]; then
    cp "${SOURCE_DIR}/stellar-coding-agent/CHANGELOG.md" "${STELLAR_DIR}/CHANGELOG.md"
    ok "CHANGELOG.md deployed"
fi

# Knowledge files
for ref in architecture.md conventions.md platform-constraints.md error-patterns.md; do
    if [ -f "${SOURCE_DIR}/stellar-coding-agent/knowledge/${ref}" ]; then
        cp "${SOURCE_DIR}/stellar-coding-agent/knowledge/${ref}" "${STELLAR_DIR}/knowledge/${ref}"
        ok "knowledge/${ref}"
    fi
done

# Procedure files
for ref in phases.md; do
    if [ -f "${SOURCE_DIR}/stellar-coding-agent/procedure/${ref}" ]; then
        cp "${SOURCE_DIR}/stellar-coding-agent/procedure/${ref}" "${STELLAR_DIR}/procedure/${ref}"
        ok "procedure/${ref}"
    fi
done

# Procedure templates
for ref in problem-spec.md implementation-plan.md verification-report.md incident-report.md; do
    if [ -f "${SOURCE_DIR}/stellar-coding-agent/procedure/templates/${ref}" ]; then
        cp "${SOURCE_DIR}/stellar-coding-agent/procedure/templates/${ref}" "${STELLAR_DIR}/procedure/templates/${ref}"
        ok "procedure/templates/${ref}"
    fi
done

# Procedure decision trees
for ref in error-resolution.md; do
    if [ -f "${SOURCE_DIR}/stellar-coding-agent/procedure/decision-trees/${ref}" ]; then
        cp "${SOURCE_DIR}/stellar-coding-agent/procedure/decision-trees/${ref}" "${STELLAR_DIR}/procedure/decision-trees/${ref}"
        ok "procedure/decision-trees/${ref}"
    fi
done

# Constraint files
for ref in code-standards.md type-safety.md; do
    if [ -f "${SOURCE_DIR}/stellar-coding-agent/constraints/${ref}" ]; then
        cp "${SOURCE_DIR}/stellar-coding-agent/constraints/${ref}" "${STELLAR_DIR}/constraints/${ref}"
        ok "constraints/${ref}"
    fi
done

# Reference files
for ref in memory-template.md; do
    if [ -f "${SOURCE_DIR}/stellar-coding-agent/${ref}" ]; then
        cp "${SOURCE_DIR}/stellar-coding-agent/${ref}" "${STELLAR_DIR}/${ref}"
        ok "${ref}"
    fi
done

# Remove _meta.json if exists
if [ -f "${STELLAR_DIR}/_meta.json" ]; then
    rm -f "${STELLAR_DIR}/_meta.json"
    ok "_meta.json removed"
else
    ok "_meta.json not present"
fi

# ============================================================
# PART 2: Cleanup deprecated files from previous versions
# ============================================================
echo ""
info "=== PART 2: Cleanup deprecated files ==="
echo ""

# Remove old workflow/ directory (replaced by procedure/ in v4.0)
if [ -d "${STELLAR_DIR}/workflow" ]; then
    rm -rf "${STELLAR_DIR}/workflow"
    ok "workflow/ removed (replaced by procedure/)"
else
    ok "workflow/ not present"
fi

# Remove old gotchas.md (renamed to platform-constraints.md in v4.0)
if [ -f "${STELLAR_DIR}/knowledge/gotchas.md" ]; then
    rm -f "${STELLAR_DIR}/knowledge/gotchas.md"
    ok "knowledge/gotchas.md removed (renamed to platform-constraints.md)"
else
    ok "knowledge/gotchas.md not present"
fi

# Remove other deprecated files
for deprecated in criteria.md state.md _migrated_from_coding_suisei; do
    if [ -f "${STELLAR_DIR}/${deprecated}" ]; then
        rm -f "${STELLAR_DIR}/${deprecated}"
        ok "${deprecated} removed (deprecated)"
    fi
done

# ============================================================
# PART 3: Restore fullstack-dev to original (remove old wrapper)
# ============================================================
echo ""
info "=== PART 3: Restore fullstack-dev ==="
echo ""

if [ -f "${FULLSTACK_DIR}/SKILL.md.original" ]; then
    cp "${FULLSTACK_DIR}/SKILL.md.original" "${FULLSTACK_DIR}/SKILL.md"
    rm -f "${FULLSTACK_DIR}/SKILL.md.original"
    ok "fullstack-dev restored to original (wrapper removed)"
else
    ok "fullstack-dev not patched (no wrapper to remove)"
fi

# ============================================================
# PART 4: Cleanup legacy skill directories
# ============================================================
echo ""
info "=== PART 4: Cleanup legacy directories ==="
echo ""

if [ -d "${SKILLS_DIR}/code" ]; then
    rm -rf "${SKILLS_DIR}/code"
    ok "Duplicate 'code/' removed"
else
    ok "No duplicate found"
fi

# Migrate from old coding-suisei if exists
if [ -d "${SKILLS_DIR}/coding-suisei" ]; then
    cp "${SKILLS_DIR}/coding-suisei/memory.md" "${STELLAR_DIR}/memory.md" 2>/dev/null || true
    rm -rf "${SKILLS_DIR}/coding-suisei"
    ok "Migrated memory from coding-suisei and removed"
else
    ok "No coding-suisei found"
fi

# ============================================================
# PART 5: Verification
# ============================================================
echo ""
info "=== PART 5: Verification ==="
echo ""

if [ -f "${STELLAR_DIR}/SKILL.md" ]; then
    if grep -q "Phase State Machine" "${STELLAR_DIR}/SKILL.md"; then
        ok "stellar-coding-agent: Phase state machine present"
    else
        fail "stellar-coding-agent: Phase state machine MISSING"
        ERRORS=$((ERRORS + 1))
    fi

    if grep -q "☄️" "${STELLAR_DIR}/SKILL.md"; then
        ok "stellar-coding-agent: ☄️ marker present"
    else
        fail "stellar-coding-agent: ☄️ marker MISSING"
        ERRORS=$((ERRORS + 1))
    fi

    for f in \
        procedure/phases.md \
        procedure/templates/problem-spec.md \
        procedure/templates/implementation-plan.md \
        procedure/templates/verification-report.md \
        procedure/templates/incident-report.md \
        procedure/decision-trees/error-resolution.md \
        constraints/code-standards.md \
        constraints/type-safety.md \
        knowledge/architecture.md \
        knowledge/conventions.md \
        knowledge/platform-constraints.md \
        knowledge/error-patterns.md \
        CHANGELOG.md; do
        if [ -f "${STELLAR_DIR}/${f}" ]; then
            ok "${f} present"
        else
            fail "${f} MISSING"
            ERRORS=$((ERRORS + 1))
        fi
    done

    for f in workflow/gates.md workflow/plan-template.md workflow/review-checklist.md knowledge/gotchas.md; do
        if [ -f "${STELLAR_DIR}/${f}" ]; then
            fail "${f} should have been removed"
            ERRORS=$((ERRORS + 1))
        else
            ok "${f} removed"
        fi
    done
else
    fail "stellar-coding-agent: SKILL.md not found"
    ERRORS=$((ERRORS + 1))
fi

# ============================================================
# Summary
# ============================================================
echo ""
echo "============================================"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}  ☄️ stellar-coding-agent v4.1.0 installed!${NC}"
    echo ""
    echo "  • stellar-coding-agent -> skills/stellar-coding-agent/"
    echo "    Phase state machine + artifact templates + knowledge base"
    echo "  • Invoke with: Skill(command=\"stellar-coding-agent\")"
    echo "============================================"
else
    echo -e "${RED}  Install completed with ${ERRORS} error(s)${NC}"
    echo "  Review errors above."
    echo "============================================"
    exit 1
fi
