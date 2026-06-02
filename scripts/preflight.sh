#!/usr/bin/env bash
# Pre-run checks: paths, scratch writable, FASTAs present.
# Usage: bash scripts/preflight.sh
set -euo pipefail
cd "$(dirname "$0")/.."

python3 << 'PY'
import csv
import sys
from pathlib import Path

def load_config():
    cfg, pg, section = {}, {}, None
    for line in Path("config/config.yaml").read_text().splitlines():
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        if s == "pangenome:":
            section = pg
            continue
        if ":" not in s:
            continue
        k, v = s.split(":", 1)
        k, v = k.strip(), v.strip().strip('"')
        (pg if line.startswith("  ") else cfg)[k] = v
    cfg["pangenome"] = pg
    return cfg

cfg = load_config()
scratch = Path(cfg["scratch_dir"]).expanduser()
ref = Path(cfg["index_trep_refs_results_dir"]).expanduser()
name = cfg["pangenome"]["out_name"]

paths = {
    "scratch": scratch,
    "results": scratch / "results",
    "pangenome": scratch / "results" / name,
    "seqfile": scratch / "results" / "seqfile.txt",
    "jobstore": scratch / "work" / "jobstore",
    "work": scratch / "work" / "scratch",
    "log": scratch / "logs" / f"{name}.cactus-pangenome.log",
}

print("=== paths (all writes go under scratch_dir) ===")
for label, p in paths.items():
    print(f"  {label:10} {p}")

print("\n=== scratch ===")
try:
    scratch.mkdir(parents=True, exist_ok=True)
    probe = scratch / ".write_test"
    probe.write_text("ok")
    probe.unlink()
    print(f"  writable: yes ({scratch})")
    import shutil
    du = shutil.disk_usage(scratch)
    print(f"  free: {du.free // (1024**3)} GB")
except (OSError, PermissionError) as e:
    print(f"  ERROR: cannot write to scratch_dir: {scratch}", file=sys.stderr)
    print("  Find a writable path:  ls -la /scratch", file=sys.stderr)
    print("  Then set scratch_dir in config/config.yaml", file=sys.stderr)
    sys.exit(1)

print("\n=== inputs (index_Trep_refs) ===")
if not ref.is_dir():
    print(f"  ERROR: not found: {ref}", file=sys.stderr)
    sys.exit(1)

def enabled(row):
    return row.get("enabled", "yes").strip().lower() in ("yes", "y", "1", "true")

missing = []
for row in csv.DictReader(Path("samples.csv").open()):
    row = {k: (v or "").strip() for k, v in row.items()}
    if not enabled(row):
        continue
    sub = row.get("results_subdir") or row["haplotype"]
    stem = Path(row["file"].replace(".gz", "")).stem
    p = ref / row["source"] / sub / f"{stem}.fna"
    if p.is_file():
        print(f"  OK  {row['cactus_name']}")
    else:
        missing.append(str(p))

if missing:
    print("\n  MISSING:", *missing, sep="\n    ", file=sys.stderr)
    sys.exit(1)

print("\n=== ready ===")
print("  conda activate trep_pangenome")
print("  snakemake -n --cores 1 --use-conda")
print("  snakemake --cores 1 --use-conda   # when ready, via your job workflow")
PY
