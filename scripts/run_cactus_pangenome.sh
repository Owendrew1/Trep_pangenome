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
EXTRA="${14:-}"

mkdir -p "$OUTDIR" "$(dirname "$LOGFILE")" "$WORKDIR"

if [[ ! -f "$ACTIVATE" ]]; then
  echo "Missing cactus venv activate: $ACTIVATE" >&2
  exit 1
fi
# shellcheck source=/dev/null
source "$ACTIVATE"

exec cactus-pangenome "$JOBSTORE" "$SEQFILE" \
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
  $EXTRA
