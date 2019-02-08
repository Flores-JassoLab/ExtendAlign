Module:	mk-get_best_hit
Author(s): Mariana Flores (mflores@inmegen.edu.mx), Joshua Haase (jihaase@inmegen.gob.mx ), Israel Aguilar (iaguilaror@gmail.com)
Date: FEB 2019

TODO:
	NONE

Module description: Extract the best hit for every query in a EA blastn results file
  a. An EA blastn results file has a LOT of hits per query, sometimes you want to find only the best hit
	b. The best hit definition is: the blastn alignment withe the longest alignment length but the lowest number of mismatches and gaps reported
  c. This module uses a simple strategy to finde best hits: 1. sort by alignment length, mismatches and gaps, accordingly; 2. then print a line each time a query ID appears for the first time in the sorted results.
  d. In practice, at the end we have one blastn result per query; said line reports the the longest alignment with the least number of mismatches and gaps

Module Dependencies:
	NONE

Input:
  A custom blastn output TAB separated file, with .blastn.tsv extension
  Example line(s):
  ````
  qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand
  22 hsa-let-7a-5p.MIMAT0000062 96 mmu-let-7a-2.MI0000557 100.000 22 0 1 1 22 17 38 6.54e-06 35.9 plus
  22 hsa-let-7a-5p.MIMAT0000062 94 mmu-let-7a-1.MI0000556 100.000 22 0 0 1 22 13 34 6.54e-06 35.9 plus
  22 hsa-let-7a-5p.MIMAT0000062 94 mmu-let-7a-1.MI0000556 93.750 16  1 0 7 22 77 62 0.034    23.5 minus
  ````

  Note(s):
    - For this example, some tabs ware replaced by simple white spaces
    - 3 blastn hits for the same query ID (hsa-let-7a-5p.MIMAT0000062) are shown

Output:
	A custom blastn output TAB separated file, with .blastnbesthit.tsv extension.
  This besthit file contains one hit per query ID
	Example line(s):
	````
  qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand
  22 hsa-let-7a-5p.MIMAT0000062 94 mmu-let-7a-1.MI0000556 100.000 22 0 0 1 22 13 34 6.54e-06 35.9 plus
	````
	Note(s):
	- Only one best hit was kept, since it has an alignment length of 22, 0 mismatches, and 0 gaps.
  - Closest hit had an alignment length of 22, 0 mismatches, and 1 gap, thus it was filtered out.

  Output File Column Descriptions: see readme.txt in module mk-HSe-blastn; columns remain the same.

Module parameters:
  NONE

Testing the module:

1. Locally test this module by running

	````
	bash testmodule.sh
	````

2. "[>>>] Module Test Successful" should be printed in the console...
