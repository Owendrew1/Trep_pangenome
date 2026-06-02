# Trep_pangenome — *Trifolium repens* pangenome (Minigraph-Cactus)

**This repository is the Cactus / pangenome pipeline only.**  
It is **not** the indexing pipeline — that is a separate repo.

### Two repos in `~/github-repos/`

| Repo | Purpose | You run |
|------|---------|---------|
| **`index_Trep_refs`** | Decompress FASTAs, samtools/GATK/BWA indexing | Indexing Snakemake (`Snakefile` there) |
| **`Trep_pangenome`** | Minigraph-Cactus graph + Giraffe indexes | **This repo** — `cactus-pangenome` via Snakemake |

```text
~/github-repos/
  index_Trep_refs/     # linear refs → results/*_genomic.fna, .fai, BWA, …
  Trep_pangenome/      # THIS REPO — reads those FASTAs, builds pangenome graph
```

`Trep_pangenome` **reads** `~/github-repos/index_Trep_refs/results/` and must **not** edit files under `index_Trep_refs`.

**Large Cactus outputs** (graph, jobstore, logs) go on **scratch**, not in the git clone:

```text
/scratch/uottawa.o.univ/odrew060/Trep_pangenome/
  results/    # seqfile, trifolium_repens/*.gfa.gz, *.gbz, …
  work/       # Toil jobstore + scratch
  logs/
```

### What belongs in this repo (git)

Expected contents of `~/github-repos/Trep_pangenome/`:

```text
Snakefile
workflow/
config/config.yaml      # Snakefile loads this (not a stray config.yaml at repo root)
envs/
samples.csv
scripts/
README.md
```

If you see **`results/`**, **`profiles/`**, or a root **`config.yaml`** in the clone, those are leftovers from earlier setup — safe to remove from the repo; paths in `config/config.yaml` point at scratch for outputs.

---

## Part 1 — What this project is

### Purpose

Build a **pangenome graph** from multiple *T. repens* assemblies using **`cactus-pangenome`**. The graph captures structural variation and haplotype differences that no single linear reference can represent.

### Relationship to `index_Trep_refs`

| | `index_Trep_refs` | `Trep_pangenome` (**this repo**) |
|---|-------------------|----------------------------------|
| **Pipeline** | Linear reference indexing | Minigraph-Cactus pangenome |
| **Path** | `~/github-repos/index_Trep_refs` | `~/github-repos/Trep_pangenome` |
| **Reads from** | `/scratch/references/...` (raw gz) | `index_Trep_refs/results/*.fna` |
| **Writes to** | `index_Trep_refs/results/` | `/scratch/.../Trep_pangenome/results/` |
| **Tools** | samtools, GATK, BWA | Cactus, Toil, vg (indexes only) |

### Confirmed settings

| Setting | Value |
|---------|--------|
| **Graph reference** | `UTM_haploid` (`GCA_030408175.1`) |
| **Cactus cores** | 32–48 (`mg`/`cons`/`index`: 48; `map`: 32 in `config/config.yaml`) |
| **Job submission** | Site job software handles scheduling (no manual SLURM partition in this repo) |
| **Output location** | `/scratch/uottawa.o.univ/odrew060/Trep_pangenome/` |

Verify the scratch path exists on Nepenthes (`bash scripts/preflight.sh`) and matches your account layout. All output paths are derived from **`scratch_dir`** in `config/config.yaml` only.

### Workflow

1. **`make_seqfile`** — Cactus seqfile under scratch `results/seqfile.txt`.
2. **`cactus_pangenome`** — `cactus-pangenome` (long, high memory).
3. **`pangenome_done`** — completion flag `.pg.done`.

### Expected outputs (under scratch)

Prefix: `/scratch/.../Trep_pangenome/results/trifolium_repens/trifolium_repens`

| Suffix | Role |
|--------|------|
| `.full.gfa.gz` | Full graph |
| `.full.gbz` | Graph for vg |
| `.d2.vcf.gz` | Variants (filter=2 graph) |
| `.hal` | HAL alignment |
| `.d2.dist`, `.d2.min` | Giraffe short-read indexes |
| `.pg.done` | Snakemake done flag |

### Repository layout (git)

```text
Snakefile
workflow/common.smk
config/config.yaml
samples.csv
envs/cactus.yaml          # Cactus only — deployed by snakemake --use-conda per rule
environment.yaml          # project conda env (Snakemake driver)
scripts/preflight.sh
README.md
```

Not in git: scratch `results/`, `work/`, `logs/`, `.snakemake/`.

---

## Nepenthes environment

**Host:** `rap-p125` · **Conda:** Miniforge at `/opt/miniforge3` (use project envs, not server-wide installs).

Typical `PATH` (no SLURM CLI):

```text
~/.local/bin:~/bin:/opt/miniforge3/condabin:/usr/local/bin:/usr/bin:…
```

Check with `echo $PATH`. There is no `module` command and no `sbatch`/`sinfo` in this shell — job submission goes through your lab’s usual workflow.

### Install policy (per repo, not server-wide)

Install tools **only inside the conda env for that pipeline**, not with `apt`, not into base conda, and not shared across projects unless intentional.

| Repo | Conda env | What goes in the env |
|------|-----------|----------------------|
| **`index_Trep_refs`** | (that repo’s env, e.g. from its `environment.yaml`) | samtools, GATK, BWA, Snakemake for indexing |
| **`Trep_pangenome`** | **`trep_pangenome`** | Snakemake + SLURM executor plugin (`environment.yaml`) |
| **`Trep_pangenome` rules** | auto via `--use-conda` | Cactus in `envs/cactus.yaml` when the Cactus rule runs |

### One-time setup for this repo

```bash
source /opt/miniforge3/etc/profile.d/conda.sh   # if conda activate fails

cd ~/github-repos/Trep_pangenome
conda env create -f environment.yaml            # creates env trep_pangenome
conda activate trep_pangenome
snakemake --version
```

Do **not** `conda install` Snakemake into base or use `pip install` / `apt install` for pipeline tools on the server.

Cactus is pulled into an isolated env the first time you run with `snakemake --use-conda` (from `envs/cactus.yaml`), or use Singularity if enabled in `config/config.yaml`.

---

### Snapshot (current state)

- **7 / 8** assemblies enabled; `drTriRepe_Sanger_hap2_alt` off until FASTA exists.
- Reference **`UTM_haploid`** confirmed.
- Workflow tested through seqfile + dry-run; **full Cactus run not started** on scratch yet.

---

## Part 2 — Before using this pipeline

### Science and samples

- [x] **Reference genome** — `UTM_haploid`.
- [ ] **Assembly list** — 7 enabled now; enable hap2_alt when available in `index_Trep_refs/results/`.
- [ ] **`bash scripts/preflight.sh`** — all enabled FASTAs present.

### Compute

- [x] **Cores** — 32–48 configured in `config/config.yaml`.
- [x] **Job submission** — handled by lab/site software (not configured in this repo).
- [ ] **Scratch** — create and check space: `/scratch/uottawa.o.univ/odrew060/Trep_pangenome/`.
- [ ] **Cactus runtime** — conda (`envs/cactus.yaml`) vs Singularity (`use_singularity: true`).

### Environment

- [ ] Create project env: `conda env create -f environment.yaml` → `conda activate trep_pangenome`
- [ ] Clone/pull this repo to `~/github-repos/Trep_pangenome`
- [ ] Do not rely on server-wide or base-conda installs for Snakemake/Cactus

### Pre-run

```bash
cd ~/github-repos/Trep_pangenome
conda activate trep_pangenome
bash scripts/preflight.sh
snakemake -n --cores 1 --use-conda
```

### Run (when ready)

```bash
cd ~/github-repos/Trep_pangenome
conda activate trep_pangenome
bash scripts/preflight.sh
snakemake -n --cores 1 --use-conda
# launch via your site job software, e.g.:
snakemake --cores 1 --use-conda
```

Monitor: `/scratch/uottawa.o.univ/odrew060/Trep_pangenome/logs/trifolium_repens.cactus-pangenome.log`

---

## Plan for vg Giraffe

Graph construction (this repo) and read mapping (Giraffe) stay **separate**. Cactus builds the graph and **indexes**; Giraffe aligns reads **to the graph** rather than to one linear FASTA.

### Why align to the graph?

A linear reference forces every read onto a single genome sequence. White clover here spans **multiple assemblies and haplotypes** that differ by SNPs, indels, and larger structural changes — no one FASTA contains all of that.

**Without graph mapping (BWA to one ref only):** reference bias, poor or missing alignments for haplotype-specific sequence, and analyses that silently reflect the chosen reference rather than clover diversity as a whole.

**With the graph + Giraffe:** reads can map to alternate paths that exist in other assemblies; the pangenome and VCF are used for read placement, not only for visualization.

Linear BWA in `index_Trep_refs` remains useful for “reads vs **this one** assembly”; Giraffe is for **pangenome-wide** read analysis after this pipeline finishes.

### What this repo prepares

`--giraffe clip filter` + `--filter 2` → `trifolium_repens.d2.dist` and `.d2.min` on scratch.

### Planned follow-on (not implemented)

Separate repo/pipeline (same pattern as `index_Trep_refs` ↔ `Trep_pangenome`):

```text
index_Trep_refs   →  linear refs + optional BWA
Trep_pangenome    →  graph + Giraffe indexes   ← this repo
(Trep_giraffe)    →  reads → GAM/BAM
```

Rebuild or re-map if the graph is updated with new assemblies.

---

## Adding genomes

After `index_Trep_refs` has a new FASTA, add a row to **`samples.csv`**:

| Column | Meaning |
|--------|---------|
| `source`, `haplotype`, `assembly`, `file` | Match indexing repo |
| `cactus_name` | Cactus ID — **no dots** |
| `results_subdir` | Subfolder under `index_Trep_refs/results/` (`1`, `2`, `haploid`, …) |
| `enabled` | `yes` / `no` |

Path:

```text
~/github-repos/index_Trep_refs/results/{source}/{results_subdir}/{file_stem}.fna
```

Then validate, regenerate seqfile, re-run Cactus when ready.

---

## GitHub

- GitHub repo name: **`Trep_pangenome`** (Cactus pipeline).
- **`index_Trep_refs`** is a separate GitHub repo for indexing.

This clone holds **code only**; scratch outputs are not committed.

### Sync Mac → Nepenthes (until GitHub is set up)

```bash
rsync -avz --exclude results --exclude work --exclude logs --exclude .snakemake \
  ~/Documents/Desktop/cactus_pipeline/ \
  odrew060@Nepenthes.rdc.uolocal:~/github-repos/Trep_pangenome/
```

### First-time push

```bash
cd /path/to/Trep_pangenome   # or ~/github-repos/Trep_pangenome on server

git init
git add Snakefile workflow/ config/ envs/ environment.yaml samples.csv scripts/ README.md .gitignore
git status                  # confirm no results/, work/, logs/

git commit -m "Initial Trep_pangenome Snakemake workflow for Minigraph-Cactus."

# Create empty repo on GitHub (e.g. Trep_pangenome), then:
git branch -M main
git remote add origin git@github.com:YOUR_USER/Trep_pangenome.git
git push -u origin main
```

On Nepenthes, clone instead of rsync once the remote exists:

```bash
cd ~/github-repos
git clone git@github.com:YOUR_USER/Trep_pangenome.git
```

### Day-to-day

```bash
git pull
# edit, then:
git add -u
git commit -m "Describe change."
git push
```

---

## Future work

- Run `cactus-pangenome` on scratch when ready.
- Enable hap2_alt and additional genomes in `samples.csv`.
- Giraffe mapping pipeline using `.d2.dist` / `.d2.min`.
