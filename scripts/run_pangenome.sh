#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Cactus runs via cactus_activate in config (not --use-conda). Snakemake --cores 1 is fine:
# only one heavy rule (cactus_pangenome); Cactus parallelism is mg/map/cons/index cores in config.
snakemake -s workflow/Snakefile --directory workflow --cores "${1:-1}" -p
