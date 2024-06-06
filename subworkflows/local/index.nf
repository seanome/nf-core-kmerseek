//
// Subworkflow with functionality specific to the nf-core/kmerseek pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { SOURMASH_INDEX } from '../../modules/local/sourmash/index'

/*
========================================================================================
    SUBWORKFLOW TO INITIALISE PIPELINE
========================================================================================
*/

workflow INDEX {

    take:
    target_db_sigs     // meta, sigs: Sourmash signaturs

    main:

    ch_versions = Channel.empty()

    // target_db_sigs.view{ "target_db_sigs: ${it}" }

    target_db_sigs_grouped = target_db_sigs
        // .view{ "target_db_sigs: ${it}" }
        .map{ 
            meta, reads ->
            [[id: meta.original_id, single_end: meta.single_end, ksize: meta.ksize, alphabet: meta.alphabet], reads] }
        .groupTuple(by: 0)
    // target_db_sigs_grouped.view { "target_db_sigs_grouped: ${it}" }

    SOURMASH_INDEX(target_db_sigs_grouped)

    ch_versions = ch_versions.mix(SOURMASH_INDEX.out.versions)

    emit:
    signature_index  = SOURMASH_INDEX.out.signature_index
    versions         = ch_versions
}
