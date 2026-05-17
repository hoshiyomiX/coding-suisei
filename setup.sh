#!/usr/bin/env bash
# ============================================================
#  stellar-frameworks v5.4.7
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
echo "  ☄️ stellar-frameworks v5.4.7"
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

    if grep -q "v5.4.7" "${INSTALL_DIR}/SKILL.md"; then
        ok "Version 5.4.7 confirmed"
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

# --- Self-heal: configure hook in multiple init files ---
BASHRC_MARKER="# stellar-frameworks auto-heal"
TARGET_DIR="${PROJECT_ROOT}/stellar-frameworks"
# Single-phase: git pull first (updates boot.sh itself), then boot.sh --fast
BASHRC_PHASE1="(cd $TARGET_DIR && git pull --ff-only --quiet 2>/dev/null); bash $TARGET_DIR/boot.sh --fast --install-only >/dev/null 2>&1"

HOOK_TARGETS=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile")
HOOKS_WRITTEN=0

for HOOK_FILE in "${HOOK_TARGETS[@]}"; do
  if [ -f "$HOOK_FILE" ]; then
    if grep -qF "boot.sh" "$HOOK_FILE" 2>/dev/null; then
      sed -i '/# stellar-frameworks auto-heal/d' "$HOOK_FILE"
      sed -i '/boot.sh/d' "$HOOK_FILE"
    fi
    printf '\n%s\n%s\n' "$BASHRC_MARKER" "$BASHRC_PHASE1" >> "$HOOK_FILE"
  else
    printf '%s\n%s\n' "$BASHRC_MARKER" "$BASHRC_PHASE1" > "$HOOK_FILE"
  fi
  HOOKS_WRITTEN=$((HOOKS_WRITTEN + 1))
done

ok "Auto-heal hook written to $HOOKS_WRITTEN/3 init files (git-pull-then-boot)"

# --- Popup preview: create + launch .zscripts/dev.sh ---
ZSCRIPTS="${PROJECT_ROOT}/.zscripts"
DEV_SCRIPT="${ZSCRIPTS}/dev.sh"
DEV_PID_FILE="${ZSCRIPTS}/.dev-server.pid"
DOWNLOAD_DIR="${PROJECT_ROOT}/download"
DEV_SCRIPT_MARKER="# stellar-frameworks dev server"

if [ ! -f "$DEV_SCRIPT" ]; then
    info "Creating dev.sh for popup preview..."
    mkdir -p "$ZSCRIPTS"
    cat > "$DEV_SCRIPT" << 'DEVSH'
#!/bin/bash
# stellar-frameworks dev server — popup preview provider
# Serves Caddy (:81) → reverse proxy → :3000
# Smart mode: Next.js if available, static file server otherwise.
# Created by boot.sh v5.4.6 — do not edit manually.
# Guard: if :3000 is already occupied, exit gracefully.

if command -v ss >/dev/null 2>&1 && ss -tlnp 2>/dev/null | grep -q ':3000 '; then
  echo "[dev.sh] Port :3000 already in use — not starting" >&2
  exit 0
fi

if [ -f /home/z/my-project/package.json ] \
   && grep -q '"next"' /home/z/my-project/package.json 2>/dev/null; then
  # Next.js project detected — delegate to bun
  cd /home/z/my-project
  exec bun run dev
else
  # No Next.js — serve /download/ as static files
  mkdir -p /home/z/my-project/download
  cd /home/z/my-project/download
  exec python3 -m http.server 3000
fi
DEVSH
    chmod +x "$DEV_SCRIPT"
    ok "dev.sh created at ${DEV_SCRIPT}"
else
    ok "dev.sh already exists"
fi

# Launch server if not already running
MAYBE_LAUNCH=false
if [ -f "$DEV_PID_FILE" ]; then
  if kill -0 "$(cat "$DEV_PID_FILE")" 2>/dev/null; then
    : # Already running
  else
    rm -f "$DEV_PID_FILE"
    MAYBE_LAUNCH=true
  fi
else
  MAYBE_LAUNCH=true
fi

if $MAYBE_LAUNCH && [ -f "$DEV_SCRIPT" ]; then
  mkdir -p "$DOWNLOAD_DIR"
  bash "$DEV_SCRIPT" >/dev/null 2>&1 &
  DEV_PID=$!
  echo "$DEV_PID" > "$DEV_PID_FILE"
  ok "Popup preview launched on :3000 (PID $DEV_PID)"
else
  ok "Popup preview already running"
fi

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
    echo -e "${GREEN}  ☄️ v5.4.7 installed and ACTIVE — no restart needed!${NC}"
    echo ""
    echo "  Popup preview: LIVE on :3000 (immediate, no restart)."
    echo "  Invoke: Skill(command=\"stellar-frameworks\")"
    echo ""
    echo "============================================"
else
    echo -e "${RED}  Install completed with ${ERRORS} error(s)${NC}"
    echo "============================================"
    exit 1
fi
