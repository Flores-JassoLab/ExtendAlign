# mk-mismatch_recalculation
**Author(s):** Israel Aguilar-Ordoñez (iaguilaror@gmail.com)
**Date:** February-2019

## TODO:
NONE

## Module description:
Add recalculated ExtendAlign percent identity (`EApident`) values to ExtendAlign `HSe-blastn` results table.

1. This module compares extended nucleotides beyond the `HSe-blastn` reported alignment coordinates.

2. Mismatch recalculation is performed by positional comparison of corresponding extended nucleotides.

3. `EApident` is defined as the number of total **matches** (taking into account ExtendedAlign nucleotide comparison) in the ExtendAlign region
(which corresponds to the `HSe-blastn` alignment region + the nucleotides used to compare the 5'end and 3'end extensions) divided by the QUERY length.

## Module Dependencies:
NONE

### Input:
A `HSe-blastn` output TAB separated file, with `.extended_nucleotides.tsv` extension.

Example line(s):
```
qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand qseq sseq qmismatch_in_gap smismatch_in_gap query_mismatch subject_mismatch q5end_extension_length q3end_extension_length s5end_extension_length s3end_extension_length overlap5end_extension_length overlap3end_extension_length q5end_extension_start q5end_extension_end q3end_extension_start q3end_extension_end s5end_extension_start s5end_extension_end s3end_extension_start s3end_extension_end strand query_5end_extended_nt query_3end_extended_nt subject_5end_extended_nt subject_3end_extended_nt
22 hsa-miR-642b-3p.MIMAT0018444 111 mmu-mir-6396.MI0021931 90.909 11 1 0 11 21 76 86 7.2 15.8 plus GGAGAGGGACC GGAGAGGTACC 0 0 1 1 10 1 75 25 10 1 1 11 21 22 66 76 86 87 + AGACACATTT C TATCCGGGCA A
```

**Note(s):**
* For this example, TABs were replaced by white spaces.
* This type of file was created by the `mk-bedtools_getfasta` module.

### Output:
ExtendAlign `HSe-blastn` output TAB separated file, with `.recalculatedmm.tsv` extension.
This recalculated mismatches file contains extra columns for the common `HSe-blastn` format and `.extended_nucleotides.tsv` format.

Example line(s):
```
qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand q5end_extension_length q3end_extension_length s5end_extension_length s3end_extension_length overlap5end_extension_length overlap3end_extension_length q5end_extension_start q5end_extension_end q3end_extension_start q3end_extension_end s5end_extension_start s5end_extension_end s3end_extension_start s3end_extension_end strand query_5end_extended_nt query_3end_extended_nt subject_5end_extended_nt subject_3end_extended_nt extended_5end_mismatch extended_3end_mismatch total_mismatch extended_alignment_length extend_align_pident
22 hsa-miR-642b-3p.MIMAT0018444 111 mmu-mir-6396.MI0021931 90.909 11 1 0 11 21 76 86 7.2 15.8 plus 10 1 75 25 10 1 1 11 21 22 66 76 86 87 + AGACACATTT C TATCCGGGCA A 9 1 11 22 50
```

**Note(s):**
* For this example, TABs were replaced by white spaces.
* Do note the addition of the last 6 columns in the output file, with the extended alignment data.

Output File Column Descriptions: see readme.md in module `mk-bedtools_getfasta` for previous column description.

New columns are described as follows:

`extended_5end_mismatch`: Number of mismatches found when comparing, nucleotide by nucleotide, the strings in `query_5end_extended_nt` vs `subject_5end_extended_nt`.
`extended_3end_mismatch`: Number of mismatches found when comparing, nucleotide by nucleotide, the strings in `query_3end_extended_nt` vs `subject_3end_extended_nt`.
`query_overhang_5end_mismatch`: Number of nucleotides not used by the extension at the query 5'end overhang.
`query_overhang_3end_mismatch`: Number of nucleotides not used by the extension at the query 3'end overhang.
`total_mismatch`: Total mismatches in the extended alignment; calculated as the sum of values in columns `extended_5end_mismatch` + `extended_3end_mismatch` + `query_mismatch` + `query_overhang_5end_mismatch` + `query_overhang_3end_mismatch`.
`extend_align_pident`: Recalculated percent identity when taking into account the total mismatch and query length.

**Note(s):**
* All of this columns should have integer values; no negative values should appear.
* `EApident` is in percentage format (*i.e.* 96.35 means 96.35 %); max value should be 100.
* In case of errors during internal calculations, any of this columns will show the default value which is `ERR`.

## Module parameters:
NONE

## Testing the module:

1. Test this module locally by running,
```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...

