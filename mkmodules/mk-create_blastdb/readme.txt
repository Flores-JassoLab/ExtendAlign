Module:	mk-create_blastdb
Author(s): Mariana Flores (mflores@inmegen.edu.mx), Israel Aguilar (iaguilaror@gmail.com)
Date: FEB 2019

TODO:
	NONE

Module description: Creates a blast Database from an EA fasta file (.EAfa)
	a. This module runs blast makeblastdb to build database files

Module Dependencies:
	makeblastdb from ncbi BLAST 2.8.1+ - https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download

	Citations:
	Camacho, Christiam, et al. "BLAST+: architecture and applications." BMC bioinformatics 10.1 (2009): 421.

Input:
	A fasta file with .EAfa extension
  Example line(s):
	````
	>22{EA}hsa-let-7a-5p.MIMAT0000062
	UGAGGUAGUAGGUUGUAUAGUU
	````

Output:
  A battery of files for the blast nucleotide database
	Example file name(s):
	````
  fasta_file.EAfa.nin
  fasta_file.EAfa.nsd
  fasta_file.EAfa.nsq
  fasta_file.EAfa.nhr
  fasta_file.EAfa.nog
  fasta_file.EAfa.nsi
	````

Module parameters:
	NONE

Testing the module:

1. Locally test this module by running

	````
	bash testmodule.sh
	````

2. "[>>>] Module Test Successful" should be printed in the console...
