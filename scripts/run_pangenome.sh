#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
snakemake -s workflow/Snakefile --directory workflow --cores "${1:-1}" -p --use-conda
