● #!/bin/bash   
  set -e
                                                                                                                                                                             # ============================================================
  # PROJECT-SPECIFIC: SRF git clone/pull                                                                                                                                   
  # This block is specific to the Synthetic Research Forum project.
  # If you reuse this template for a different project, update
  # REPO_URL and BRANCH to point at your codebase.
  # /data/srf stays root-owned after this block — the openclaw
  # process gets read-only access and cannot edit source files.
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

  # Drop privileges and start OpenClaw
  exec runuser -u openclaw -- node src/server.js

  Key changes from the original:
  - Added the SRF git block before the chown lines
  - Removed /data/srf from the mkdir -p line (the git block handles it)
  - Everything else unchanged
