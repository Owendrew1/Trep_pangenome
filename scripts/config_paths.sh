# Shared config paths for bash helpers. Source from scripts/: source "$(dirname "$0")/config_paths.sh"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG="$ROOT/config/config.yaml"
OUT="$(grep '^output_dir:' "$CFG" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/')"
NAME="$(grep 'out_name:' "$CFG" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/')"
INDEX_DONE="$(grep '^index_done_flag:' "$CFG" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/')"
NGEN="$(awk -F, 'NR>1 {n++} END {print n+0}' "$ROOT/resources/pangenome_genomes.csv")"

APPTAINER_BINDS=""
while IFS= read -r path; do
  [[ -n "$path" ]] && APPTAINER_BINDS+=" -B ${path}:${path}"
done < <(awk '/^  container_bind:/{f=1;next} f&&/^    - /{gsub(/^    - |"/,""); print; next} f&&/^  [^ ]/{exit}' "$CFG")
