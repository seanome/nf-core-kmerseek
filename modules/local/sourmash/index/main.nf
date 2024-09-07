process SOURMASH_INDEX {
    tag "${meta.id}__k${meta.ksize}"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "docker.io/olgabot/sourmash_branchwater:0.9.7"

    input:
    tuple val(meta), path(siglist)

    output:
    tuple val(meta), path("*.index.rocksdb"), emit: signature_index
    path "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // --ksize needs to be specified with the desired k-mer size to be selected in ext.args
    def args = task.ext.args ?: ""
    def prefix = task.ext.prefix ?: "${meta.id}.${meta.alphabet}.k${meta.ksize}"

    """
    # To avoid long argument lists with "too many arguments" error, we will create a manifest file
    # so create a CSV file with the signature file name
    touch ${prefix}__filelist.csv
    for sig in $siglist; do
        echo \$sig >> ${prefix}__filelist.csv
    done

    # Branchwater version = "sourmash scripts" for now
    sourmash scripts index \\
        --cores $task.cpus \\
        --ksize $meta.ksize \\
        --moltype $meta.alphabet \\
        --scaled 1 \\
        --output '${prefix}.index.rocksdb' \\
        ${prefix}__filelist.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
    END_VERSIONS
    """
}
