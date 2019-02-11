#!/usr/bin/env nextflow

/*================================================================
The FLORES-JASSO LAB presents...

  THE ExtendAlign Nextflow PIPELINE

- A Short Sequence Extended Alignment tool

==================================================================
Version: 0.2.0
Project repository: https://github.com/Flores-JassoLab/ExtendAlign
==================================================================
Authors:

- Bioinformatics Design
 Mariana Flores-Torres (mflores@inmegen.edu.mx)
 Israel Aguilar-Ordonez (iaguilaror@gmail)
 Joshua I. Haase-Hernández (jihaase@inmegen.gob.mx)
 Fabian Flores-Jasso (cfflores@inmegen.gob.mx)

- Bioinformatics Development
 Israel Aguilar-Ordonez (iaguilaror@gmail)
 Mariana Flores-Torres (mflores@inmegen.edu.mx)
 Joshua I. Haase-Hernández (jihaase@inmegen.gob.mx )

- Nextflow Port
 Israel Aguilar-Ordonez (iaguilaror@gmail)

=============================
Pipeline Processes In Brief:

Pre-processing:
  _A1_query_EAfasta_formating
  _B1_subject_EAfasta_formating
  _B2_subject_blastDB_creation

Core-processing:
  _001_blastn_alignment
    _001sub1_keep_besthits
  _002_add_EA_coordinates_for_extraction
  _003_add_EA_extension_nucleotides
  _004_add_EA_percent_identity
  _005_append_queries_with_no_hits
  _006_generate_EA_report

================================================================*/

/* Define the help message as a function to call when needed *//////////////////////////////
def helpMessage() {
	log.info"""
  ==========================================
  THE ExtendAlign Nextflow PIPELINE
  - A Short Sequence Extended Alignment tool
  v${version}
  ==========================================

	Usage:

	nextflow run extend_align.nf --query_fasta <path to input 1> --subject_fasta <path to input 2>
    [--blastn_threads int_value] [--blastn_strand both|plus|minus] [--number_of_hits all|best]

   --query_fasta    <- DNA or RNA fasta file with query sequences;
                       accepted extensions are .fa .fna and .fasta
   --subject_fasta  <- DNA or RNA fasta file with subject sequences;
                       accepted extensions are .fa .fna and .fasta
   --blastn_threads <- Number of threads to use in blastn search;
                       default 1
   --blastn_strand  <- Subject strand to align against during blastn;
                       default: both
                         plus  = report hits found in subject's plus strand
                         minus = report hits found in subject's minus strand
                         both  = report all
   --number_of_hits <- Amount of blastn hits extended by EA for each query;
                       default: best
                         all  = Every hit found by blastn is extended and reported by EA
                         best = Only the best blastn hit (one per query) is extended and reported by EA
                          NOTE. defined using the basic blastn alignment values, by the following algorithm:
                                best hit is the one with higher alignment length, and the lowest number of mismatches and gaps
   --help           <- Shows Pipeline Information
   --version        <- Show ExtendAlign version
	""".stripIndent()
}

/*//////////////////////////////
  Define pipeline version
  If you bump the number, remember to bump it in the header description at the begining of this script too
*/
version = "0.2.0"

/*
  Initiate default values for parameters
  to avoid "WARN: Access to undefined parameter" messages
*/
params.query_fasta = false  //if no inputh path is provided, value is false to provoke the error during the parameter validation block
params.subject_fasta = false //if no inputh path is provided, value is false to provoke the error during the parameter validation block
params.blastn_threads = "1" //default is one computing thread for blastn processing
params.blastn_strand = "both" //default is to report blastn hits in both stands
params.number_of_hits = "best" //default is to keep only the best blastn hit before EA extension
params.help = false //default is false to not trigger help message automatically at every run
params.version = false //default is false to not trigger version message automatically at every run

/*//////////////////////////////
  If the user inputs the --help flag
  print the help message and exit pipeline
*/
if (params.help){
	helpMessage()
	exit 0
}

/*//////////////////////////////
  If the user inputs the --version flag
  print the EA pipeline version
*/
if (params.version){
	println "ExtendAlign v${version}"
	exit 0
}

/*//////////////////////////////
  Define the Nextflow version under which this pipeline was developed or successfuly tested
  Updated by iaguilar at FEB 2019
*/
nextflow_required_version = '18.10.1'
/*
  Try Catch to verify compatible Nextflow version
  If user Nextflow version is lower than the required version pipeline will continue
  but a message is printed to tell the user maybe it's a good idea to update her/his Nextflow
*/
try {
	if( ! nextflow.version.matches(">= $nextflow_required_version") ){
		throw GroovyException('Your Nextflow version is older than Extend Align required version')
	}
} catch (all) {
	log.error "-----\n" +
			"  Extend Align (EA) requires Nextflow version: $nextflow_required_version \n" +
      "  But you are running version: $workflow.nextflow.version \n" +
			"  EA pipeline will continue but some things may not work as intended\n" +
			"  You may want to run `nextflow self-update` to update Nextflow\n" +
			"============================================================"
}

/*//////////////////////////////
  INPUT PARAMETER VALIDATION BLOCK
*/

/* Check if query and subject fasta files were provided
    if they were not provided, they keep the 'false' value assigned in the parameter initiation block above
    and this test fails
*/
if ( !params.query_fasta || !params.subject_fasta ) {
  log.error " Please provide both, the --query_fasta AND the --subject_fasta \n"
  exit 1
}
/* Check if query OR subject fasta files are missing
  See the docs at https://www.nextflow.io/docs/latest/script.html#files-and-i-o
  to understand the file( , checkIfExists: true) structure

  We use a try catch structure to be able to print the catch message, otherwise a simple
  "ERROR ~ No such file: mmu-premiRNA.fa" message would be printed
  and that is not completely informative
*/
try {
	if( ! file(params.query_fasta, checkIfExists: true) || ! file(params.subject_fasta, checkIfExists: true) ){
		throw GroovyException('EA Cant find one or more of the fasta files at the provided path')
	}
} catch (all) {
	log.error "One or more of the following files could not be found: \n\n" +
  " Query: $params.query_fasta \n" +
  " Subject: $params.subject_fasta \n\n" +
  " [EA Solution] Please provide both valid paths"
  exit 1
}

/*
Check if blastn threads parameter is a number higher than 0
*/
if ( params.blastn_threads <= 0 ) {
    log.error "invalid --blastn_threads; use a positive integer value"
    exit 1
}

/*
  Check if blastn strand parameter has a valid value
  For valid values, see blastn --help from the command line
*/
if ( params.blastn_strand != "both" && params.blastn_strand != "plus" && params.blastn_strand != "minus" ) {
    log.error "invalid --blastn_strand values\n\n" +
    " [EA Solution] accepted --blastn_strand values: both | plus | minus"
    exit 1
}

/*
  Check if number of hits parameter has a valid value
  valid values are: "best" and "all"
*/
if ( params.number_of_hits != "best" && params.number_of_hits != "all" ) {
    log.error "invalid --number_of_hits values\n\n" +
    " [EA Solution] accepted --number_of_hits values: best | all"
    exit 1
}

/*//////////////////////////////
  LOG RUN INFORMATION
*/
log.info"""
==========================================
THE ExtendAlign Nextflow PIPELINE
- A Short Sequence Extended Alignment tool
v${version}
==========================================
""".stripIndent()
/* define function to store run summary info */
def summary = [:]
/* log parameter values beign used into summary */
summary['Run Name']			= workflow.runName
summary['Input Query']			= params.query_fasta
summary['Input Subject']			= params.subject_fasta
summary['Blastn threads']			= params.blastn_threads
summary['Blastn strand']			= params.blastn_strand
summary['Number of hits']			= params.number_of_hits
summary['Working dir']		 = workflow.workDir
summary['Current home']		= "$HOME"
summary['Current user']		= "$USER"
summary['Current path']		= "$PWD"
/* print stored summary info */
log.info summary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "=========================================="

/*//////////////////////////////
  PIPELINE START
*/
