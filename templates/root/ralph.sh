#!/bin/bash
# Eventmodelers agent loop — processes tasks.json indefinitely
# Usage: ./ralph.sh [project_dir]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-"$SCRIPT_DIR"}"
TASKS_FILE="$PROJECT_DIR/tasks.json"

if [[ ! -f "$PROJECT_DIR/.eventmodelers/config.json" ]]; then
  echo "ERROR: No .eventmodelers/config.json found. Run: eventmodelers install"
  exit 1
fi

echo "Eventmodelers agent — project: $PROJECT_DIR"

while true; do
  cd "$PROJECT_DIR"

  # Skip agent call entirely when no tasks (saves tokens / avoids idle Ollama calls)
  COUNT=$(node -e "
let t = [];
try { t = JSON.parse(require('fs').readFileSync('tasks.json', 'utf8')); } catch {}
console.log(t.length);
" 2>/dev/null || echo 0)

  if [[ "$COUNT" == "0" ]]; then
    sleep 5
    continue
  fi

  while true; do
    bash "$SCRIPT_DIR/agent.sh" "Process the next task from tasks.json." 2>&1
    if [[ $? -eq 0 ]]; then
      break
    else
      echo "[ralph] agent error — retrying in 60s..."
      sleep 60
    fi
  done

  sleep 2
done
