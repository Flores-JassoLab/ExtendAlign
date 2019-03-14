# mk-create_EAfasta  
**Author(s):** Israel Aguilar-Ordoñez (iaguilaror@gmail.com)  
**Date:** February-2019  

---

## TODO:
  ( *iaguilar* ) Test if this module works with whole genome fasta files or with fasta file with big contigs.

---

## Module Description:
Transformation of a fasta file into an ExtendAlign fasta file (`.EAfa`).  

1. This module takes a fasta file and adds the sequence length value to the sequence header.  
2. The sequence length value attached to the sequence header is needed for downstream quick decision making, in particular, to determine how many nucleotides is it possible to extend a blastn hit.  
3. For ExtendAlign, both query and subject fasta files need to be transformed into `.EAfa` format.  
4. This module saves up execution time, since sequence length is determined only once per sequence, instead of every time it shows up in downstream blastn results.  

---

## Module Dependencies:
  Already included as an executable in this module; NO INSTALLATION needed:
  [Seqkit v0.10.0](https://github.com/shenwei356/seqkit) (W Shen, S Le, Y Li*, F Hu*. SeqKit: a cross-platform and ultrafast toolkit for FASTA/Q file manipulation. PLOS ONE. doi:10.1371/journal.pone.0163962).

---

### Input:
A fasta file with `.fa`, `.fna` or `.fasta` extension.  

Example line(s):
```
>hsa-let-7a-5p.MIMAT0000062
UGAGGUAGUAGGUUGUAUAGUU
```

---

### Output:
An ExtendAlign fasta file with `.EAfa` extension.  

Example line(s):
```
>22{EA}hsa-let-7a-5p.MIMAT0000062
UGAGGUAGUAGGUUGUAUAGUU
```

**Note(s):**  
* The string `{EA}` is a custom separator to allow downstream splitting of the sequence length value (left side from `{EA}`) from the original sequence header (right side from `{EA}`).    
* It is most likely that no contig name or seqID from a common fasta file would include this string of characters; so we can use it safely as separator.  

---

## Module Parameters:
NONE  

---

## Testing the module:
1. Test this module locally by running,
```
bash testmodule.sh
```

2. "[>>>] Module Test Successful" should be printed in the console...
