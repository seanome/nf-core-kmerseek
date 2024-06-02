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

workflow KMERIZE {

    take:
    proteins           // meta, fasta: Path to input fasta file
    alphabet           // string: Alphabet of the input sequences (dna, protein, dayhoff, hp)
    ksizes             // string: k=\d+,k=\d+ k-mer sizes to use

    main:


}