//
// Subworkflow with functionality specific to the nf-core/kmerseek pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { SOURMASH_SKETCH } from '../../modules/nf-core/sourmash/sketch'

/*
========================================================================================
    SUBWORKFLOW TO INITIALISE PIPELINE
========================================================================================
*/

workflow KMERIZE {

    take:
    ch_samplesheet           // meta, fasta: Path to input fasta file

    main:

    ch_versions = Channel.empty()

    ch_samplesheet.view()

    //
    // Print version and exit if required and dump pipeline parameters to JSON file
    //
    SOURMASH_SKETCH (
        ch_samplesheet
    )

    // TODO: Add `sourmash sig describe` to get # kmers and other info about the signature to send to MultiQC
    // TODO: Add sig2kmer here maybe? Or maybe do that all later

    emit:
    signatures = SOURMASH_SKETCH.out.signatures
    versions    = ch_versions
}
