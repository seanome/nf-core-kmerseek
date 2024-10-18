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
    query_or_against   // string: "query" or "against" to prevent filename collisions in all-by-all comparisons

    main:

    ch_versions = Channel.empty()

    // TODO: skip SEQKIT_SPLIT2 if number of reads is greater than the input fasta size
    // use countFasta Nextflow operator:
    // https://www.nextflow.io/docs/latest/reference/operator.html#countfasta
    SEQKIT_SPLIT2(
        proteins,
    )
    ch_versions = ch_versions.mix(SEQKIT_SPLIT2.out.versions)


    split_reads = SEQKIT_SPLIT2.out.reads
        .transpose()
        .map {
            meta, reads -> [
                [id: reads.getBaseName(), aggregate_id:meta.id, single_end:true],
                reads
            ]
        }

    SOURMASH_MANYSKETCH (
        split_reads,
        alphabet,
        ksizes,
        query_or_against,
    )

    ch_versions = ch_versions.mix(SOURMASH_MANYSKETCH.out.versions)

    // TODO: Add `sourmash sig describe` to get # kmers and other info about the signature to send to MultiQC
    // TODO: Add sig2kmer here maybe? Or maybe do that all later
    // TODO: Add k-mer counting with Sourmash NodeGraph here

    emit:
    signatures = SOURMASH_MANYSKETCH.out.signatures
    versions    = ch_versions
}
