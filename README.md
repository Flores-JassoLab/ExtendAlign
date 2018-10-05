ExtendAlign
===============

A computational algorithm to correct the match/mismatch bias
reported on end-to-end alignments of short sequences

Usage
=====

Place your sequences to be aligned (query) in fasta format into the `data/query` directory
Place your sequences to be used as reference (subject) in fasta format into the `data/subject` directory
and execute:

```
export PATH=$PATH:$(pwd)/bin
targets | xargs mk
```

Your results will be on `reports/` when the process ends.

The reports consist on a table containing the following information,
separated by tabs:

```
query_name, subj_name, query_length, complete_query_seq, complete_subj_seq, total_match, total_mismatch
```

The process is quite slow, so `split` the files before using.

Options
=======

`NPROC` environment variable can be specified to run multiple processes simultaneously.

```
targets | xargs env NPROC=$(grep proc /proc/cpuinfo | wc -l ) mk
```

Design considerations
=====================


Algorithm
=========


Requirements
============

  - [`coreutils`](https://www.gnu.org/software/coreutils/coreutils.html "Basic file, shell and text manipulation utilities of the GNU operating system.")

  - [`findutils`](https://www.gnu.org/software/findutils/ "Basic directory searching utilities of the GNU operating system.")

  - [`mk`](http://doc.cat-v.org/bell_labs/mk/mk.pdf "A successor for `make`.")

  - [`blast`](ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ "Basic Local Alignment Search Tool.")

  - [`samtools`](http://www.htslib.org/download/ "Utilities for interacting with and post-processing short DNA sequence read alignments")

  - [`execline`](http://www.skarnet.org/software/execline/ "execline is a (non-interactive) scripting language")


References
==========

Please cite as «Flores-Torres et al. (2018) ExtendAlign: a computational algorithm to correct the match/mismatch bias reported on end-to-end alignments of short sequences».

```

```
