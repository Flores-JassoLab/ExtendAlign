Module:	mk-EA_report
Author(s): Israel Aguilar (iaguilaror@gmail.com), Mariana Flores (mflores@inmegen.edu.mx)
Date: FEB 2019

TODO:
	NONE

Module description: generate a summarized Extend Align results table for the user to see
  a. This module parses the complex EA ".with_nohits.tsv" with no hits table that contains every calculation performed by EA
  b. This module extracts only the columns that are ultimately informative to the user
  c. The summarized report includes the original blastn calculated pident, to make contrast with the Extend Align recalculated pident

Module Dependencies:
	NONE

Input:
  A custom blastn output TAB separated file, with .with_nohits.tsv extension
  Example line(s):
	````
	qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand qseq sseq qmismatch_in_gap smismatch_in_gap query_mismatch subject_mismatch q5end_extension_length q3end_extension_length s5end_extension_length s3end_extension_length overlap5end_extension_length overlap3end_extension_length q5end_extension_start q5end_extension_end q3end_extension_start q3end_extension_end s5end_extension_start s5end_extension_end s3end_extension_start s3end_extension_end strand query_5end_extended_nt query_3end_extended_nt subject_5end_extended_nt subject_3end_extended_nt extended_5end_mismatch extended_3end_mismatch query_overhang_5end_mismatch query_overhang_3end_mismatch total_mismatch extend_align_pident
	26 hsa-miR-1226-5p.MIMAT0005576 71 mmu-mir-6927.MI0022774 76.923 26 6 0 1 26 1 26 0.039 23.5 plus GTGAGGGCATGCAGGCCTGGATGGGG GTGAGGGGATCCAGCCCAGGCTAGGG 0 0 6 6 0 0 0 45 0 0 1 1 26 26 1 1 26 26 + . . . . 0 0 0 0 6 76.9231
	. hsa-miR-8083.MIMAT0031010 . NO_HIT . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
	````
	Note(s):
		- For this example, tabs ware replaced by simple white spaces
		- Do note the difference between the "hsa-miR-1226-5p.MIMAT0005576" hit, and the "hsa-miR-8083.MIMAT0031010" NO_HIT line

  Output File Column Descriptions: see readme.txt in module mk-append_nohits

Output:
  An EA analysis summary tab separated file
  Example line(s):
  ````

  ````
  Note(s):
    - For this example, tabs ware replaced by simple white spaces
    - Do note the difference between the "hsa-miR-1226-5p.MIMAT0005576" hit, and the "hsa-miR-8083.MIMAT0031010" NO_HIT line

  Output File Column Descriptions:

  """"
  query_name: Name or ID of the sequence used as query for alignment
  subject_name: Name or ID of the sequence where a hit was found
  query_length: Length of the query
  EA_alignment_length: Number of query nucleotides included in the extended alignment
  EA_total_mismatch: Number of mismatches found in the extended alignment
  EA_total_match: Number of matches found in the extended alignment
  EA_pident: Extend Align recalculated percent identity
  blastn_pident: Original blastn percent identity
  """"

Module parameters:
  NONE

Testing the module:

1. Locally test this module by running
````

	bash testmodule.sh
	````

2. "[>>>] Module Test Successful" should be printed in the console...
