#!/usr/bin/env bash
# Called by workflow/Snakefile — one-line cactus-pangenome (avoids Snakemake line-join bugs).
set -euo pipefail

JOBSTORE="$1"
SEQFILE="$2"
OUTDIR="$3"
OUTNAME="$4"
REFERENCE="$5"
BATCH="$6"
WORKDIR="$7"
LOGFILE="$8"
MG="$9"
MAP="${10}"
CONS="${11}"
INDEX="${12}"
ACTIVATE="${13}"
shift 13
EXTRA_FLAGS=("$@")

mkdir -p "$OUTDIR" "$(dirname "$LOGFILE")" "$WORKDIR"

if [[ ! -f "$ACTIVATE" ]]; then
  echo "Missing cactus venv activate: $ACTIVATE" >&2
  exit 1
fi
export PYTHONPATH="${PYTHONPATH:-}"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}"
set +u
# shellcheck source=/dev/null
source "$ACTIVATE"
set -u

RESTART=()
if [[ -d "$JOBSTORE" ]] && [[ -n "$(ls -A "$JOBSTORE" 2>/dev/null)" ]]; then
  echo "Jobstore exists — resuming with --restart" >&2
  RESTART=(--restart)
fi

exec cactus-pangenome "$JOBSTORE" "$SEQFILE" \
  "${RESTART[@]}" \
  --outDir "$OUTDIR" \
  --outName "$OUTNAME" \
  --reference "$REFERENCE" \
  --batchSystem "$BATCH" \
  --workDir "$WORKDIR" \
  --logFile "$LOGFILE" \
  --mgCores "$MG" \
  --mapCores "$MAP" \
  --consCores "$CONS" \
  --indexCores "$INDEX" \
  "${EXTRA_FLAGS[@]}"
