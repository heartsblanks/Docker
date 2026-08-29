#!/usr/bin/env bash
# Shows container state and health for every service in the stack.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

source scripts/compose-runtime.sh
echo "Using: ${COMPOSE_CMD}"

${COMPOSE_CMD} ps
