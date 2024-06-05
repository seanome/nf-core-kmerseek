//
// Subworkflow with functionality specific to the nf-core/kmerseek pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { SOURMASH_MANYSKETCH } from '../../modules/local/sourmash/manysketch'

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

    ch_versions = Channel.empty()

    SOURMASH_MANYSKETCH (
        proteins,
        alphabet,
        ksizes,
    )

    sigs_ksize = SOURMASH_MANYSKETCH.out.signatures
        .map{ meta, sig ->
            tokens = sig.getBaseName().tokenize(".")
            ksize = tokens[-2].replace("k", "")
            meta.ksize = ksize
            meta.alphabet = alphabet
            [meta, sig]}
    sigs_ksize.view()

    ch_versions = ch_versions.mix(SOURMASH_MANYSKETCH.out.versions)

    // TODO: Add `sourmash sig describe` to get # kmers and other info about the signature to send to MultiQC
    // TODO: Add sig2kmer here maybe? Or maybe do that all later
    // TODO: Add k-mer counting with Sourmash NodeGraph here

    emit:
    signatures  = SOURMASH_MANYSKETCH.out.signatures
    versions    = ch_versions
}
