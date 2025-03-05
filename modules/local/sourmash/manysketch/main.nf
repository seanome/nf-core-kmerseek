process SOURMASH_MANYSKETCH {
    tag "${meta.id}_${alphabet}_k${ksize}"

    conda "${moduleDir}/environment.yml"
    container "docker.io/olgabot/sourmash_branchwater:latest"

    input:
    tuple val(meta), path(sequence)
    val(alphabet)
    each ksize
    val(query_or_against)

    output:
    tuple val(meta), path("*.sig.zip"), emit: signatures
    path "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // required defaults for the tool to run, but can be overridden
    def args = "--singleton --param-string '${alphabet},scaled=1,k=${ksize},abund'"
    def prefix = task.ext.prefix ?: "${meta.id}"
    def BRANCHWATER_VERSION = '0.9.3' // Version not available using command line
    """
    # manysketch only accepts CSV files (can't use fastas directly),
    # so create a CSV file with the fasta sequence name
    echo "name,genome_filename,protein_filename" > ${meta.id}__manysketch.csv
    for f in $sequence; do
        echo "\$(basename \$f),,\$f" >> ${meta.id}__manysketch.csv
    done
    head ${meta.id}__manysketch.csv
    wc -l ${meta.id}__manysketch.csv
    sourmash scripts manysketch \\
        --debug \\
        -c $task.cpus \\
        $args \\
        --output '${query_or_against}.${prefix}.${alphabet}.k${ksize}.sig.zip' \\
        ${meta.id}__manysketch.csv

    cat <<-END_VERSIONS > versions.yml
"${task.process}":
    sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
    sourmash_plugin_branchwater: $BRANCHWATER_VERSION
END_VERSIONS
    """
}
