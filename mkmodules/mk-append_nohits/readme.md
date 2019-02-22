# mk-append_nohits
**Author(s):** Israel Aguilar-Ordoñez (iaguilaror@gmail.com)
**Date:** February-2019

## To-do:
NONE

## Module Description:
Add rows with information for querys that had no hit in ExtendAlign `HSe-blastn`.

1. This module compares query IDs between the previous ExtendAlign `HSe-blastn` results table and the input query ExtendAlign fasta file.
2. By comparing this data, we can determine which ExtendAlign fasta query IDs are missing from the ExtendAlign `HSe-blastn` results table.
3. A dummy results table is created for the missing query IDs.
4. For every missing query ID, a row is created with the `NO_HIT` legend in the subject ID column and `.` values in other columns.
5. **IMPORTANT!!** Values for the missing queries are declared explicitly in the mkfile recipe `%.nohit_results.tmp`. This means that if the number and/or order of the columns in the input `*.recalculatedmm.tsv` format is changed, the script `%.nohit_results.tmp` recipe in this module must be adjusted.

## Module Dependencies:
NONE

### Input:
    a. A fasta file with `.EAfa` extension.

Example line(s):
```
>22{EA}hsa-let-7a-5p.MIMAT0000062
UGAGGUAGUAGGUUGUAUAGUU
```

**Note(s):**
* The `NUMBER{EA}` string of characters at the start of the fasta header, is a custom string added by a previous EA module (`mk-create_EAfasta`).

    b. ExtendAlign `HSe-blastn` output TAB separated file, with `.recalculatedmm.tsv` extension, see readme.txt at `mk-mismatch_recalculation` module for column description.

Example line(s):
```
qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand q5end_extension_length q3end_extension_length s5end_extension_length s3end_extension_length overlap5end_extension_length overlap3end_extension_length q5end_extension_start q5end_extension_end q3end_extension_start q3end_extension_end s5end_extension_start s5end_extension_end s3end_extension_start s3end_extension_end strand query_5end_extended_nt query_3end_extended_nt subject_5end_extended_nt subject_3end_extended_nt extended_5end_mismatch extended_3end_mismatch total_mismatch extended_alignment_length extend_align_pident
22 hsa-miR-642b-3p.MIMAT0018444 111 mmu-mir-6396.MI0021931 90.909 11 1 0 11 21 76 86 7.2 15.8 plus 10 1 75 25 10 1 1 11 21 22 66 76 86 87 + AGACACATTT C TATCCGGGCA A 9 1 11 22 50
```

**Note(s):**
* For this example, TABs were replaced by simple white spaces.
* This type of file is created by the `mk-mismatch_recalculation` module.

### Output:
ExtendAlign `HSe-blastn` output TAB separated file, with `.with_nohits.tsv` extension.
This results file includes the extra rows for queries with no ExtendAlign `HSe-blastn` hits.

Example line(s):
```
qlength qseqid slength sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore sstrand q5end_extension_length q3end_extension_length s5end_extension_length s3end_extension_length overlap5end_extension_length overlap3end_extension_length q5end_extension_start q5end_extension_end q3end_extension_start q3end_extension_end s5end_extension_start s5end_extension_end s3end_extension_start s3end_extension_end strand query_5end_extended_nt query_3end_extended_nt subject_5end_extended_nt subject_3end_extended_nt extended_5end_mismatch extended_3end_mismatch total_mismatch extended_alignment_length extend_align_pident
22 hsa-miR-642b-3p.MIMAT0018444 111 mmu-mir-6396.MI0021931 90.909 11 1 0 11 21 76 86 7.2 15.8 plus 10 1 75 25 10 1 1 11 21 22 66 76 86 87 + AGACACATTT C TATCCGGGCA A 9 1 11 22 50
  . hsa-miR-8083.MIMAT0031010 . NO_HIT . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
```

**Note(s):**
* For this example, TABs were replaced by simple white spaces.
* Do note the difference between the **hsa-miR-642b-3p.MIMAT0018444** hit, and the **hsa-miR-8083.MIMAT0031010** `NO_HIT` line.

Output File Column Descriptions: see readme.txt in module `mk-mismatch_recalculation`.

## Module Parameters:
NONE

## Testing the module:

1. Test this module locally by running,
```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...


