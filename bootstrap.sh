#!/usr/bin/env bash
  # bootstrap.sh — SRF application bootstrap
  # Runs as the openclaw user (called from entrypoint.sh after privilege drop).
  # Executed on every container start, before the OpenClaw server starts.
  #
  # ============================================================
  # PROJECT-SPECIFIC: SRF Python package setup
  # If you reuse this template for a different project:
  #   1. Update the pip install line with your package path and extras
  #   2. Update the skills copy source path
  #   3. Remove or replace the SRF-specific comments
  # ============================================================
  #
  # What this script does:
  #   1. Creates a persistent Python venv at /data/venv (survives restarts)
  #   2. Installs the SRF Python package from /data/srf into the venv
  #   3. Copies OpenClaw skill documents to /data/workspace/skills/
  #      so OpenClaw auto-discovers them on startup
  #
  # What this script does NOT do:
  #   - Git operations (handled by entrypoint.sh as root)
  #   - Write to /data/srf (root-owned, openclaw cannot write there)
  #   - Modify any file outside /data/venv and /data/workspace

  set -euo pipefail

  echo "[bootstrap] Starting SRF bootstrap..."

  # ---------------------------------------------------------------------------
  # Python venv
  # Create if absent. If it already exists, this is a no-op.
  # The venv persists across restarts on the /data volume.
  # ---------------------------------------------------------------------------
  if [ ! -f /data/venv/bin/python ]; then
    echo "[bootstrap] Creating Python venv at /data/venv..."
    python3 -m venv /data/venv
  else
    echo "[bootstrap] Venv already exists, skipping create."
  fi

  # ---------------------------------------------------------------------------
  # Install SRF Python package
  #
  # PROJECT-SPECIFIC: update this line for a different project.
  #
  # Non-editable install (no -e flag) — pip writes only into /data/venv/lib,
  # nothing is written back to /data/srf. This is required because /data/srf
  # is root-owned and the openclaw process cannot write to it.
  #
  # Extras:
  #   anthropic    — Anthropic SDK (tracker=None fallback path)
  #   openai       — OpenAI SDK (tracker=None fallback path)
  #   promptledger — PromptLedger client (observability, optional at runtime)
  # ---------------------------------------------------------------------------
  echo "[bootstrap] Installing SRF package into venv..."
  /data/venv/bin/pip install --quiet /data/srf[anthropic,openai,promptledger]

  # ---------------------------------------------------------------------------
  # Copy skills to workspace
  #
  # PROJECT-SPECIFIC: update the source path for a different project.
  #
  # OpenClaw auto-discovers skills placed in /data/workspace/skills/.
  # -n (no-clobber) preserves any manually placed overrides on the volume.
  # ---------------------------------------------------------------------------
  echo "[bootstrap] Copying skills to workspace..."
  mkdir -p /data/workspace/skills
  cp -rn /data/srf/skills/. /data/workspace/skills/ 2>/dev/null || true

  echo "[bootstrap] Bootstrap complete."
