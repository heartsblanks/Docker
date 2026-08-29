#!/usr/bin/env bash
# Detects whether to drive this stack with `docker compose` or a podman
# equivalent, and prints the command prefix to use. Sourced by the other
# scripts in this folder — not meant to be run directly.
set -euo pipefail

detect_compose_cmd() {
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    echo "docker compose"
    return
  fi
  if command -v podman >/dev/null 2>&1 && podman compose version >/dev/null 2>&1; then
    echo "podman compose"
    return
  fi
  if command -v podman-compose >/dev/null 2>&1; then
    echo "podman-compose"
    return
  fi
  echo "ERROR: no usable 'docker compose', 'podman compose', or 'podman-compose' found on PATH." >&2
  exit 1
}

COMPOSE_CMD="$(detect_compose_cmd)"
export COMPOSE_CMD
