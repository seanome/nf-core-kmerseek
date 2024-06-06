//
// Subworkflow with functionality specific to the nf-core/kmerseek pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { SOURMASH_MANYSKETCH } from '../../modules/local/sourmash/manysketch'
include { SEQKIT_SPLIT2       } from '../../modules/local/seqkit/split2'

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

    SEQKIT_SPLIT2(
        proteins,
    )
    ch_versions = ch_versions.mix(SEQKIT_SPLIT2.out.versions)


    split_reads = SEQKIT_SPLIT2.out.reads
        .transpose()
        .map {
            meta, reads -> [
                [id: reads.getBaseName(), original_id:meta.id, single_end:true],
                reads
            ]
        }

    SOURMASH_MANYSKETCH (
        split_reads,
        alphabet,
        ksizes,
    )

    sigs_ksize = SOURMASH_MANYSKETCH.out.signatures
        .map{ meta, sig ->
            [assignKsizeAlphabet(meta, sig, alphabet), sig]}
    // sigs_ksize.view{ "sigs_ksize: ${it}" }

    ch_versions = ch_versions.mix(SOURMASH_MANYSKETCH.out.versions)

    // TODO: Add `sourmash sig describe` to get # kmers and other info about the signature to send to MultiQC
    // TODO: Add sig2kmer here maybe? Or maybe do that all later
    // TODO: Add k-mer counting with Sourmash NodeGraph here

    emit:
    signatures  = sigs_ksize
    versions    = ch_versions
}


def assignKsizeAlphabet(LinkedHashMap meta, sig, String alphabet) {
    def tokens = sig.getBaseName().tokenize(".")
    def ksize = tokens[-2].replace("k", "")
    new_meta = [:]
    new_meta.id = meta.id
    new_meta.original_id = meta.original_id
    new_meta.single_end = meta.single_end
    new_meta.ksize = ksize
    new_meta.alphabet = alphabet
    return new_meta
}