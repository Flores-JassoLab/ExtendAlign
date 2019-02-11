Module:	mk-EA_report
Author(s): Israel Aguilar (iaguilaror@gmail.com), Mariana Flores (mflores@inmegen.edu.mx)
Date: FEB 2019

TODO:
	NONE

Module description: generate a summarized Extend Align results table for the user to see
  a. This module parses the complex EA ".with_nohits.tsv" with no hits table that contains every calculation performed by EA
  b. This module extracts only the columns that are ultimately informative to the user
  c. During this first versions, this sumarized report includes the original blastn only calculated pident, to make contrast with the Extend Align recalculated pident

Module Dependencies:
	NONE

Input:
  A custom blastn output TAB separated file, with .with_nohits.tsv extension
  Example line(s):
  ````
  qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand q5end_extension_length q3end_extension_length s5end_extension_length s3end_extension_length overlap5end_extension_length overlap3end_extension_length q5end_extension_start q5end_extension_end q3end_extension_start q3end_extension_end s5end_extension_start s5end_extension_end s3end_extension_start s3end_extension_end strand query_5end_extended_nt query_3end_extended_nt subject_5end_extended_nt subject_3end_extended_nt extended_5end_mismatch extended_3end_mismatch total_mismatch extended_alignment_length extend_align_pident
  22 hsa-miR-642b-3p.MIMAT0018444 111 mmu-mir-6396.MI0021931 90.909 11 1 0 11 21 76 86 7.2 15.8 plus 10 1 75 25 10 1 1 11 21 22 66 76 86 87 + AGACACATTT C TATCCGGGCA A 9 1 11 22 50
  . hsa-miR-8083.MIMAT0031010 . NO_HIT . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
  ````
  Note(s):
    - For this example, tabs ware replaced by simple white spaces
    - Do note the difference between the "hsa-miR-642b-3p.MIMAT0018444" hit, and the "hsa-miR-8083.MIMAT0031010" NO_HIT line

  Output File Column Descriptions: see readme.txt in module mk-append_nohits

Output:
  An EA analysis summary tab separated file
  Example line(s):
  ````
  query_name subject_name query_length EA_alignment_length EA_total_mismatch EA_total_match EA_pident blastn_pident
  hsa-miR-1226-5p.MIMAT0005576 mmu-mir-6927.MI0022774 26 26 6 20 76.9231 76.923
  hsa-miR-8083.MIMAT0031010 NO_HIT . . . 0 . .
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
