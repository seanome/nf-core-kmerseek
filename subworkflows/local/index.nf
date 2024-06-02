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
    alphabet           // string: Alphabet of the input sequences (protein, dayhoff, hp)
    ksizes             // Channel of integers for k-mer sizes to use

    main:
    
    target_db_sigs.view()

    SOURMASH_INDEX(target_db_sigs, alphabet, ksizes)

}