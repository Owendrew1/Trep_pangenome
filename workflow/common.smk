import csv
from pathlib import Path

SCRATCH = Path(config["scratch_dir"]).expanduser()
REF = Path(config["index_trep_refs_results_dir"]).expanduser()
OUT = SCRATCH / "results"
PG = config["pangenome"]
NAME = PG["out_name"]


def load_samples(path):
    with open(path, newline="") as f:
        return [
            {k: (v or "").strip() for k, v in row.items()}
            for row in csv.DictReader(f)
        ]


def enabled(r):
    return r.get("enabled", "yes").lower() in ("yes", "y", "1", "true")


ROWS = load_samples(config["samples_csv"])
SAMPLES = [r for r in ROWS if enabled(r)]
SAMPLE_BY_NAME = {r["cactus_name"]: r for r in SAMPLES}


def fasta_stem(r):
    return Path(r["file"].replace(".gz", "")).stem


def fasta_path(r):
    sub = r.get("results_subdir") or r["haplotype"]
    return REF / r["source"] / sub / f"{fasta_stem(r)}.fna"


def missing_fastas():
    return [str(p) for r in SAMPLES if not (p := fasta_path(r)).is_file()]


def pangenome_dir():
    return OUT / NAME


def pangenome_done():
    return pangenome_dir() / f"{NAME}.pg.done"


def scratch_paths():
    """All write locations derived from scratch_dir."""
    return {
        "scratch": SCRATCH,
        "results": OUT,
        "pangenome": pangenome_dir(),
        "seqfile": OUT / "seqfile.txt",
        "jobstore": SCRATCH / "work" / "jobstore",
        "work": SCRATCH / "work" / "scratch",
        "log": SCRATCH / "logs" / f"{NAME}.cactus-pangenome.log",
    }
