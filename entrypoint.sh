● #!/bin/bash
  set -e

  # ============================================================
  # PROJECT-SPECIFIC: SRF git clone/pull
  # If you reuse this template for a different project, update
  # REPO_URL and BRANCH to point at your codebase.
  # /data/srf stays root-owned — openclaw gets read-only access.
  # ============================================================
  REPO_URL="https://github.com/mrodek/SyntheticResearchForum"
  BRANCH="main"

  mkdir -p /data/srf

  if [ ! -d /data/srf/.git ]; then
    echo "[entrypoint] Cloning SRF repo..."
    git clone --depth 1 --branch "${BRANCH}" "${REPO_URL}" /data/srf
  else
    echo "[entrypoint] Pulling latest SRF code..."
    git -C /data/srf pull --ff-only || echo "[entrypoint] WARNING: git pull failed, running with existing code"
  fi
  # ============================================================

  # Fix ownership on the live mounted volume — must run as root
  mkdir -p /data/workspace /data/.openclaw
  chown -R openclaw:openclaw /data/workspace /data/.openclaw
  # /data/srf stays root-owned — openclaw gets read-only access

  # Run application bootstrap as openclaw
  # PROJECT-SPECIFIC: bootstrap.sh handles venv + pip install + skills copy
  runuser -u openclaw -- bash /app/bootstrap.sh

  # Drop privileges and start OpenClaw
  exec runuser -u openclaw -- node src/server.js
