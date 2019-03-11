Module:	mk-recalculate_ngap
Author(s): Israel Aguilar (iaguilaror@gmail.com)
Date: FEB 2019

TODO:
	_(iaguilar)_ convert this file to markdown format

Module description: add number of mismatched nucleotides due to gaps introduced to query and subject sequences, respectively
  a. This module calculates the number of "-" characters in the blastn query sequence used for alignment
  b. It also calculates the number of "-" characters in the blastn subject sequence used for alignment
  c. Said values are used to cross define the number of mismatched nucleotides at query and subject

Module Dependencies:
	NONE

Input:
  A custom blastn output TAB separated file, with .blastn.tsv extension
  Example line(s):
  ````
	qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand qseq sseq
	26 hsa-miR-12128.MIMAT0049022 68 mmu-mir-6926.MI0022773 87.500 16 1 1 4 19 17 31 8.2 15.8 plus AGGGATGGCGCATGAA AGGGATGGTG-ATGAA
  ````

  Note(s):
    - For this example, tabs ware replaced by simple white spaces
		- This format is produced by the mk-HSe-blastn mkmodule

Output:
	A custom blastn output TAB separated file, with .EAcoordinates.tsv extension.
  This coordinates file contains extra columns for the common blastn format
	Example line(s):
	````
	qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand qseq sseq qmismatch_in_gap smismatch_in_gap query_mismatch subject_mismatch
	26 hsa-miR-12128.MIMAT0049022 68 mmu-mir-6926.MI0022773 87.500 16 1 1 4 19 17 31 8.2 15.8 plus AGGGATGGCGCATGAA AGGGATGGTG-ATGAA 1 0 2 1
	````
  Note(s):
    - For this example, tabs ware replaced by simple white spaces
		- DO note the fact that a gap "-" introduced at the SUBJECT sequence is counted as 1 qmismatch_in_gap;
		- In case the gap would span two nt "--", the number of mismatches in gaps (qmismatch_in_gap) would be reported as 2
		- Finally, the query_mismatch is 2 due to the original 1 mismtach reported by blastn + the qmismatch_in_gap calculated by EA

  Output File Column Descriptions: see readme.txt in module mk-HSe-blastn for basic column description;
  new columns are described as follows:
  """"
	qmismatch_in_gap: number of nucleotides in query skipped by the gapped regions of a blastn alginment. For EA downstream analysis, we consider this as mismatches specifically from the query point of view
	smismatch_in_gap: number of nucleotides in subject skipped by the gapped regions of a blastn alginment.
	query_mismatch: total number of blastn mismatches for query after taking into account the gap configuration in each alignment.
	subject_mismatch: total number of blastn mismatches for subject after taking into account the gap configuration in each alignment.
  """"

Module parameters:
  NONE

Testing the module:

1. Locally test this module by running

	````
	bash testmodule.sh
	````

2. "[>>>] Module Test Successful" should be printed in the console...
