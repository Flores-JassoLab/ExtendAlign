Module:	mk-create_EAfasta
Author(s): Israel Aguilar (iaguilaror@gmail.com)
Date: FEB 2019

TODO:
	(iaguilar) Test if this module works in whole genome fasta files, or in a fasta with big contigs

Module description: transform a fasta file into .EAfa (fasta for extend align)
	a. This module takes a fasta file, and adds the sequence length to the sequence name.
	b. Sequence length in the sequence name is needed for downstream quick decision making, particularly, how many nt is it possible to extend a blast hit
	c. For Extend Alignment, both the query and subject fasta files need to be transformed into .EAfa format
	d. This module saves up execution time, since sequence length is calculated only once per seq, instead of every time it shows up in downstream blastn results

Module Dependencies:
	seqkit - https://github.com/shenwei356/seqkit

	Citations:
	W Shen, S Le, Y Li*, F Hu*. SeqKit: a cross-platform and ultrafast toolkit for FASTA/Q file manipulation. PLOS ONE. doi:10.1371/journal.pone.0163962.

Input:
	A fasta file with .fa, .fna or .fasta extension
	Example line(s):
	````
	>hsa-let-7a-5p.MIMAT0000062
	UGAGGUAGUAGGUUGUAUAGUU
	````

Output:
	An Extend Align fasta file with .EAfa extension
	Example line(s):
	````
	>22{EA}hsa-let-7a-5p.MIMAT0000062
	UGAGGUAGUAGGUUGUAUAGUU
	````
	Note(s):
	- The "{EA}" string of characters is a custom separator to allow for downstream splitting of sequence length (left from "{EA}") and original sequence ID (right from "{EA}")
	- I think no contig name or seqID from a common fasta file will include said string of characters; so we can use it safely as separator


Module parameters:
	NONE

Testing the module:

1. Locally test this module by running

	````
	bash testmodule.sh
	````

2. "[>>>] Module Test Successful" should be printed in the console...
