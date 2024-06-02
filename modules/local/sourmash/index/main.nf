process SOURMASH_INDEX {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "docker.io/olgabot/sourmash_branchwater"

    input:
    tuple val(meta), path(siglist)
    val(alphabet)
    val(ksize)

    output:
    tuple val(meta), path("*.sbt.zip"), emit: signature_index
    path "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // --ksize needs to be specified with the desired k-mer size to be selected in ext.args
    def args = task.ext.args ?: ""
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    # Branchwater version = "sourmash scripts" for now
    sourmash scripts index \\
        --cores $task.cpus \\
        --ksize $ksize \\
        --moltype $alphabet \\
        $args \\
        '${prefix}.${alphabet}.k${ksize}.index.zip' \\
        $siglist

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
    END_VERSIONS
    """
}
