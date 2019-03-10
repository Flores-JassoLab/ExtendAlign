Module:	mk-get_best_hit
Author(s): Mariana Flores (mflores@inmegen.edu.mx), Joshua Haase (jihaase@inmegen.gob.mx ), Israel Aguilar (iaguilaror@gmail.com)
Date: FEB 2019

TODO:
	NONE

Module description: Extract the best hit for every query in a EA blastn results file
  a. An EA blastn results file has a LOT of hits per query, sometimes you want to find only the best hit
	b. The best hit definition for EA is query focused: the blastn alignment with the longest alignment length but the lowest number of query mismatches (this means that gaps introduced in the subject sequence are counted as query mismatches)
  c. This module uses a simple strategy to finde best hits: 1. sort by alignment length, and query mismatches, accordingly; 2. then print a line each time a query ID appears for the first time in the sorted results.
  d. In practice, at the end we have one blastn result per query; said line reports the the longest alignment with the least number of mismatches from a query point of view

Module Dependencies:
	NONE

Input:
  A custom blastn output TAB separated file, with .EAblastn.tsv extension
  Example line(s):
  ````
	qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand qseq sseq qngap sngap query_mismatch subject_mismatch
	26 hsa-miR-12128.MIMAT0049022 107 mmu-mir-767.MI0012530 82.353 17 3 0 8 24 73 89 0.97 18.9 plus ATGGCGCATGAAGAGGA ATGGTTCCTGAAGAGGA 0 0 3 3
	26 hsa-miR-12128.MIMAT0049022 75 mmu-mir-343.MI0005494 88.235 17 1 1 10 26 61 46 2.8 17.3 minus GGCGCATGAAGAGGAGA GGCACATGAAG-GGAGA 1 0 2 1
	26 hsa-miR-12128.MIMAT0049022 95 mmu-mir-221.MI0000709 82.353 17 3 0 3 19 4 20 0.97 18.9 plus CAGGGATGGCGCATGAA CAGGTCTGGGGCATGAA 0 0 3 3
  ````

  Note(s):
    - For this example, some tabs ware replaced by simple white spaces
    - 3 blastn hits for the same query ID (hsa-miR-12128.MIMAT0049022) are shown

Output:
	A custom blastn output TAB separated file, with .EAblastnbesthit.tsv extension.
  This besthit file contains one hit per query ID
	Example line(s):
	````
	qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand qseq sseq qngap sngap query_mismatch subject_mismatch
	26 hsa-miR-12128.MIMAT0049022 75 mmu-mir-343.MI0005494 88.235 17 1 1 10 26 61 46 2.8 17.3 minus GGCGCATGAAGAGGAGA GGCACATGAAG-GGAGA 1 0 2 1
	````
	Note(s):
	- Only one best hit was kept, since it has an alignment length of 17, and 2 query mismatches.
  - Closest hit had an alignment length of 17, and 3 query mismatches, thus it was filtered out.

  Output File Column Descriptions: see readme.txt in module mk-HSe-blastn; columns remain the same.

Module parameters:
  NONE

Testing the module:

1. Locally test this module by running

	````
	bash testmodule.sh
	````

2. "[>>>] Module Test Successful" should be printed in the console...
