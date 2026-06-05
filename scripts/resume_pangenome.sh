#!/usr/bin/env bash
# Resume pangenome on Nepenthes in tmux (survives SSH disconnect).
# Usage: bash scripts/resume_pangenome.sh [session_name]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SESSION="${1:-pangenome}"
ACTIVATE="$(grep 'cactus_activate:' "$ROOT/config/config.yaml" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/')"

cd "$ROOT"

echo "=== Preflight ==="
echo "Host: $(hostname)"
echo "CPUs: $(nproc)"
free -h | head -2

if [[ ! -f "$ACTIVATE" ]]; then
  echo "Missing Cactus venv: $ACTIVATE" >&2
  exit 1
fi
# Custom activate appends to PYTHONPATH/LD_LIBRARY_PATH; unset vars break under set -u.
export PYTHONPATH="${PYTHONPATH:-}"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}"
set +u
# shellcheck source=/dev/null
source "$ACTIVATE"
set -u
if ! command -v cactus-pangenome >/dev/null; then
  echo "cactus-pangenome not on PATH after activate" >&2
  exit 1
fi

INDEX_DONE="$(grep '^index_done_flag:' "$ROOT/config/config.yaml" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/')"
if [[ ! -f "$INDEX_DONE" ]]; then
  echo "Indexing not finished (missing $INDEX_DONE)" >&2
  exit 1
fi

JOBSTORE="/scratch/odrew060/Trep_pangenome/work/jobstore"
if [[ -d "$JOBSTORE" ]]; then
  echo "Jobstore present — Cactus will resume from prior progress."
else
  echo "No jobstore yet — starting fresh."
fi

DONE="/scratch/odrew060/Trep_pangenome/pangenome.done"
if [[ -f "$DONE" ]]; then
  echo "Already complete: $DONE"
  ls -lh /scratch/odrew060/Trep_pangenome/results/trifolium_repens/ 2>/dev/null || true
  exit 0
fi

RUN="cd '$ROOT' && ./scripts/run_pangenome.sh 1"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Attaching to existing tmux session: $SESSION"
  exec tmux attach -t "$SESSION"
fi

if [[ -n "${TMUX:-}" ]]; then
  echo "Already in tmux — starting pipeline in this window (detach: Ctrl+b then d)."
  bash -lc "$RUN"
  exit $?
fi

echo "Starting tmux session '$SESSION' (detach: Ctrl+b then d)"
exec tmux new-session -s "$SESSION" "$RUN; echo '=== snakemake exited ==='; exec bash"
