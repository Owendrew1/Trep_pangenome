# Trep_pangenome

Minigraph-Cactus pangenome for *Trifolium repens*. **Consumes outputs from index_Trep_refs** — it does not re-run or duplicate the indexing sample catalog.

## Inputs vs outputs

| Role | Where |
|------|--------|
| Indexed FASTAs (from indexing) | `refs_dir` — default scratch tree after `index_Trep_refs` |
| Indexing finished | `index_done_flag` — e.g. `ref_indexing.done` on scratch |
| Genome list (source/file paths) | `index_samples_csv` → **index_Trep_refs** `resources/samples.csv` (read-only) |
| Cactus names + on/off | `pangenome_samples_csv` → `resources/pangenome_genomes.csv` only |
| Graph + Cactus work | `output_dir` on your scratch |

## Layout

```text
Trep_pangenome/
  config/config.yaml
  resources/pangenome_genomes.csv   # cactus_name, enabled, row_id only
  scripts/run_pangenome.sh
  workflow/Snakefile
  workflow/rules/common.smk
  workflow/envs/cactus.yaml
```

## Run (Nepenthes)

```bash
conda activate snakemake   # if needed for snakemake only
cd ~/github-repos/Trep_pangenome
git pull origin main

# Check prior progress (Jun 4 run got to minigraph mapping before OOM)
bash scripts/check_pangenome.sh

# Resume in tmux (do not delete work/jobstore)
bash scripts/resume_pangenome.sh
```

Requires **index_Trep_refs** finished (`index_done_flag` exists, `.fna` under `refs_dir`).

**If it dies again at minigraph mapping:** lower `map_cores` (e.g. 8) and/or `--maxCores` in `config/config.yaml`.

If you still use the **old** repo `index_Trep_refs/results/` layout (`{source}/{haplotype}/*.fna`), set `refs_dir` to that folder and `refs_use_haplotype_subdir: true`.

## Status

Jun 4 run reached minigraph mapping then OOM (SIGTERM). Jobstore on scratch supports resume after lowering `map_cores` / `--maxCores`.
