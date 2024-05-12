process SOURMASH_SKETCH_DYNAMIC_KSIZE {
    memory { sequence.size() < 1.MB ? check_max( 1.GB * task.attempt, 'memory'  ) : check_max( 72.GB * task.attempt, 'memory'  ) }
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sourmash:4.8.4--hdfd78af_0':
        'biocontainers/sourmash:4.8.4--hdfd78af_0' }"

    input:
    tuple val(meta), path(sequence)
    val(alphabet)
    each ksize

    output:
    tuple val(meta), path("*.sig"), emit: signatures
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // required defaults for the tool to run, but can be overridden
    def args = alphabet == "protein"
                ? "protein --singleton --param-string 'scaled=1,k=$ksize,abund'"
                : "protein --singleton --$alphabet --param-string 'scaled=1,k=$ksize,abund'"
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    sourmash sketch \\
        $args \\
        --merge '${prefix}' \\
        --output '${prefix}.${alphabet}.k${ksize}.sig' \\
        $sequence

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
    END_VERSIONS
    """
}
