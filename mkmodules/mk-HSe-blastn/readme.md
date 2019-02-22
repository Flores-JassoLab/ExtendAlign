## mk-HSe-blastn
**Author(s):** Mariana Flores-Torres (mariana.flo.tor@gmail.com), Israel Aguilar-Ordoñez (iaguilaror@gmail.com)
**Date:** February-2019

## To-do:
NONE

## Module Description:
Blastn run in High Sensitivity (HSe) mode with an ExtendAlign fasta query file over an ExtendAlign fasta blastn database previously created.

1. Blastn run allows gapped alignments and uses the smallest word size (7).
2. Unlike basic blastn results, `HSe-blastn` reports the original query and subject sequence lengths.
3. The query and subject length values will be used in modules downstream to decide if an alignment can be extended by ExtendAlign.

## Module Dependencies:
NCBI [BLAST 2.8.1+](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download) (Camacho, Christiam, et al. "BLAST+: architecture and applications." BMC bioinformatics 10.1 (2009): 421).

### Input:
A fasta file with `.EAfa` extension.

Example line(s):
```
>22{EA}hsa-let-7a-5p.MIMAT0000062
UGAGGUAGUAGGUUGUAUAGUU
```

**Note(s):**

* The string`NUMBER{EA}` at the beginning of the fasta header, corresponds to a custom string added by a previous ExtendAlign module (`mk-create_EAfasta`).

### Output:
A custom blastn output TAB separated file, with `.blastn.tsv` extension

Example line(s):
```
  qlength qseqid  slength sseqid  pident  length  mismatch        gaps    qstart  qend    sstart  send      evalue  bitscore        sstrand
  22      hsa-let-7a-5p.MIMAT0000062      96      mmu-let-7a-2.MI0000557  100.000 22      0       0122      17      38      6.54e-06        35.9    plus
```

**Note(s):**

* `qlength` and `slength` columns are custom ExtendAlign outputs.
* Basic column description taken from [BLAST® Command Line Applications User Manual](https://www.ncbi.nlm.nih.gov/books/NBK279684/).


Output File Column Descriptions:

`qlength`: Nucleotide length for the query that was aligned in this hit.
`qseqid`: Fasta header for query sequence.
`slength`: Nucleotide length for the subject that was aligned in this hit.
`seqid`: Fasta header for subject sequence.
`pident`: Percentage of identical matches.
`length`: Alignment length.
`mismatch`: Number of mismatches.
`gaps`: Total number of gap.
`qstart`: Start of alignment in query.
`qend`: End of alignment in query.
`sstart`: Start of alignment in subject.
`send`: End of alignment in subject.
`evalue`: Expect value.
`bitscore`: Bit score.
`sstrand`: Subject Strand where the alignment hit was located.


## Module Parameters:

Path to main ExtendAlign fasta file that defines the blastn database.
An ExtendAlign blast database is created by an upstream module (`mk-create_blastdb`).
```
BLAST_DATABASE="../../test/data/blastdb/mmu-premiRNAs22.fa.EAfa"
```

Number of threads (CPUs) to use in `HSe-blastn` search.
```
BLAST_THREADS="1"
```

Subject strand to search against in database/subject.
`HSe-blastn` can choose from: `both`, `minus`, or `plus`.
```
BLAST_STRAND="both"
```

Number of aligned sequences to keep.
```
BLAST_MAX_TARGET_SEQS="100"
```

Expect value (E) for saving hits.
```
BLAST_EVALUE="10"
```

**Note(s):**

* To find more about blastn parameters [BLAST® Command Line Applications User Manual](https://www.ncbi.nlm.nih.gov/books/NBK279684/).

## Testing the module:

1. Test this module locally by running,
```
bash testmodule.sh
```

2. ```[>>>] Module Test Successful``` should be printed in the console...

