# mk-get_EA_coordinates  
**Author(s):** Mariana Flores-Torres (mariana.flo.tor@gmail.com), Israel Aguilar-Ordoñez (iaguilaror@gmail.com)  
**Date:** February-2019  

---

## TODO:
NONE

---

## Module description:
Add sequence coordinates to the ExtendAlign `HSe-blastn` results table to indicate where nucleotides should be extracted from for downstream bulk fasta extraction.  

1. This module calculates the length of extendable nucleotides at the 5'-end and 3'-end, of query and subjects.
2. It takes into account the factors that affect a correct comparison of nucleotides, such as:  
   i. Query and subject length.  

   ii. Differential overhanging - or cases where query's unaligned overhangs are longer than subject's unaligned overhangs, and vice versa thus, this module includes a failsafe to not extend more nucleotides than can be evenly compared between query and subject extension (*i.e.* if at 5'-end, query can be extended 5 nt, but subject can only be extended 3 nt, coordinates will be adjusted to only span 3 nt extensions for both, query and subject).  

   iii. Strandness - in cases where the ExtendAlign `HSe-blastn` hit was reported as a hit in the minus strand of the subject (this requires mirrored operations of the sequence coordinates) *e.g.* the subject 5'-end extendable coordinates for a **minus** hit are extracted from the 3'-end portion of the original subject sequence.

3. Using all of the data above, this module adds sequence coordinates to indicate where to perform nucleotide extraction to enable a downstream finer match/mismatch count in cases where alignments can be extended.
4. **IMPORTANT!!:** This module does not perform the fasta extraction, or the extended match/mismatch recount. Leave that to other mkmodules.

---

## Module Dependencies:
NONE

---

### Input:
ExtendAlign `HSe-blastn` output TAB separated file, with `.EAblastn.tsv` or `.EAblastnbesthit.tsv` extension.  

Example line(s):
```
qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand qseq sseq qmismatch_in_gap smismatch_in_gap query_mismatch subject_mismatch
26 hsa-miR-1226-5p.MIMAT0005576 71 mmu-mir-6927.MI0022774 76.923 26 6 0 1 26 1 26 0.039 23.5 plus GTGAGGGCATGCAGGCCTGGATGGGG GTGAGGGGATCCAGCCCAGGCTAGGG 0 0 6 6
26 hsa-miR-4700-3p.MIMAT0019797 79 mmu-mir-700.MI0004684 69.231 26 8 0 1 26 28 3 2.8 17.3 minus CACAGGACTGACTCCTCACCCCAGTG CACAGGAAGGAGCCTTACTCCCAGTG 0 0 8 8
```

**Note(s):**  
* For this example, TABs were replaced by white spaces.  

---

### Output:
ExtendAlign `HSe-blastn` output TAB separated file, with `.EAcoordinates.tsv` extension.  
This coordinates file contains extra columns for the common blastn format.  

Example line(s):
```
qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand qseq sseq qmismatch_in_gap smismatch_in_gap query_mismatch subject_mismatch q5end_extension_length q3end_extension_length s5end_extension_length s3end_extension_length overlap5end_extension_length overlap3end_extension_length q5end_extension_start q5end_extension_end q3end_extension_start q3end_extension_end s5end_extension_start s5end_extension_end s3end_extension_start s3end_extension_end strand
26 hsa-miR-1226-5p.MIMAT0005576 71 mmu-mir-6927.MI0022774 76.923 26 6 0 1 26 1 26 0.039 23.5 plus GTGAGGGCATGCAGGCCTGGATGGGG GTGAGGGGATCCAGCCCAGGCTAGGG 0 0 6 6 0 0 0 45 0 0 1 1 26 26 1 1 26 26 +
26 hsa-miR-4700-3p.MIMAT0019797 79 mmu-mir-700.MI0004684 69.231 26 8 0 1 26 28 3 2.8 17.3 minus CACAGGACTGACTCCTCACCCCAGTG CACAGGAAGGAGCCTTACTCCCAGTG 0 0 8 8 0 0 51 2 0 0 1 1 26 26 28 28 3 3 -
```

**Note(s):**

* For this example, TABs were replaced by white spaces.  

Output File Column Descriptions: see readme.md in module `mk-HSe-blastn` for basic column description; new columns are described as follows:  

`q5end_extension_length:` For query, number of nucleotides at 5'-end that were not included in the `HSe-blastn` reported alignment.  
`q3end_extension_length:` For query, number of nucleotides at 3'-end that were not included in the `HSe-blastn` reported alignment.  
`s5end_extension_length:` For subject, number of nucleotides at 5'-end that were not included in the `HSe-blastn` reported alignment.  
`s3end_extension_length:` For subject, number of nucleotides at 3'-end that were not included in the `HSe-blastn` reported alignment.  
`overlap5end_extension_length:` For 5'-end, maximum number of extension length shared by query and subject; *e.g.* query 5'-end length is 7 nt, subject 5'-end is 3 nt, thus, the `overlap5end_extension_length` is the minimal value of those two, which is 3 nt.  
`overlap3end_extension_length:` For 3'-end, maximum number of extension length shared by query and subject; *e.g.* query 3'-end length is 0 nt, subject 3'-end is 9 nt, thus, the `overlap5end_extension_length` is the minimal value of those two, which is 0 nt.  
`q5end_extension_start:` For query 5'-end, sequence position where the nucleotides should begin to be extracted from the query fasta.  
`q5end_extension_end:` For query 5'-end, sequence position where the nucleotides should finish to be extracted.  
`q3end_extension_start:` For query 3'-end, sequence position where the nucleotides should begin to be extracted.  
`s5end_extension_start:` For subject 5'-end, sequence position where the nucleotides should begin to be extracted from the query fasta.  
`q3end_extension_end:` For query 3'-end, sequence position where the nucleotides should finish to be extracted.  
`s5end_extension_end:` For subject 5'-end, sequence position where the nucleotides should finish to be extracted.  
`s3end_extension_start:` For subject 3'-end, sequence position where the nucleotides should begin to be extracted.  
`s3end_extension_end:` For subject 3'-end, sequence position where the nucleotides should finish to be extracted.  
`strand:` + or - code for the `HSe-blastn` result strandness (will be required in +/- format by downstream process).  

---

## Module parameters:
NONE

---

## Testing the module:
1. Test this module locally by running,
```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...

