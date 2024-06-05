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

    target_db_sigs.view{ "target_db_sigs: ${it}" }

    SOURMASH_INDEX(target_db_sigs)

    ch_versions = ch_versions.mix(SOURMASH_INDEX.out.versions)

    emit:
    signature_index  = SOURMASH_INDEX.out.signature_index
    versions         = ch_versions
}
