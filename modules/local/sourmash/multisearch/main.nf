process SOURMASH_MULTISEARCH {
    tag "${meta.alphabet}_k${meta.ksize}"
    label "process_medium"

    conda "${moduleDir}/environment.yml"
    container "docker.io/olgabot/sourmash_branchwater_multisearch_prob_overlap"

    input:
    tuple val(meta), val(query_meta), path(query_sig), val(against_meta), path(against_sig)

    output:
    tuple val(meta), path("*.csv"), emit: csv
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // $ sourmash scripts multisearch --help

    // == This is sourmash version 4.8.11. ==
    // == Please cite Irber et. al (2024), doi:10.21105/joss.06830. ==

    // usage:  multisearch [-h] [-q] [-d] -o OUTPUT [-t THRESHOLD] [-k KSIZE] [-s SCALED] [-m {DNA,protein,dayhoff,hp}] [-c CORES] [-a] query_paths against_paths

    // massively parallel in-memory sketch search

    // positional arguments:
    // query_paths           input file of sketches
    // against_paths         input file of sketches

    // options:
    // -h, --help            show this help message and exit
    // -q, --quiet           suppress non-error output
    // -d, --debug           provide debugging output
    // -o OUTPUT, --output OUTPUT
    //                         CSV output file for matches
    // -t THRESHOLD, --threshold THRESHOLD
    //                         containment threshold for reporting matches (default: 0.01)
    // -k KSIZE, --ksize KSIZE
    //                         k-mer size at which to select sketches
    // -s SCALED, --scaled SCALED
    //                         scaled factor at which to do comparisons
    // -m {DNA,protein,dayhoff,hp}, --moltype {DNA,protein,dayhoff,hp}
    //                         molecule type (DNA, protein, dayhoff, or hp; default DNA)
    // -c CORES, --cores CORES
    //                         number of cores to use (default is all available)
    // -a, --ani             estimate ANI from containment
    //
    // Example run:
    // sourmash scripts multisearch query.sig.gz database.zip -o results.csv

    // required defaults for the tool to run, but can be overridden
    def args = "--ksize ${meta.ksize} --moltype ${meta.alphabet} --threshold 0 --scaled 1"
    def prefix = task.ext.prefix ?: "${query_meta.id}--in--${against_meta.id}.${meta.alphabet}.${meta.ksize}"
    def BRANCHWATER_VERSION = '0.9.3' // Version not available using command line
    """
    sourmash scripts multisearch \\
        --debug \\
        -c $task.cpus \\
        $args \\
        --output '${prefix}.multisearch.csv' \\
        ${query_sig} \\
        ${against_sig}

    cat <<-END_VERSIONS > versions.yml
"${task.process}":
    sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
    sourmash_plugin_branchwater: $BRANCHWATER_VERSION
END_VERSIONS
    """
}
