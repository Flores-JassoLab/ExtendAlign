Module:	mk-get_EA_coordinates
Author(s): Israel Aguilar (iaguilaror@gmail.com)
Date: FEB 2019

TODO:
	NONE

Module description: add sequence coordinates to an EA blastn results table to indicate where nucleotides should be extracted from for downstream bulk fasta extraction
  a. This module calculates the length of extendable nucleotides at the 5 prime and 3 prime ends, of query and subjects
  b. It takes into account the many factor that affect a correct comparison of nucleotides, such as:
    - query and subject length
    - differential overhanging - or cases where query's unaligned overhangs are longer than subject's unaligned overhangs, and vice versa
    - strandness - in cases where the blastn hit was reported as a hit in the minus strand of the subject (this requires mirrored operations of the sequence coordinates)
      ^^ e.g. the Subject 5'end extendable coordinates for a "minus" hit are extracted from the 3'end portion of the original Subject sequence
  c. Using all of the above data, this module adds sequence coordinates to indicate where to perform nucleotide extraction to enable a downstream finer match/mismatch count in cases where alignments can be extended
  d. IMPORTANT: this module does not perform the fasta extraction, or the extended match/mismatch recount. Leave that to other mkmodule

Module Dependencies:
	NONE

Input:
  A custom blastn output TAB separated file, with .blastn.tsv or .blastnbesthit.tsv extension
  Example line(s):
  ````
  qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand
  26 hsa-miR-1226-5p.MIMAT0005576 71 mmu-mir-6927.MI0022774 76.923 26 6 0 1 26 1 26 0.039 23.5 plus
  26 hsa-miR-4700-3p.MIMAT0019797 79 mmu-mir-700.MI0004684 69.231 26 8 0 1 26 28 3 2.8 17.3 minus
  ````

  Note(s):
    - For this example, tabs ware replaced by simple white spaces

Output:
	A custom blastn output TAB separated file, with .EAcoordinates.tsv extension.
  This coordinates file contains extra columns for the common blastn format
	Example line(s):
	````
  qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand q5end_extension_length q3end_extension_length s5end_extension_length s3end_extension_length overlap5end_extension_length overlap3end_extension_length q5end_extension_start q5end_extension_end q3end_extension_start q3end_extension_end s5end_extension_start s5end_extension_end s3end_extension_start s3end_extension_end strand
  26 hsa-miR-1226-5p.MIMAT0005576 71 mmu-mir-6927.MI0022774 76.923 26 6 0 1 26 1 26 0.039 23.5 plus 0 0 0 45 0 0 1 1 26 26 1 1 26 26 +
  26 hsa-miR-4700-3p.MIMAT0019797 79 mmu-mir-700.MI0004684 69.231 26 8 0 1 26 28 3 2.8 17.3 minus 0 0 51 2 0 0 1 1 26 26 28 28 3 3 -
	````

  Output File Column Descriptions: see readme.txt in module mk-HSe-blastn for basic column description;
  new columns are described as follows:
  """"
  q5end_extension_length:
  q3end_extension_length:
  s5end_extension_length:
  s3end_extension_length:
  overlap5end_extension_length:
  overlap3end_extension_length:
  q5end_extension_start:
  q5end_extension_end:
  q3end_extension_start:
  q3end_extension_end:
  s5end_extension_start:
  s5end_extension_end:
  s3end_extension_start:
  s3end_extension_end:
  strand:
  """"

Module parameters:
  NONE

Testing the module:

1. Locally test this module by running

	````
	bash testmodule.sh
	````

2. "[>>>] Module Test Successful" should be printed in the console...
