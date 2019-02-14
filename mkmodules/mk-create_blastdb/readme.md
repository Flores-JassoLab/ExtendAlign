# mk-create_blastdb

**Author(s):** Mariana Flores-Torres (mariana.flo.tor@gmail.com), Israel Aguilar-Ordoñez (iaguilaror@gmail.com)
**Date:** February-2019

## To-do:
  NONE

## Module Description:
  Creates a blastn database from an ExtendAlign fasta file (`.EAfa`)

1. This module runs blastn `makeblastdb` to build database files.

## Module Dependencies:
  NCBI Makeblastdb for [BLAST 2.8.1+](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download) (Camacho, Christiam, et al. "BLAST+: architecture and applications." BMC bioinformatics 10.1 (2009): 421).

### Input:
  A fasta file with `.EAfa` extension.

Example line(s):
```
>22{EA}hsa-let-7a-5p.MIMAT0000062
UGAGGUAGUAGGUUGUAUAGUU
```

### Output:
  A battery of files for the blast nucleotide database.

Example file name(s):
```
fasta_file.EAfa.nin
fasta_file.EAfa.nsd
fasta_file.EAfa.nsq
fasta_file.EAfa.nhr
fasta_file.EAfa.nog
fasta_file.EAfa.nsi
```

## Module Parameters:
  NONE

## Testing the module:

1. Test this module locally by running,
```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...

