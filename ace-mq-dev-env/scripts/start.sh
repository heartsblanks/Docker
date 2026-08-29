#!/usr/bin/env bash
# Brings up the full dev environment (ACE + MQ + 2x Db2 + Db2-mainframe stand-in + Oracle).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [[ ! -f .env ]]; then
  echo "No .env found. Copy .env.example to .env and fill in real passwords first." >&2
  exit 1
fi

source scripts/compose-runtime.sh
echo "Using: ${COMPOSE_CMD}"

${COMPOSE_CMD} up -d

echo
echo "Containers starting. Db2/Oracle/MQ/ACE can take a few minutes on first run"
echo "(Db2 in particular does a one-time database creation on first boot)."
echo "Run scripts/status.sh to watch health, and 'docker/podman logs -f dev-ace' etc for details."
