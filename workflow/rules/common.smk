# Shared helpers for workflow/Snakefile (aligned with index_Trep_refs/rules/common.smk).

import csv
from pathlib import Path


def load_samples(path):
    with open(path, newline="") as f:
        rows = list(csv.DictReader(f))
    for i, r in enumerate(rows, 1):
        for k in list(r.keys()):
            r[k] = (r[k] or "").strip()
        r["row_id"] = f"{i:04d}"
    return rows


def asm(r):
    return Path(r["file"].replace(".gz", "")).stem


def ref_path(r, refs_dir, use_hap_subdir=False):
    base = Path(refs_dir) / r["source"]
    if use_hap_subdir:
        base = base / r["results_subdir"]
    return base / f"{asm(r)}.fna"


def write_sanitized_fasta(src, dst):
    """Cactus requires ACGTN only; convert IUPAC ambiguity codes (e.g. k) to N."""
    src, dst = Path(src), Path(dst)
    dst.parent.mkdir(parents=True, exist_ok=True)
    with open(src) as inf, open(dst, "w") as outf:
        for line in inf:
            if line.startswith(">"):
                outf.write(line)
            else:
                s = line.strip()
                outf.write("".join(c if c.upper() in "ACGTN" else "N" for c in s) + "\n")
