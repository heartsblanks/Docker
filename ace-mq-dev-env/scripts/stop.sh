#!/usr/bin/env bash
# Stops the dev environment. Data volumes are preserved (use reset.sh to wipe them).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

source scripts/compose-runtime.sh
echo "Using: ${COMPOSE_CMD}"

${COMPOSE_CMD} down
