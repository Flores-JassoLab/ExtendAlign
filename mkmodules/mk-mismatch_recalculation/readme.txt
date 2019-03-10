Module:	mk-mismatch_recalculation
Author(s): Israel Aguilar (iaguilaror@gmail.com)
Date: FEB 2019

TODO:
	NONE

Module description: add recalculated EApident (Extend Align percent identity) values to a custom EA blastn results table
  a. This module compares extended nucleotides beyond the vanilla blastn reported alignment coordinates.
  b. Recalculation is performed by positional comparison of corresponding extended nucleotides
  c. EApident is defined as the number of total MATCHES (taking into account extended align nucleotide comparison)
      ^^ in the Extended Alignment region (which is the original blastn alignment region + the nucleotides used to compare the 5'end and 3'end extensions)
      ^^ divided by the QUERY length

Module Dependencies:
	NONE

Input:
  A custom blastn output TAB separated file, with .extended_nucleotides.tsv extension
  Example line(s):
  ````
	qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand qseq sseq qmismatch_in_gap smismatch_in_gap query_mismatch subject_mismatch q5end_extension_length q3end_extension_length s5end_extension_length s3end_extension_length overlap5end_extension_length overlap3end_extension_length q5end_extension_start q5end_extension_end q3end_extension_start q3end_extension_end s5end_extension_start s5end_extension_end s3end_extension_start s3end_extension_end strand query_5end_extended_nt query_3end_extended_nt subject_5end_extended_nt subject_3end_extended_nt
  22 hsa-miR-642b-3p.MIMAT0018444 111 mmu-mir-6396.MI0021931 90.909 11 1 0 11 21 76 86 7.2 15.8 plus GGAGAGGGACC GGAGAGGTACC 0 0 1 1 10 1 75 25 10 1 1 11 21 22 66 76 86 87 + AGACACATTT C TATCCGGGCA A
  ````
  Note(s):
    - For this example, tabs ware replaced by simple white spaces
    - This type of file was created by the mk-bedtools_getfasta module

Output:
  A custom blastn output TAB separated file, with .recalculatedmm.tsv extension
  This recalculated mismatches file contains extra columns for the common blastn format and .extended_nucleotides.tsv format
  Example line(s):
  ````
  qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand q5end_extension_length q3end_extension_length s5end_extension_length s3end_extension_length overlap5end_extension_length overlap3end_extension_length q5end_extension_start q5end_extension_end q3end_extension_start q3end_extension_end s5end_extension_start s5end_extension_end s3end_extension_start s3end_extension_end strand query_5end_extended_nt query_3end_extended_nt subject_5end_extended_nt subject_3end_extended_nt extended_5end_mismatch extended_3end_mismatch total_mismatch extended_alignment_length extend_align_pident
  22 hsa-miR-642b-3p.MIMAT0018444 111 mmu-mir-6396.MI0021931 90.909 11 1 0 11 21 76 86 7.2 15.8 plus 10 1 75 25 10 1 1 11 21 22 66 76 86 87 + AGACACATTT C TATCCGGGCA A 9 1 11 22 50
  ````
  Note(s):
    - For this example, tabs ware replaced by simple white spaces
    - Do note the last 6 columns, with the extended alignment data

  Output File Column Descriptions: see readme.txt in module mk-bedtools_getfasta for previous column description;
  new columns are described as follows:
  """"
  extended_5end_mismatch: number of mismatches found when comparing, nt by nt, the strings in query_5end_extended_nt vs subject_5end_extended_nt
  extended_3end_mismatch: number of mismatches found when comparing, nt by nt, the strings in query_3end_extended_nt vs subject_3end_extended_nt
	query_overhang_5end_mismatch: number of nucleotides not used by the extension at the query 5'end overhang
	query_overhang_3end_mismatch: number of nucleotides not used by the extension at the query 3'end overhang
  total_mismatch: total mismatches in the extended alignment; calculated as the sum of values in columns extended_5end_mismatch + extended_3end_mismatch + query_mismatch + query_overhang_5end_mismatch + query_overhang_3end_mismatch
  extend_align_pident: recalculated percent identity when taking into account the total mismatch and QUERY length
  """"
  Note(s):
    - all of this columns should have integer values; no negative values should appear
    - extend_align_pident is in percentage format (i.e. 96.35 means 96.35 %); max value should be 100
    - in case of internal calculations, any of this columns will show the default value which is "ERR"

Module parameters:
  NONE

Testing the module:

1. Locally test this module by running
````

	bash testmodule.sh
	````

2. "[>>>] Module Test Successful" should be printed in the console...
