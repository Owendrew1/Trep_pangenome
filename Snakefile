configfile: "config/config.yaml"
include: "workflow/common.smk"

P = scratch_paths()
PGD = str(pangenome_dir())


def targets():
    p = PGD
    n = NAME
    return [
        f"{p}/{n}.full.gbz",
        f"{p}/{n}.full.gfa.gz",
        f"{p}/{n}.d2.vcf.gz",
        f"{p}/{n}.hal",
        f"{p}/{n}.d2.dist",
        f"{p}/{n}.d2.min",
        str(pangenome_done()),
    ]


rule all:
    input:
        targets(),


rule make_seqfile:
    output:
        seqfile=str(P["seqfile"]),
    run:
        if PG["reference"] not in SAMPLE_BY_NAME:
            raise ValueError(f"reference '{PG['reference']}' not in enabled samples")
        if missing := missing_fastas():
            raise ValueError("Missing FASTAs:\n" + "\n".join(missing))
        Path(output.seqfile).parent.mkdir(parents=True, exist_ok=True)
        with open(output.seqfile, "w") as f:
            for r in SAMPLES:
                f.write(f"{r['cactus_name']}\t{fasta_path(r)}\n")


rule cactus_pangenome:
    input:
        seqfile=rules.make_seqfile.output.seqfile,
    output:
        gbz=f"{PGD}/{NAME}.full.gbz",
        gfa=f"{PGD}/{NAME}.full.gfa.gz",
        vcf=f"{PGD}/{NAME}.d2.vcf.gz",
        hal=f"{PGD}/{NAME}.hal",
        dist=f"{PGD}/{NAME}.d2.dist",
        min=f"{PGD}/{NAME}.d2.min",
    log:
        str(P["log"]),
    params:
        jobstore=str(P["jobstore"]),
        work=str(P["work"]),
        extra=PG.get("extra_args", ""),
    resources:
        mem_mb=PG.get("mem_mb", 128000),
        runtime=PG.get("runtime", 2880),
    conda:
        "envs/cactus.yaml",
    shell:
        """
        set -euo pipefail
        mkdir -p {PGD} $(dirname {log}) {params.work}

        cactus-pangenome {params.jobstore} {input.seqfile} \
            --outDir {PGD} --outName {NAME} --reference {PG[reference]} \
            --batchSystem {PG[batch_system]} --workDir {params.work} --logFile {log} \
            --mgCores {PG[mg_cores]} --mapCores {PG[map_cores]} \
            --consCores {PG[cons_cores]} --indexCores {PG[index_cores]} \
            {params.extra}
        """


rule pangenome_done:
    input:
        rules.cactus_pangenome.output,
    output:
        str(pangenome_done()),
    shell:
        "touch {output}"
