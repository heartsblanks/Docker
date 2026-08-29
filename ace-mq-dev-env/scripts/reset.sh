#!/usr/bin/env bash
# Tears the environment down AND deletes all data volumes (Db2/Oracle/MQ data,
# ACE workdir). Use this to get back to a totally clean slate.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

source scripts/compose-runtime.sh
echo "Using: ${COMPOSE_CMD}"

read -r -p "This will DELETE all persisted data (Db2, Oracle, MQ, ACE workdir). Continue? [y/N] " confirm
if [[ "${confirm}" != "y" && "${confirm}" != "Y" ]]; then
  echo "Aborted."
  exit 0
fi

${COMPOSE_CMD} down -v
