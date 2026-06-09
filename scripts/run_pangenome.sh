#!/usr/bin/env bash
# Run pangenome workflow. Usage: ./scripts/run_pangenome.sh [cores]
set -euo pipefail
cd "$(dirname "$0")/.."
source "$(dirname "$0")/config_paths.sh"

exec snakemake -s workflow/Snakefile --directory workflow --cores "${1:-1}" -p \
  --use-apptainer --apptainer-args "$APPTAINER_BINDS"
