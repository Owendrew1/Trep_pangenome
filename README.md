# Trep_pangenome

Minigraph-Cactus pangenome for *Trifolium repens*. Consumes indexed FASTAs from **index_Trep_refs**.

## Config

| Key | Role |
|-----|------|
| `refs_dir` | Indexed `.fna` tree from indexing |
| `index_done_flag` | Proof indexing finished |
| `output_dir` | Scratch outputs (logs, results, work, done flag derived from this) |
| `pangenome_samples_csv` | Genome manifest (`cactus_name`, `source`, `file`, `results_subdir`) — every row is included |

`resources/pangenome_genomes.csv` is the only sample list for this pipeline (indexed FASTAs still come from `index_Trep_refs` via `refs_dir`).

## Run

```bash
conda activate snakemake
cd ~/github-repos/Trep_pangenome
./scripts/run_pangenome.sh 1
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
| `trifolium_repens.viz/` | PNG per reference chromosome |

Done flag: `{output_dir}/pangenome.done`
