process SOURMASH_INDEX {
    tag "${meta.id}__k${meta.ksize}"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "docker.io/olgabot/sourmash_branchwater"

    input:
    tuple val(meta), path(siglist)

    output:
    tuple val(meta), path("*.index.zip"), emit: signature_index
    path "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // --ksize needs to be specified with the desired k-mer size to be selected in ext.args
    def args = task.ext.args ?: ""
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    # Branchwater version of index only accepts CSV files (can't use signatures directly),
    # so create a CSV file with the signature file name
    touch ${meta.id}__index.csv
    for sig in $siglist; do
        echo \$sig >> ${meta.id}__index.csv
    done

    # Branchwater version = "sourmash scripts" for now
    sourmash scripts index \\
        --cores $task.cpus \\
        --ksize $meta.ksize \\
        --moltype $meta.alphabet \\
        --scaled 1 \\
        $args \\
        --output '${prefix}.${meta.alphabet}.k${meta.ksize}.index.zip' \\
        ${meta.id}__index.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
    END_VERSIONS
    """
}
