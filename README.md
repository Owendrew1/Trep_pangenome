# Trep_pangenome

Minigraph-Cactus pangenome for *Trifolium repens*. Consumes indexed FASTAs from **index_Trep_refs**.

## Layout (same pattern as index_Trep_refs)

```text
Trep_pangenome/
├── environment.yaml          # Snakemake runner (create once)
├── config/config.yaml
├── resources/pangenome_genomes.csv
├── workflow/
│   ├── Snakefile
│   ├── rules/common.smk
│   └── envs/cactus.yaml      # Cactus (Snakemake deploys per rule)
└── scripts/
    ├── run_pangenome.sh
    ├── resume_pangenome.sh
    └── check_pangenome.sh
```

## Setup

```bash
cd Trep_pangenome
conda env create -f environment.yaml
conda activate snakemake   # or the env name conda prints
```

Edit `config/config.yaml`: `refs_dir`, `index_done_flag`, `output_dir`, and `pangenome` settings.

**Cactus (default):** leave `pangenome.cactus_activate` empty. `run_pangenome.sh` passes `--use-conda`; Snakemake installs Cactus from `workflow/envs/cactus.yaml` when the `cactus_pangenome` rule runs.

**Cactus (manual install):** if conda cannot solve or your cluster blocks it, install [Cactus binaries](https://github.com/ComparativeGenomicsToolkit/cactus/releases) and set `pangenome.cactus_activate` to that venv’s `bin/activate` (Nepenthes example is in `config.yaml`).

## Config

| Key | Role |
|-----|------|
| `refs_dir` | Indexed `.fna` tree from indexing |
| `index_done_flag` | Proof indexing finished |
| `output_dir` | Scratch outputs (logs, results, work, done flag) |
| `pangenome_samples_csv` | Genome manifest — every row is included |

## Run

```bash
conda activate snakemake
cd ~/github-repos/Trep_pangenome
./scripts/run_pangenome.sh 1
```

Dry run:

```bash
snakemake -s workflow/Snakefile --directory workflow -n -p --use-conda
```

Resume after failure (do not delete `work/jobstore`):

```bash
bash scripts/resume_pangenome.sh
bash scripts/check_pangenome.sh
```

## Outputs

Under `{output_dir}/results/trifolium_repens/`:

| File | Role |
|------|------|
| `trifolium_repens.full.gbz` + `.dist` + `.min` | Giraffe mapping |
| `trifolium_repens.full.gfa.gz` | Graph (GFA) |
| `trifolium_repens.full.hal` | HAL alignment |
| `trifolium_repens.d2.vcf.gz` | Variants |

Done flag: `{output_dir}/pangenome.done`
