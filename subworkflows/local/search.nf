// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules

include { SOURMASH_MULTISEARCH } from '../../modules/local/sourmash/multisearch'

workflow SEARCH {

    take:
    // TODO nf-core: edit input (take) channels
    query_sigs   // channel: [ val(meta), [ sig ] ]
    against_sigs // channel: [ val(meta), [ sig ] ]

    main:

    ch_versions = Channel.empty()

    // TODO nf-core: substitute modules here for the modules of your subworkflow

    against_sigs_ksize_alphabet = against_sigs
        .view{ "against_sigs: ${it}" }
        .map{
            meta, sig ->
                split = sig.baseName.tokenize('.')
                meta.ksize = split[-2].strip('k') as Integer
                meta.alphabet = split[-3]
                [
                    meta, 
                    sig
                ]
        }
        .view{ "against_sigs_meta_ksize_alphabet: ${it}" }
        .map{
            meta, sig ->
                [
                    [ksize: meta.ksize, alphabet: meta.alphabet], 
                    [id: meta.id, single_end: meta.single_end, ksize: meta.ksize, alphabet: meta.alphabet], 
                    sig
                ] 
            }
    against_sigs_ksize_alphabet.view { "against_sigs_ksize_alphabet: ${it}" }

    query_sigs_ksize_alphabet = query_sigs
        .view{ "query_sigs: ${it}" }
        .map{
            meta, sig ->
                split = sig.baseName.tokenize('.')
                meta.ksize = split[-2].strip('k') as Integer
                meta.alphabet = split[-3]
                [
                    meta, 
                    sig
                ]
        }
        .view{ "query_sigs_meta_ksize_alphabet: ${it}" }
        .map{
            meta, sig ->
                [
                    [ksize: meta.ksize, alphabet: meta.alphabet], 
                    [id: meta.id, single_end: meta.single_end, ksize: meta.ksize, alphabet: meta.alphabet], 
                    sig
                ] 
            }
    query_sigs_ksize_alphabet.view { "query_sigs_ksize_alphabet: ${it}" }

    query_against = query_sigs_ksize_alphabet.join(against_sigs_ksize_alphabet, by:0)
        .view{ "query_against: ${it}" }

    SOURMASH_MULTISEARCH(
        query_against
    )

    emit:
    // TODO nf-core: edit emitted channels
    multisearch_csvs      = SOURMASH_MULTISEARCH.out.csv           // channel: [ val(meta), [ bam ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}

