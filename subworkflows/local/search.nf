//
// Subworkflow with functionality specific to the nf-core/kmerseek pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { SOURMASH_MANYSEARCH } from '../../modules/local/sourmash/manysearch'
include { SEQTK_SUBSEQ        } from '../../modules/nf-core/seqtk/subseq'

/*
========================================================================================
    SUBWORKFLOW TO INITIALISE PIPELINE
========================================================================================
*/

workflow SEARCH {

    take:
    query        // ksize, meta, sig: Path to input signature
    db           // ksize, meta, sig: Path to input signature
    alphabet     // string: Alphabet of the input sequences (dna, protein, dayhoff, hp)
    threshold    // float: Jaccard similarity threshold for sourmash search
    db_fasta     // fasta: Channel Path to the database fasta file

    main:

    ch_versions = Channel.empty()

    // Get the cartesien product (outer product) of query and database signatures on the first key, which is the ksize
    // Match every query to the database with the same ksize
    ksize_query_db = query.combine(db, by: 0)
    ksize_query_db.view()


    SOURMASH_MANYSEARCH (
        ksize_query_db,
        alphabet,
        threshold,
    )
    ch_versions = ch_versions.mix(SOURMASH_MANYSEARCH.out.versions)

    // Create a channel from the db path
    ch_fasta = Channel.fromPath(db_fasta)
    // Trick seqtk into using the metadata from the lists
    fasta_combined_matchlists = ch_fasta.combine(SOURMASH_MANYSEARCH.out.matches_names_lst)
    fasta_combined_matchlists.view()
    fasta_matchlists = db_combined_matchlists.map{ it -> [it[1], it[0], it[2]]}
    fasta_matchlists.view()
    fasta_for_subseq = fasta_matchlists.map{ it -> [[id: it[0]], it[1]]}
    lists_for_subseq = fasta_matchlists.map{ it -> [it[2]]}

    // SEQTK_SUBSEQ(
    //     fasta_for_subseq,
    //     lists_for_subseq,
    // )

    // TODO: Add `sourmash sig describe` to get # kmers and other info about the signature to send to MultiQC
    // TODO: Add sig2kmer here maybe? Or maybe do that all later
    // TODO: Add k-mer counting with Sourmash NodeGraph here -> or maybe make one signature across all?

    emit:
    matches_csv = SOURMASH_MANYSEARCH.out.matches_csv
    matches_names_txt = SOURMASH_MANYSEARCH.out.matches_names_lst
    versions    = ch_versions
}
