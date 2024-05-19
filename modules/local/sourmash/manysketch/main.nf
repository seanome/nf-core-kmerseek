process SOURMASH_MANYSKETCH {
    tag "${meta.id}_k${ksize}"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "docker.io/olgabot/sourmash_branchwater"

    input:
    tuple val(meta), path(sequence)
    val(alphabet)
    each ksize

    output:
    tuple val(ksize), val(meta), path("*.sig.zip"), emit: signatures
    path "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // required defaults for the tool to run, but can be overridden
    def args = "--singleton --param-string '$alphabet,scaled=1,k=$ksize,abund'"
    def prefix = task.ext.prefix ?: "${meta.id}"
    def BRANCHWATER_VERSION = '0.9.3' // Version not available using command line
    """
    # manysketch only accepts CSV files (can't use fastas directly),
    # so create a CSV file with the fasta sequence name
    echo "name,genome_filename,protein_filename\n${meta.id},,${sequence}" > ${meta.id}__manysketch.csv
    sourmash scripts manysketch \\
        --debug \\
        -c $task.cpus \\
        $args \\
        --output '${prefix}.${alphabet}.k${ksize}.sig.zip' \\
        ${meta.id}__manysketch.csv

    cat <<-END_VERSIONS > versions.yml
"${task.process}":
    sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
    sourmash_plugin_branchwater: $BRANCHWATER_VERSION
END_VERSIONS
    """
}
