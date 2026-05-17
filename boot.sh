#!/bin/bash
# stellar-frameworks — Install, self-heal (git-tracked) v5.4.5
# Pure skill installer + popup preview provider. No Next.js bootstrap.
# Self-heal: after first run, adds two-phase hook to shell init files.
# Popup preview: creates .zscripts/dev.sh for static file serving on :3000.
# Usage: bash <(curl -sL https://raw.githubusercontent.com/hoshiyomiX/stellar-frameworks/main/boot.sh)
#    or: bash ~/my-project/stellar-frameworks/boot.sh
#    or: bash stellar-frameworks/boot.sh [--install-only] [--fast]
#
# Flags:
#   --fast         Skip git operations (pure local copy ~50ms). Used by hook Phase 1.
#   --install-only Accepted for compatibility; no-op since v5.4.4.

set -euo pipefail

# Parse flags
FAST_MODE=false
for arg in "$@"; do
  case "$arg" in
    --fast) FAST_MODE=true ;;
    --install-only) : ;; # no-op: kept for backwards compatibility
  esac
done

# ── 0. Auto-clone: if running from a one-liner, SCRIPT_DIR is a temp dir ──
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL="https://github.com/hoshiyomiX/stellar-frameworks.git"
PROJECT_ROOT="${PROJECT_ROOT:-/home/z/my-project}"
TARGET_DIR="$PROJECT_ROOT/stellar-frameworks"

if [ ! -f "$TARGET_DIR/boot.sh" ]; then
  echo "[boot] Repo not found at $TARGET_DIR — cloning..."
  mkdir -p "$PROJECT_ROOT"
  git clone "$REPO_URL" "$TARGET_DIR" 2>/dev/null || {
    echo "[boot] ERROR: git clone failed. Check network or run manually:"
    echo "  cd $PROJECT_ROOT && git clone $REPO_URL"
    exit 1
  }
  echo "[boot] Cloned successfully"
  SCRIPT_DIR="$TARGET_DIR"
elif [ "$(basename "$SCRIPT_DIR")" != "stellar-frameworks" ]; then
  SCRIPT_DIR="$TARGET_DIR"
fi

SOURCE_DIR="$SCRIPT_DIR/skill/stellar-frameworks"

# Detect project root — repo may be a subdirectory of /home/z/my-project/
if [ -f "$PROJECT_ROOT/package.json" ] && [ -d "$PROJECT_ROOT/src/app" ]; then
  : # PROJECT_ROOT explicitly set or detected
else
  PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
fi

INSTALL_DIR="$PROJECT_ROOT/skills/stellar-frameworks"
OBSOLETE_DIR="$PROJECT_ROOT/skills/stellar-coding-agent"
ZSCRIPTS="$PROJECT_ROOT/.zscripts"
DEV_SCRIPT="$ZSCRIPTS/dev.sh"
DOWNLOAD_DIR="$PROJECT_ROOT/download"

# ── 1. Auto-update: pull if remote has newer skill files ──────────
# Non-fatal: any git failure just skips the update and proceeds.
# SKIP entirely in --fast mode (used by hook Phase 1 to avoid race conditions).
if [ -d "$SCRIPT_DIR/.git" ] && ! $FAST_MODE; then
  BRANCH="$(git -C "$SCRIPT_DIR" branch --show-current 2>/dev/null || echo "")"
  REMOTE="$(git -C "$SCRIPT_DIR" remote get-url origin 2>/dev/null || echo "")"

  if [ -n "$BRANCH" ] && [ -n "$REMOTE" ]; then
    if git -C "$SCRIPT_DIR" fetch origin "$BRANCH" --quiet 2>/dev/null; then
      LOCAL="$(git -C "$SCRIPT_DIR" rev-parse HEAD 2>/dev/null)"
      REMOTE_SHA="$(git -C "$SCRIPT_DIR" rev-parse "origin/$BRANCH" 2>/dev/null)"

      if [ "$LOCAL" != "$REMOTE_SHA" ]; then
        BEHIND="$(git -C "$SCRIPT_DIR" rev-list --count HEAD.."origin/$BRANCH" 2>/dev/null || echo "0")"
        AHEAD="$(git -C "$SCRIPT_DIR" rev-list --count "origin/$BRANCH"..HEAD 2>/dev/null || echo "0")"

        if [ "$AHEAD" = "0" ] && [ "$BEHIND" -gt 0 ]; then
          if [ -z "$(git -C "$SCRIPT_DIR" status --porcelain -- skill/ setup.sh boot.sh README.md 2>/dev/null)" ]; then
            OLD_VER="$(grep -oP 'version:\s*\K[0-9]+\.[0-9]+\.[0-9]+' "$SOURCE_DIR/SKILL.md" 2>/dev/null || echo "?")"
            if git -C "$SCRIPT_DIR" pull --ff-only --quiet origin "$BRANCH" 2>/dev/null; then
              NEW_VER="$(grep -oP 'version:\s*\K[0-9]+\.[0-9]+\.[0-9]+' "$SOURCE_DIR/SKILL.md" 2>/dev/null || echo "?")"
              echo "[boot] Updated ${OLD_VER} → ${NEW_VER} ($BEHIND commits)"
            else
              echo "[boot] WARNING: git pull failed — skipping update"
            fi
          else
            echo "[boot] Skipping update — local changes detected in tracked files"
          fi
        elif [ "$AHEAD" -gt 0 ]; then
          echo "[boot] Skipping update — local commits ahead of remote (diverged)"
        fi
      fi
    fi
  fi
fi

# ── 2. Install / self-heal: copy git-tracked skill/ → platform skills/ ──
NEED_INSTALL=false
if [ ! -f "$INSTALL_DIR/SKILL.md" ]; then
  NEED_INSTALL=true
else
  INSTALLED_VER="$(grep -oP 'version:\s*\K[0-9]+\.[0-9]+\.[0-9]+' "$INSTALL_DIR/SKILL.md" 2>/dev/null || echo "0.0.0")"
  SOURCE_VER="$(grep -oP 'version:\s*\K[0-9]+\.[0-9]+\.[0-9]+' "$SOURCE_DIR/SKILL.md" 2>/dev/null || echo "0.0.0")"
  if [ "$INSTALLED_VER" != "$SOURCE_VER" ]; then
    NEED_INSTALL=true
    echo "[boot] Version mismatch: installed $INSTALLED_VER → source $SOURCE_VER"
  fi
fi

# Clean up predecessor skill (stellar-coding-agent v5.0.0)
if [ -d "$OBSOLETE_DIR" ]; then
  rm -rf "${OBSOLETE_DIR:?}"
  echo "[boot] Removed predecessor skill: stellar-coding-agent"
fi

if $NEED_INSTALL; then
  if [ ! -d "$SOURCE_DIR" ]; then
    echo "[boot] ERROR: skill/ not found. Is this the repo root?"
    exit 1
  fi
  echo "[boot] Installing skill files → skills/"
  mkdir -p "$INSTALL_DIR"
  rm -rf "${INSTALL_DIR:?}"
  cp -R "$SOURCE_DIR" "$INSTALL_DIR"

  # Verify critical files
  ERRORS=0
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
    if [ -f "$INSTALL_DIR/$f" ]; then
      : # OK
    else
      echo "[boot] WARNING: $f MISSING"
      ERRORS=$((ERRORS + 1))
    fi
  done

  if [ $ERRORS -eq 0 ]; then
    echo "[boot] Installed successfully"
  else
    echo "[boot] WARNING: installed with $ERRORS missing file(s)"
  fi
else
  echo "[boot] Skill files OK"
fi

# ── 3. Popup preview: ensure .zscripts/dev.sh exists ──────────────
# The platform's start.sh auto-executes .zscripts/dev.sh if it exists.
# This provides popup preview (Caddy :81 → proxy → :3000) without fullstack-dev.
#
# Smart dev.sh behavior:
#   - If Next.js project exists (package.json with "next" dep) → bun run dev
#   - Otherwise → python3 static server serving /download/ on :3000
#
# NOTE: fullstack-dev's init-fullstack.sh also checks for dev.sh existence.
# If dev.sh is present, init-fullstack.sh skips tarball download and runs it.
# This is intentional — our dev.sh handles both cases intelligently.
# To force fullstack-dev setup: rm .zscripts/dev.sh && invoke fullstack-dev.

DEV_SCRIPT_MARKER="# stellar-frameworks dev server"
if [ ! -f "$DEV_SCRIPT" ]; then
  echo "[boot] Creating dev.sh for popup preview..."
  mkdir -p "$ZSCRIPTS"
  cat > "$DEV_SCRIPT" << 'DEVSH'
#!/bin/bash
# stellar-frameworks dev server — popup preview provider
# Serves Caddy (:81) → reverse proxy → :3000
# Smart mode: Next.js if available, static file server otherwise.
# Created by boot.sh v5.4.5 — do not edit manually.

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
  echo "[boot] dev.sh created → popup preview will be active on next session"
elif ! grep -qF "$DEV_SCRIPT_MARKER" "$DEV_SCRIPT" 2>/dev/null; then
  echo "[boot] dev.sh already exists (external) — keeping it"
else
  echo "[boot] dev.sh OK (managed by stellar-frameworks)"
fi

# ── 4. Self-heal persistence (two-phase hook) ─────────────────────
# Ensures stellar-frameworks auto-recovers after sandbox resets.
# Writes two-phase hook to MULTIPLE shell init files for redundancy:
#   $HOME/.bashrc       — interactive non-login shells
#   $HOME/.bash_profile  — login shells (bash)
#   $HOME/.profile       — login shells (POSIX fallback)
#
# Phase 1 (sync, ~50ms): --fast skips git ops → pure local copy.
#   Ensures skill name is in platform cache immediately on session start.
# Phase 2 (async, ~5-15s): no --fast → git fetch + pull → re-copy.
#   Updates to latest version in background. Next Skill() call gets new version.

BASHRC_MARKER="# stellar-frameworks auto-heal"
BASHRC_PHASE1="bash $TARGET_DIR/boot.sh --fast --install-only >/dev/null 2>&1"
BASHRC_PHASE2="(bash $TARGET_DIR/boot.sh --install-only >/dev/null 2>&1 &)"

# Clean up stale hook from wrong path (v5.4.1 bug)
STALE_BASHRC="$PROJECT_ROOT/.bashrc"
if [ -f "$STALE_BASHRC" ] && grep -qF "$BASHRC_MARKER" "$STALE_BASHRC" 2>/dev/null; then
  sed -i '/# stellar-frameworks auto-heal/d' "$STALE_BASHRC"
  sed -i '/boot.sh/d' "$STALE_BASHRC"
  [ ! -s "$STALE_BASHRC" ] && rm -f "$STALE_BASHRC"
  echo "[boot] Cleaned stale hook from $STALE_BASHRC"
fi

# Write hook to all three init files
HOOK_TARGETS=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile")
HOOKS_WRITTEN=0

for HOOK_FILE in "${HOOK_TARGETS[@]}"; do
  # Remove any existing hooks (including old single-phase and async variants)
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

echo "[boot] Two-phase auto-heal hook written to $HOOKS_WRITTEN/3 init files"

# ── 5. Post-install notice ─────────────────────────────────────
# Platform reads SKILL.md from disk on each Skill() call (NOT cached).
# So updates are effective immediately — no restart needed.

if $NEED_INSTALL; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  ☄️ v5.4.5 installed and ACTIVE — no restart needed!         ║"
  echo "║  Popup preview: will be active on next session (:3000).     ║"
  echo "║  Invoke: Skill(command=\"stellar-frameworks\")                 ║"
  echo "║  Auto-heal: two-phase hook in 3 init files.                  ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
fi

# ── 6. Done ──
exit 0
