Module:	mk-HSe-blastn
Author(s): Mariana Flores (mflores@inmegen.edu.mx), Israel Aguilar (iaguilaror@gmail.com)
Date: FEB 2019

TODO:
	NONE

Module description: run blastn in High Sensitivity mode with an EA fasta query file over a EA fasta blast Database previously created
	a. blastn is run allowing gapped alignments and with the smallest word size (7)
  b. Unlike basic blastn results, HSe-blastn reports the original query and subject sequence lengths
  c. Query and subject lengths will be used in another module downstream to decide if an alignment can be extended by EA

Module Dependencies:
	blastn from ncbi BLAST 2.8.1+ - https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download

	Citations:
	Camacho, Christiam, et al. "BLAST+: architecture and applications." BMC bioinformatics 10.1 (2009): 421.

Input:
  A fasta file with .EAfa extension
  Example line(s):
  ````
  >22{EA}hsa-let-7a-5p.MIMAT0000062
  UGAGGUAGUAGGUUGUAUAGUU
  ````

  Note(s):
	- The "NUMBER{EA}" string of characters at the start of the fasta header, is a custom string added by a previous EA module (mk-create_EAfasta)

Output:
	A custom blastn output TAB separated file, with .blastn.tsv extension
	Example line(s):
	````
	qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand qseq sseq
	22 hsa-let-7a-5p.MIMAT0000062 96 mmu-let-7a-2.MI0000557 100.000 22 0 0 1 22 17 38 6.54e-06 35.9 plus TGAGGTAGTAGGTTGTATAGTT TGAGGTAGTAGGTTGTATAGTT
	````
	Note(s):
	- "qlength" and "slength" columns are custom Extend Align outputs
  - Basic blastn column description taken from: https://www.ncbi.nlm.nih.gov/books/NBK279684/

  Output File Column Descriptions:
  """"
  qlength: Nucleotide length for the query that was aligned in this hit
  qseqid: Fasta ID for the query sequence
  slength: Nucleotide length for the subject that was aligned in this hit
  seqid: Fasta ID for the subject sequence
  pident: Percentage of identical matches
  length: Alignment length
  mismatch: Number of mismatches
  gaps: Total number of gap
  qstart: Start of alignment in query
  qend: End of alignment in query
  sstart: Start of alignment in subject
  send: End of alignment in subject
  evalue: Expect value
  bitscore: Bit score
  sstrand: Subject Strand where the alignment hit was located
	qseq: Aligned part of query sequence
	sseq: Aligned part of subject sequence
  """"

Module parameters:

## Path to main EA fasta file that defines the blast database
#  Proper EA blast database is created by an upstream module (mk-create_blastdb)
BLAST_DATABASE="../../test/data/blastdb/mmu-premiRNAs22.fa.EAfa"

## Number of threads (CPUs) to use in blast search
BLAST_THREADS="1"

## Subject strand to search against in database/subject.
# Choice of "both", "minus", or "plus".
BLAST_STRAND="both"

##
# Number of aligned sequences to keep
BLAST_MAX_TARGET_SEQS="100"

##
# Expect value (E) for saving hits
BLAST_EVALUE="10"

NOTE: find more about blastn parameters here:https://www.ncbi.nlm.nih.gov/books/NBK279684/

Testing the module:

1. Locally test this module by running

	````
	bash testmodule.sh
	````

2. "[>>>] Module Test Successful" should be printed in the console...
