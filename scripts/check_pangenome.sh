#!/usr/bin/env bash
# Quick status without tmux. Usage: bash scripts/check_pangenome.sh
set -euo pipefail

BASE="/scratch/odrew060/Trep_pangenome"
LOG="$BASE/pangenome_logs/cactus_pangenome/trifolium_repens.log"

echo "=== Host ==="
hostname
echo "=== Done flag ==="
ls -la "$BASE/pangenome.done" 2>&1 || true
echo "=== Graph outputs ==="
ls -lh "$BASE/results/trifolium_repens/" 2>&1 || true
echo "=== Seqfile / sanitized FASTAs ==="
ls -lh "$BASE/results/seqfile.txt" 2>&1 || true
ls "$BASE/results/sanitized_fna/" 2>&1 | head -10 || true
echo "=== Running processes ==="
ps aux | grep -E 'snakemake|cactus|toil' | grep -v grep || echo "(none)"
echo "=== Latest log ==="
tail -15 "$LOG" 2>&1 || echo "(no log yet)"
