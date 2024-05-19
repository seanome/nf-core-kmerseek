process SOURMASH_MANYSEARCH {
    tag "${query_meta.id}_${db_meta.id}_k${ksize}"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "docker.io/olgabot/sourmash_branchwater"

    input:
    tuple val(ksize), val(query_meta), path(query_sig), val(db_meta), path(db_sig)
    val(alphabet)
    val(threshold)

    output:
    // The line below doesn't work
    // tuple val([id: "${query_meta.id}.${db_meta.id}.k${ksize}", k: val(ksize), moltype: alphabet, query: query_meta.id, db: db_meta.id]), path("*.csv")      , emit: matches_csv
    // Use simple string instead of creating a new metadata object
    tuple val("${query_meta.id}.${db_meta.id}.k${ksize}"), path("*.csv")      , emit: matches_csv
    tuple val("${query_meta.id}.${db_meta.id}.k${ksize}"), path("*.names.txt"), emit: matches_names_txt
    path "versions.yml"                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:

    // required defaults for the tool to run, but can be overridden
    // def args = "--singleton --param-string '$alphabet,scaled=1,k=$ksize,abund'"
    def prefix = task.ext.prefix ?: "${query_meta.id}.${db_meta.id}.k${ksize}"
    def output_csv = "${prefix}.csv"
    def matching_names = "${prefix}.names.txt"
    def BRANCHWATER_VERSION = '0.9.3' // Version not available using command line
    """
    sourmash scripts manysearch \\
        -m $alphabet \\
        -k $ksize \\
        --output $output_csv \\
        --scaled 1 \\
        --threshold ${threshold} \\
        $query_sig \\
        $db_sig
    
    ## tail -n +2 ignores the first line (header)
    cut -f 3 -d, $output_csv \\
        | tail -n +2 \\
        > ${matching_names}

    cat <<-END_VERSIONS > versions.yml
"${task.process}":
    sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
    sourmash_plugin_branchwater: $BRANCHWATER_VERSION
END_VERSIONS
    """
}
