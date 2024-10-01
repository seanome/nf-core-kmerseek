// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules

include { SOURMASH_MULTISEARCH } from '../../modules/local/sourmash/multisearch'

workflow SEARCH {

    take:
    // TODO nf-core: edit input (take) channels
    ch_bam // channel: [ val(meta), [ bam ] ]

    main:

    ch_versions = Channel.empty()

    // TODO nf-core: substitute modules here for the modules of your subworkflow

    against_sigs_grouped = against_sigs
        .view{ "against_sigs: ${it}" }
        .map{
            meta, reads ->
            [[id: meta.original_id, single_end: meta.single_end, ksize: meta.ksize, alphabet: meta.alphabet], reads] }
        .groupTuple(by: 0)
    against_sigs_grouped.view { "against_sigs_grouped: ${it}" }

    query_sigs_grouped = query_sigs
        .view{ "query_sigs: ${it}" }
        .map{
            meta, reads ->
            [[id: meta.original_id, single_end: meta.single_end, ksize: meta.ksize, alphabet: meta.alphabet], reads] }
        .groupTuple(by: 0)
    query_sigs_grouped.view { "query_sigs_grouped: ${it}" }

    emit:
    // TODO nf-core: edit emitted channels
    bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}

