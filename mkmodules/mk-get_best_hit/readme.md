# mk-get_best_hit
**Author(s):** Mariana Flores-Torres (mariana.flo.tor@gmail.com), Joshua I. Haase-Hernandez (jihaase@inmegen.gob.mx ), Israel Aguilar-Ordoñez (iaguilaror@gmail.com)
**Date:** February-2019

## TODO:
NONE

## Module Description:
Extract the best hit for every query in a ExtendAlign `HSe-blastn` results file.

1. An ExtendAlign `HSe-blastn` results file may have a LOT of hits per query, sometimes you want to find only the **best hit**.
2. The **best hit** definition is: the `HSe-blastn` alignment with the longest alignment length but the lowest number of mismatches and gaps reported.
3. This module uses a simple strategy to find the best hits:
     i. Sort by alignment length, mismatches and gaps.
     ii.Print a line each time a query ID appears for the first time in the sorted results.
4. In practice, at the end we have one `HSe-blastn` result per query; ExtendAlign reports the longest alignment with the least number of mismatches and gaps.

## Module Dependencies:
NONE

###Input:
A custom `HSe-blastn` output TAB separated file, with `.blastn.tsv` extension.

Example line(s):

```
qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand
22 hsa-let-7a-5p.MIMAT0000062 96 mmu-let-7a-2.MI0000557 100.000 22 0 1 1 22 17 38 6.54e-06 35.9 plus
22 hsa-let-7a-5p.MIMAT0000062 94 mmu-let-7a-1.MI0000556 100.000 22 0 0 1 22 13 34 6.54e-06 35.9 plus
22 hsa-let-7a-5p.MIMAT0000062 94 mmu-let-7a-1.MI0000556 93.750 16  1 0 7 22 77 62 0.034    23.5 minus
```

**Note(s):**
* For this example, some TABs were replaced by simple white spaces.
* Three-`HSe-blastn` hits for the same query ID (hsa-let-7a-5p.MIMAT0000062) are shown.

### Output:
A custom `HSe-blastn` output TAB separated file, with `.blastnbesthit.tsv` extension.
This **best hit** file contains one hit per query ID.

Example line(s):

```
qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand
22 hsa-let-7a-5p.MIMAT0000062 94 mmu-let-7a-1.MI0000556 100.000 22 0 0 1 22 13 34 6.54e-06 35.9 plus
```

**Note(s):**
* Only one **best hit** was kept, since it has an alignment length = 22, mismatches = 0, and gaps = 0.
* The closest hit had an alignment length = 22, mismatches = 0, and gap = 1, thus it was filtered out.

For Output File Column Descriptions: see readme.txt in module `mk-HSe-blastn`; columns remain the same.

## Module Parameters:
NONE

## Testing the module:

1. Test this module locally by running,

```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...
