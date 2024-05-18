process SOURMASH_SKETCH_DYNAMIC_KSIZE {
    tag "$meta.id_k${ksize}"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "docker.io/olgabot/sourmash_branchwater"

    input:
    tuple val(meta), path(sequence)
    val(alphabet)
    each ksize

    output:
    tuple val(meta), path("*.sig.zip"), emit: signatures
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // required defaults for the tool to run, but can be overridden
    def args = "--singleton --param-string '$alphabet,scaled=1,k=$ksize,abund'"
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo "name,genome_filename,protein_filename\n${meta.id},,${sequence}" > ${meta.id}__manysketch.csv
    sourmash scripts manysketch \\
        -c $task.cpus \\
        $args \\
        --output '${prefix}.${alphabet}.k${ksize}.sig.zip' \\
        ${meta.id}__manysketch.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
    END_VERSIONS
    """
}
