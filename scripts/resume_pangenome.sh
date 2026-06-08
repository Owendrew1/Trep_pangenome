#!/usr/bin/env bash
# Resume pangenome on Nepenthes in tmux. Usage: bash scripts/resume_pangenome.sh
set -euo pipefail

source "$(dirname "$0")/config_paths.sh"
SESSION="${1:-pangenome}"
ACTIVATE="$(grep 'cactus_activate:' "$CFG" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/')"

cd "$ROOT"

echo "=== Preflight ==="
echo "Host: $(hostname)"
free -h | head -2

export PYTHONPATH="${PYTHONPATH:-}"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}"
set +u
# shellcheck source=/dev/null
source "$ACTIVATE"
set -u
command -v cactus-pangenome >/dev/null

[[ -f "$INDEX_DONE" ]] || { echo "Indexing not finished: $INDEX_DONE" >&2; exit 1; }
[[ -f "$OUT/pangenome.done" ]] && { echo "Already done: $OUT/pangenome.done"; exit 0; }
[[ -d "$OUT/work/jobstore" ]] && echo "Jobstore present — will resume with --restart."

RUN="cd '$ROOT' && ./scripts/run_pangenome.sh 1"
tmux has-session -t "$SESSION" 2>/dev/null && exec tmux attach -t "$SESSION"
[[ -n "${TMUX:-}" ]] && { bash -lc "$RUN"; exit; }
exec tmux new-session -s "$SESSION" "$RUN; exec bash"
