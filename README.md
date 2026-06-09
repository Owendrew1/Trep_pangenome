# Trep_pangenome

Minigraph-Cactus pangenome for *Trifolium repens*. Consumes indexed FASTAs from **index_Trep_refs**.

## Layout

```text
Trep_pangenome/
├── environment.yaml          # Snakemake only
├── config/config.yaml        # container image + bind paths
├── resources/pangenome_genomes.csv
├── workflow/
│   ├── Snakefile
│   └── rules/common.smk
└── scripts/run_pangenome.sh  # snakemake --use-apptainer
```

## Setup

```bash
conda env create -f environment.yaml
conda activate snakemake
```

Edit `config/config.yaml`: `refs_dir`, `index_done_flag`, `output_dir`, `container`, `container_bind`.

Cactus runs from a local `.sif` (`pangenome.container`). If the cluster cannot reach `quay.io`, pull on a machine with Docker, transfer, and build on Nepenthes:

```bash
# Mac
docker pull quay.io/comparative-genomics-toolkit/cactus:v2.9.8
docker save quay.io/comparative-genomics-toolkit/cactus:v2.9.8 -o containers/cactus_v2.9.8.tar
scp containers/cactus_v2.9.8.tar odrew060@Nepenthes.rdc.uolocal:/scratch/odrew060/Trep_pangenome/containers/

# Nepenthes
mkdir -p /scratch/odrew060/Trep_pangenome/containers
apptainer build /scratch/odrew060/Trep_pangenome/containers/cactus_v2.9.8.sif \
  docker-archive:///scratch/odrew060/Trep_pangenome/containers/cactus_v2.9.8.tar
```

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

Done flag: `{output_dir}/pangenome.done`
