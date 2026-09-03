#!/usr/bin/env bash
# run.sh — local dev server
set -euo pipefail
cd "$(dirname "$0")/backend"
exec uvicorn survey:app --host "${HOST:-127.0.0.1}" --port 8000 --reload