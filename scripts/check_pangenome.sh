#!/usr/bin/env bash
# Status check. Usage: bash scripts/check_pangenome.sh
set -euo pipefail

source "$(dirname "$0")/config_paths.sh"

LOG="$OUT/pangenome_logs/cactus_pangenome/${NAME}.log"
RES="$OUT/results/$NAME"

bar() { printf '%s\n' "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; }

bar
if [[ -f "$OUT/pangenome.done" ]]; then
  echo "  STATUS      ✅ DONE"
else
  echo "  STATUS      🔄 not finished (no pangenome.done)"
fi
bar

if [[ -f "$LOG" ]]; then
  echo "  Mapped      $(grep -c 'Successfully ran:.*gaf2paf' "$LOG" 2>/dev/null || echo 0)/${NGEN} genomes"
fi

echo ""
echo "  KEY OUTPUTS:"
for f in "${NAME}.full.gbz" "${NAME}.full.hal" "${NAME}.vcf.gz"; do
  [[ -f "$RES/$f" ]] && echo "  ✅ $f" || echo "  ❌ $f"
done

bar