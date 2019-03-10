#!/bin/bash

###
# Author: Israel Aguilar (iaguilaror@gmail.com)
###
# SCRIPT OBJECTIVES
#		1. Defining the bed coordinates for fasta nt extension in a EA blastn results table
#		2. First, the number of nt to extend at Query 5' end, Query 3' end are calculated
#		3. Then, the number of nt to extend at Subject 5' end, Subject 3' end are calculated
#		4. Taken strand into account, when subject strand was reported as minus by EA blastn, Query 5'end values will be compared with Subject 3'end values; same goes for Query 3'end vs Subject 5'end values
#		5. When comparing, lets say, assuming a plus strand blasn hit, q5end vs s5end, the lowest 5end nt length between the two will define the overlapping extension length to extract
#		6. Once overlapping extension length is defined for both 'ends, bed coordinates will be defined by adding or substracting the overlapping extension length, depending on the 'end orientation and strandness of the hit
#		7. In the end, this script only adds sequence cordinates for the following module to extract nucleotides from contigs via a bed to fasta convertion tool (as of this version: bedtools)

## Read input file from first parameter passed to this script
INPUT_FILE="$1"

## Using awk, the following operations will be performed in blocks
#	1. Define query 5' end extension length (that is, the number of upstream Query nucleotides not included in the alignment hit)
# 2. Define query 3' end extension length (that is, the number of downstream Query nucleotides not included in the alignment hit)
# Then, taking strandness into account (this means, if blastn sstrand value is "minus", then a subject 5'end values are calculated using the blastn 'send' -subject end- values -normally used to define subject 3'end values)
#		^^ the following happens:
# 3. Define subject 5' end extension length
# 4. Define query 5' end extension length
#	5. Define the 5' overlapping extension length (i.e. the minimum number of nucleotides valid for downstream comparison in search of mismatches)
#	6. Define the 3' overlapping extension length
#	By comparing blastn reported start and end alignment coordinates, for query and subject, the following happens:
# 7. Define the coordinates for the query 5' start and end of extension
# 8. Define the coordinates for the query 3' start and end of extension
# 9. Define the coordinates for the subject 5' start and end of extension
# 10. Define the coordinates for the subject 3' start and end of extension
## All of the above may seem like a hassle just to get to points 7-10, but as of this version (article preprint, FEB 2019), explicit printing of the intermediate values is important for debugging
## Also, this may look cleaner in R, but that would introduce an extra pipeline requirement other than good ol' awk
awk '
  ###
  # Definition of input and output Field Separator as tab
    BEGIN {OFS=FS="\t"}
  ###
  # First line, print header, adding new column names
    NR == 1 {
      print $0,
      "q5end_extension_length","q3end_extension_length",
      "s5end_extension_length","s3end_extension_length",
      "overlap5end_extension_length","overlap3end_extension_length",
      "q5end_extension_start","q5end_extension_end",
      "q3end_extension_start","q3end_extension_end",
      "s5end_extension_start","s5end_extension_end",
      "s3end_extension_start","s3end_extension_end",
      "strand"
    } # ends header printing block
  ###
  # Data body operations block
    NR > 1 {
    ## Define named variables to reference columns
    # original query sequence length (including nt outside the blastn alignment)
      query_length=$1
    # position where the query began to align in the blastn hit
      query_alignment_start=$9
    # position where the query finished to align in the blastn hit
      query_alignment_end=$10
    # # #
    # original subject sequence length (including nt outside the blastn alignment)
      subject_length=$3
    # position where the subject began to align in the blastn hit
      subject_alignment_start=$11
    # position where the subject finished to align in the blastn hit
      subject_alignment_end=$12
    # Subject strand, or sense, (plus or minus) where the blastn hit took place
      subject_strand=$15
    ### Reset values, to avoid errors of carrying over values when some conditions are not met
      q5end_extension_length="NA"
      q3end_extension_length="NA"
      s5end_extension_length="NA"
      s3end_extension_length="NA"
      overlap5end_extension_length="NA"
      overlap3end_extension_length="NA"
      q5end_extension_start="NA"
      q5end_extension_end="NA"
      q3end_extension_start="NA"
      q3end_extension_end="NA"
      s5end_extension_start="NA"
      s5end_extension_end="NA"
      s3end_extension_start="NA"
      s3end_extension_end="NA"
      strand="NA"
    ###
    # Query extension lengths definition block
    ## Define query 5 end extension length
      # This is the the query_alignment_start minus one
      # i.e. query_alignment_start=1 ; q5end_extension_length=0 , since query aligned from the very beginning
        q5end_extension_length=query_alignment_start - 1
    ## Define query 3 end extension length
      # This is the the query_length minus query_alignment_end
      # i.e. query_length=23 , query_alignment_end=16 ; q3end_extension_length=7 , since seven query nucleotides were not included in the blastn hit alignment
        q3end_extension_length=query_length - query_alignment_end
    ###
    # Subject extension lengths definition block
    # if subject strand is "plus", subject lengths are calculated similarly as the Query ends above
      if ( subject_strand == "plus" ) {
        ## Define Subject 5 end extension length
          s5end_extension_length=subject_alignment_start - 1
        ## Define Subject 3 end extension length
          s3end_extension_length=subject_length - subject_alignment_end
      } else if ( subject_strand == "minus" ) {
    # if subject strand is "minus", subject lengths are calculated mirrored -i.e. 5 end final values correspond to the 3 end in the original subject sequence
        ## Define minus strand Subject 5 end extension length
        # for blastn "minus" hits, the subject start is actually the rightmost position in the subject coordinates
        # thus, to get the number of 5 end nucleotides,
        # we substract the subject_alignment_start from the subject_length
        # at the end, we are calcullating how many nt overhang in the original 3 end of the subject sequence
        # but during a downstream process (another module), nucleotides will be reverse complement extracted from that 3 end
          s5end_extension_length=subject_length - subject_alignment_start
        ## Define minus strand Subject 3 end extension length
        # for "minus" hits, the subject end is actually the leftmost position in the subject coordinates
        # thus, to get the number of 3 end nucleotides,
        # we substract the 1 to the subject_alignment_end
        # at the end, we are calcullating how many nt overhang in the original 5 end of the subject sequence
        # but during a downstream process (another module), nucleotides will be reverse complement extracted from that 5 end
          s3end_extension_length=subject_alignment_end - 1
      } # ends Subject extension lengths definition block
    ###
    # Define 5 end overlapping extension length
    # by finding the lowest number between q5end_extension_length and s5end_extension_length
    # if Query 5 end extension length is LESS THAN or EQUAL than Subject 5 end extension length, the overlapping extension length value is the Query 5 end extension length
    # else, the overlapping extension length value is the Subject 5 end extension length
      if ( q5end_extension_length <= s5end_extension_length )
        overlap5end_extension_length= q5end_extension_length
      else
        overlap5end_extension_length= s5end_extension_length
    ###
    # Define 3 end overlapping extension length
    # by finding the lowest number between q3end_extension_length and s3end_extension_length
    # if Query 3 end extension length is LESS THAN or EQUAL than Subject 3 end extension length, the overlapping extension length value is the Query 3 end extension length
    # else, the overlapping extension length value is the Subject 3 end extension length
      if ( q3end_extension_length <= s3end_extension_length )
        overlap3end_extension_length= q3end_extension_length
      else
        overlap3end_extension_length= s3end_extension_length
    ###
    # Define the coordinates for the Query 5 prime start and end of extension
    # extension will begin from query alignment start minus the 5 end overlapped extension length
      q5end_extension_start= query_alignment_start - overlap5end_extension_length
    # extension will end at query alignment start
      q5end_extension_end= query_alignment_start
    ###
    # Define the coordinates for the Query 3 prime start and end of extension
    # extension will begin from query alignment end
      q3end_extension_start= query_alignment_end
    # extension will end at query alignment end plus the 3 end overlapped extension length
      q3end_extension_end= query_alignment_end + overlap3end_extension_length
    ###
    # Define the coordinates for the Subject 5 prime start and end of extension
    # if subject strand is "plus", subject coordinates are calculated similarly as the Query coordinates above
      if ( subject_strand == "plus" ) {
        s5end_extension_start= subject_alignment_start - overlap5end_extension_length
        s5end_extension_end= subject_alignment_start
      } else if ( subject_strand == "minus" ) {
      # if subject strand is "minus", subject coordinates are calculated in a similar same way as query 3 end values
      ## remember than when strand is "minus", subject alignment start is rightmost from subject alignment end position
      # extension will begin from subject alignment start
        s5end_extension_start= subject_alignment_start
      # extension will end at subject alignment start plus the 5 end overlapped extension length
        s5end_extension_end= subject_alignment_start + overlap5end_extension_length
      }
    ###
    # Define the coordinates for the Subject 3 prime start and end of extension
    # if subject strand is "plus", subject coordinates are calculated similarly as the Query coordinates above
      if ( subject_strand == "plus" ) {
        s3end_extension_start= subject_alignment_end
        s3end_extension_end= subject_alignment_end + overlap3end_extension_length
      } else if ( subject_strand == "minus" ) {
      # if subject strand is "minus", subject coordinates are calculated in a similar same way as query 5 end values
      ## remember than when strand is "minus", subject alignment end is leftmost from subject alignment start position
      # extension will begin from subject alignment end minus the 3 end overlapped extension length
        s3end_extension_start= subject_alignment_end - overlap3end_extension_length
      # extension will end at subject alignment end
        s3end_extension_end= subject_alignment_end
      }
    ###
    # Add sign code for strandness (will be required by bedtools to extracte fasta nucleotides)
      if ( subject_strand == "plus" )
        strand="+"
      else
        strand="-"
    ###
    # Print lines and coordinate values
      print $0,
        q5end_extension_length, q3end_extension_length,
        s5end_extension_length, s3end_extension_length,
        overlap5end_extension_length, overlap3end_extension_length,
        q5end_extension_start, q5end_extension_end,
        q3end_extension_start, q3end_extension_end,
        s5end_extension_start, s5end_extension_end,
        s3end_extension_start, s3end_extension_end,
        strand
    }
' $INPUT_FILE
