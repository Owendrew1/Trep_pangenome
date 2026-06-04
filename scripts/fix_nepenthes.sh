#!/usr/bin/env bash
# Run on Nepenthes from repo root: bash scripts/fix_nepenthes.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

sed -i.bak 's/batch_system: "slurm"/batch_system: "single_machine"/' config/config.yaml

if ! grep -q 'subprocess.run(cmd' workflow/Snakefile; then
  echo "Snakefile is still the OLD version (broken shell: block)."
  echo "Run:  cd $ROOT && git pull origin main"
  echo "If pull says up to date, push from your Mac first, then pull again."
  exit 1
fi

chmod +x scripts/run_cactus_pangenome.sh
echo "Ready. grep check:"
grep -n subprocess.run workflow/Snakefile | head -1
grep batch_system config/config.yaml
