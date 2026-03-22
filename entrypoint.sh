#!/bin/bash
set -e

# Fix ownership on the live mounted volume — must run as root
mkdir -p /data/workspace /data/.openclaw /data/srf
chown -R openclaw:openclaw /data/workspace /data/.openclaw
# /data/srf stays root-owned — openclaw gets read-only access

# Drop privileges and start OpenClaw
exec runuser -u openclaw -- node src/server.js
