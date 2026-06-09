#!/usr/bin/env bash
# Resume pangenome on Nepenthes in tmux. Usage: bash scripts/resume_pangenome.sh
set -euo pipefail

source "$(dirname "$0")/config_paths.sh"
SESSION="${1:-pangenome}"
ACTIVATE="$(grep 'cactus_activate:' "$CFG" | grep -v '^[[:space:]]*#' | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/' | head -1)"

cd "$ROOT"

if [[ -n "$ACTIVATE" ]] && [[ -f "$ACTIVATE" ]]; then
  export PYTHONPATH="${PYTHONPATH:-}"
  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}"
  set +u
  # shellcheck source=/dev/null
  source "$ACTIVATE"
  set -u
fi
command -v cactus-pangenome >/dev/null || {
  echo "cactus-pangenome not on PATH; use conda env or set pangenome.cactus_activate" >&2
  exit 1
}

[[ -f "$INDEX_DONE" ]] || { echo "Indexing not finished: $INDEX_DONE" >&2; exit 1; }
[[ -f "$OUT/pangenome.done" ]] && { echo "Already done: $OUT/pangenome.done"; exit 0; }
[[ -d "$OUT/work/jobstore" ]] && echo "Jobstore present — will resume with --restart."

RUN="cd '$ROOT' && ./scripts/run_pangenome.sh 1"
tmux has-session -t "$SESSION" 2>/dev/null && exec tmux attach -t "$SESSION"
[[ -n "${TMUX:-}" ]] && { bash -lc "$RUN"; exit; }
exec tmux new-session -s "$SESSION" "$RUN; exec bash"