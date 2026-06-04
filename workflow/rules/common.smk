# Shared helpers for workflow/Snakefile (same load_samples as index_Trep_refs).

import csv


def load_samples(path):
    with open(path, newline="") as f:
        rows = list(csv.DictReader(f))
    for i, r in enumerate(rows, 1):
        for k in list(r.keys()):
            r[k] = (r[k] or "").strip()
        r["row_id"] = f"{i:04d}"
    return rows


def enabled(r):
    return r.get("enabled", "yes").lower() in ("yes", "y", "1", "true")
