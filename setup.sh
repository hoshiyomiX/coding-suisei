#!/usr/bin/env bash
# ============================================================
#  stellar-frameworks v5.4.5
#
#  Install:  cd /home/z/my-project/stellar-frameworks && bash setup.sh
#  Invoke:   Skill(command="stellar-frameworks")
#  Marker:   ☄️
#  Note:     boot.sh is the preferred installer — this file is
#            retained for standalone use.
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${SCRIPT_DIR}/skill/stellar-frameworks"
PROJECT_ROOT="${PROJECT_ROOT:-/home/z/my-project}"
INSTALL_DIR="${PROJECT_ROOT}/skills/stellar-frameworks"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
fail()  { echo -e "${RED}[FAIL]${NC}  $*"; }

echo ""
echo "============================================"
echo "  ☄️ stellar-frameworks v5.4.5"
echo "============================================"
echo ""

if [ ! -f "${SOURCE_DIR}/SKILL.md" ]; then
    fail "Source files not found in ${SOURCE_DIR}/"
    echo "  Make sure setup.sh is run from the repo root."
    exit 1
fi

ERRORS=0

# --- Uninstall previous version (if any) ---
if [ -d "${INSTALL_DIR}" ]; then
    rm -rf "${INSTALL_DIR}"
    ok "Previous installation removed"
fi

# --- Remove predecessor skill (stellar-coding-agent v5.0.0) ---
OBSOLETE_DIR="${PROJECT_ROOT}/skills/stellar-coding-agent"
if [ -d "${OBSOLETE_DIR}" ]; then
    rm -rf "${OBSOLETE_DIR}"
    ok "Removed predecessor skill: stellar-coding-agent"
fi

# --- Fresh install ---
mkdir -p "${INSTALL_DIR}"
cp -R "${SOURCE_DIR}" "${INSTALL_DIR}"
ok "Files deployed to ${INSTALL_DIR}"

# --- Verify ---
echo ""
info "Verifying installation..."

if [ -f "${INSTALL_DIR}/SKILL.md" ]; then
    if grep -q "Phase State Machine" "${INSTALL_DIR}/SKILL.md"; then
        ok "Phase state machine present"
    else
        fail "Phase state machine MISSING"
        ERRORS=$((ERRORS + 1))
    fi

    if grep -q "v5.4.5" "${INSTALL_DIR}/SKILL.md"; then
        ok "Version 5.4.5 confirmed"
    else
        fail "Version mismatch"
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
        knowledge/universal/architecture.md \
        knowledge/universal/conventions.md \
        knowledge/universal/error-patterns.md \
        knowledge/platform/zai-sandbox.md \
        memory-template.md \
        CHANGELOG.md; do
        if [ -f "${INSTALL_DIR}/${f}" ]; then
            ok "${f}"
        else
            fail "${f} MISSING"
            ERRORS=$((ERRORS + 1))
        fi
    done
else
    fail "SKILL.md not found"
    ERRORS=$((ERRORS + 1))
fi

# --- Self-heal: configure two-phase hook in multiple init files ---
BASHRC_MARKER="# stellar-frameworks auto-heal"
TARGET_DIR="${PROJECT_ROOT}/stellar-frameworks"
# Phase 1 (sync, ~50ms): skip git ops → ensures skill name in platform cache
BASHRC_PHASE1="bash $TARGET_DIR/boot.sh --fast --install-only >/dev/null 2>&1"
# Phase 2 (async, ~5-15s): git pull + re-copy → updates to latest version
BASHRC_PHASE2="(bash $TARGET_DIR/boot.sh --install-only >/dev/null 2>&1 &)"

HOOK_TARGETS=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile")
HOOKS_WRITTEN=0

for HOOK_FILE in "${HOOK_TARGETS[@]}"; do
  if [ -f "$HOOK_FILE" ]; then
    if grep -qF "boot.sh" "$HOOK_FILE" 2>/dev/null; then
      sed -i '/# stellar-frameworks auto-heal/d' "$HOOK_FILE"
      sed -i '/boot.sh/d' "$HOOK_FILE"
    fi
    printf '\n%s\n%s\n%s\n' "$BASHRC_MARKER" "$BASHRC_PHASE1" "$BASHRC_PHASE2" >> "$HOOK_FILE"
  else
    printf '%s\n%s\n%s\n' "$BASHRC_MARKER" "$BASHRC_PHASE1" "$BASHRC_PHASE2" > "$HOOK_FILE"
  fi
  HOOKS_WRITTEN=$((HOOKS_WRITTEN + 1))
done

ok "Two-phase auto-heal hook written to $HOOKS_WRITTEN/3 init files (.bashrc, .bash_profile, .profile)"

# Clean up stale hook from wrong path (v5.4.1 bug)
STALE_BASHRC="$PROJECT_ROOT/.bashrc"
if [ -f "$STALE_BASHRC" ] && grep -qF "$BASHRC_MARKER" "$STALE_BASHRC" 2>/dev/null; then
  sed -i '/# stellar-frameworks auto-heal/d' "$STALE_BASHRC"
  sed -i '/boot.sh/d' "$STALE_BASHRC"
  [ ! -s "$STALE_BASHRC" ] && rm -f "$STALE_BASHRC"
  ok "Cleaned stale hook from $STALE_BASHRC"
fi

# --- Done ---
echo ""
echo "============================================"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}  ☄️ v5.4.5 installed and ACTIVE — no restart needed!${NC}"
    echo ""
    echo "  Skill() reads SKILL.md from disk — updates are instant."
    echo "  Invoke: Skill(command=\"stellar-frameworks\")"
    echo ""
    echo "============================================"
else
    echo -e "${RED}  Install completed with ${ERRORS} error(s)${NC}"
    echo "============================================"
    exit 1
fi
