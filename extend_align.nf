#!/usr/bin/env nextflow

/*================================================================
The FLORES-JASSO LAB presents...

  The ExtendAlign Nextflow Pipeline

- A Short Sequence Extended Alignment tool

==================================================================
Version: 0.2.2
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
	_001x1_recalculate_gap_mismatches
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
  The ExtendAlign Nextflow Pipeline
  - A Short Sequence Extended Alignment tool
  v${version}
  ==========================================

	Usage:

  nextflow run extend_align.nf --query_fasta <path to input 1> --subject_fasta <path to input 2> [--output_dir path to results ]
  				[--number_of_hits all|best] [--blastn_threads int_value] [--blastn_strand both|plus|minus]
  				[--blastn_max_target_seqs int_value] [--blastn_evalue real_value] [-profile sge|condor] [-resume]

	  --query_fasta    <- DNA or RNA fasta file with query sequences;
				accepted extensions are .fa .fna and .fasta
	  --subject_fasta  <- DNA or RNA fasta file with subject sequences;
				accepted extensions are .fa .fna and .fasta
	  --output_dir     <- directory where results, intermediate and log files will bestored;
				default: same dir where --query_fasta resides
	  --number_of_hits <- Amount of blastn hits extended by EA for each query;
				default: best
				all  = Every hit found by blastn is extended and reported by EA
				best = Only the best blastn hit (one per query) is extended and reported by EA
				NOTE. defined using the basic blastn alignment values, by the following algorithm:
				best hit is the one with higher alignment length, and the lowest number of mismatches and gaps
	  --blastn_threads <- Number of threads to use in blastn search;
				default: 1
	  --blastn_strand  <- Subject strand to align against during blastn;
				default: both
				plus  = report hits found in subject's plus strand
				minus = report hits found in subject's minus strand
				both  = report all
	  --blastn_max_target_seqs <- Number of aligned sequences to keep;
				default: 1000
	  --blastn_evalue  <- Expect value (E) for saving hits;
				default: 1000
	  -profile	   <- Run pipeline using configurations compatible with cluster computing environments
				default: not activated; jobs are run locally
				sge	= submit pipeline processes as SGE jobs
				condor	= submit pipeline processes as HTCondor jobs
				Note. Before running EA with cluster compatibility make sure you configure your credentials in the following files:
				for SGE, config_profiles/sge.config
				for HTCondor, config_profiles/condor.config
				Read more here: https://www.nextflow.io/docs/latest/config.html#config-profiles
	  -resume	   <- Use cached results if the executed project has been run before;
				default: not activated
				This native NF option checks if anything has changed from a previous pipeline execution.
				Then, it resumes the run from the last successful stage.
				i.e. If for some reason your previous run got interrupted,
				running the -resume option will take it from the last successful pipeline stage
				instead of starting over
				Read more here: https://www.nextflow.io/docs/latest/getstarted.html#getstart-resume
	  --help           <- Shows Pipeline Information
	  --version        <- Show ExtendAlign version
	""".stripIndent()
}

/*//////////////////////////////
  Define pipeline version
  If you bump the number, remember to bump it in the header description at the begining of this script too
*/
version = "0.2.2"

/*//////////////////////////////
  Define pipeline Name
  This will be used as a name to include in the results and intermediates directory names
*/
pipeline_name = "Extend_Align"

/*
  Initiate default values for parameters
  to avoid "WARN: Access to undefined parameter" messages
*/
params.query_fasta = false  //if no inputh path is provided, value is false to provoke the error during the parameter validation block
params.subject_fasta = false //if no inputh path is provided, value is false to provoke the error during the parameter validation block
params.blastn_threads = 1 //default is one computing thread for blastn processing
params.blastn_strand = "both" //default is to report blastn hits in both stands
params.number_of_hits = "best" //default is to keep only the best blastn hit before EA extension
params.blastn_max_target_seqs = 100 //default is to keep only the first 100 hits found by blastn
params.blastn_evalue = 10 //Default is an evalue of 10.0 as cutoff to report hits
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
  TODO (iaguilar) check the extension of input queries; see getExtension() at https://www.nextflow.io/docs/latest/script.html#check-file-attributes
*/

/* Check if query and subject fasta files were provided
    if they were not provided, they keep the 'false' value assigned in the parameter initiation block above
    and this test fails
*/
if ( !params.query_fasta || !params.subject_fasta ) {
  log.error " Please provide both, the --query_fasta AND the --subject_fasta \n\n" +
  " For more information, execute: nextflow run extend_align.nf --help"
  exit 1
}
/* Check if query OR subject fasta files are missing
  See the docs at https://www.nextflow.io/docs/latest/script.html#files-and-i-o
  to understand the file( , checkIfExists: true) structure

  We use a try catch structure to be able to print the catch message, otherwise a simple
  "ERROR ~ No such file: mmu-premiRNA.fa" message would be printed
  which is not completely informative
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
Check if blastn threads parameter is 0 or lower; if it is, send error message
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

/*
Check if blastn max_target_seqs parameter is 0 or lower; if it is, send error message
*/
if ( params.blastn_max_target_seqs <= 0 ) {
    log.error "invalid --blastn_max_target_seqs; use a positive integer value"
    exit 1
}

/*
Check if blastn evalue parameter is 0 or lower; if it is, send error message
*/
if ( params.blastn_evalue <= 0 ) {
    log.error "invalid --blastn_evalue; use a real number"
    exit 1
}

/*
  TODO (iaguilar) perform output_dir parameter validation, with the following rules:
    -when it is not provided, goes to default value
    -when no value is passed (no --output_dir flag), gives error message and asks for fullpath
	finish TODO block

  Output directory definition
  Default value to create directory is the parent dir of --query_fasta
	thus, this must be defined after the "Check if query OR subject fasta files are missing" block
*/
params.output_dir = file(params.query_fasta).getParent()

/*
  Results and Intermediate directory definition
  They are always relative to the base Output Directory
  and they always include the pipeline name in the variable (pipeline_name) defined by this Script

  This directories will be automatically created by the pipeline to store files during the run
*/
results_dir = "${params.output_dir}/${pipeline_name}_results/"
intermediates_dir = "${params.output_dir}/${pipeline_name}_intermediate/"

/*//////////////////////////////
  LOG RUN INFORMATION
*/
log.info"""
==========================================
The ExtendAlign Nextflow Pipeline
- A Short Sequence Extended Alignment tool
v${version}
==========================================
"""
log.info "--Nextflow metadata--"
/* define function to store nextflow metadata summary info */
def nfsummary = [:]
/* log parameter values beign used into summary */
/* For the following runtime metadata origins, see https://www.nextflow.io/docs/latest/metadata.html */
nfsummary['Resumed run?'] = workflow.resume
nfsummary['Run Name']			= workflow.runName
nfsummary['Current user']		= workflow.userName
/* string transform the time and date of run start; remove : chars and replace spaces by underscores */
nfsummary['Start time']			= workflow.start.toString().replace(":", "").replace(" ", "_")
nfsummary['Script dir']		 = workflow.projectDir
nfsummary['Working dir']		 = workflow.workDir
nfsummary['Current dir']		= workflow.launchDir
nfsummary['Launch command'] = workflow.commandLine
log.info nfsummary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "\n\n--ExtendAlign Parameters--"
/* define function to store nextflow metadata summary info */
def pipelinesummary = [:]
/* log parameter values beign used into summary */
pipelinesummary['Query']			= params.query_fasta
pipelinesummary['Subject']			= params.subject_fasta
pipelinesummary['Results Dir']		= results_dir
pipelinesummary['Intermediate Dir']		= intermediates_dir
pipelinesummary['Blastn threads']			= params.blastn_threads
pipelinesummary['Blastn strand']			= params.blastn_strand
pipelinesummary['Blastn max_target_seqs']			= params.blastn_max_target_seqs
pipelinesummary['Blastn evalue']			= params.blastn_evalue
pipelinesummary['Number of hits']			= params.number_of_hits
/* print stored summary info */
log.info pipelinesummary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "==========================================\nPipeline Start"

/*//////////////////////////////
  PIPELINE START
*/

/*
	DEFINE PATHS TO MK MODULES
  -- every required file (mainly runmk.sh and mkfile, but also every accessory script)
  will be moved from this paths into the corresponding process work subdirectory during pipeline execution
  The use of ${workflow.projectDir} metadata guarantees that mkmodules
  will always be retrieved from a path relative to this NF script
*/

/* _A1_query_EAfasta_formating */
module_mk_A1_query_EAfasta_formating = "${workflow.projectDir}/mkmodules/mk-create_EAfasta"

/* _B1_subject_EAfasta_formating */
module_mk_B1_subject_EAfasta_formating = "${workflow.projectDir}/mkmodules/mk-create_EAfasta"

/* _B2_subject_blastDB_creation */
module_mk_B2_subject_blastDB_creation = "${workflow.projectDir}/mkmodules/mk-create_blastdb"

/* _001_blastn_alignment */
module_mk_001_blastn_alignment = "${workflow.projectDir}/mkmodules/mk-HSe-blastn"

/* _001x1_recalculate_gap_mismatches */
module_mk_001x1_recalculate_gap_mismatches = "${workflow.projectDir}/mkmodules/mk-recalculate_ngap"

/* _001sub1_keep_besthits */
module_mk_001sub1_keep_besthits = "${workflow.projectDir}/mkmodules/mk-get_best_hit"

/* _002_add_EA_coordinates_for_extraction */
module_mk_002_add_EA_coordinates_for_extraction = "${workflow.projectDir}/mkmodules/mk-get_EA_coordinates"

/* _003_add_EA_extension_nucleotides */
module_mk_003_add_EA_extension_nucleotides = "${workflow.projectDir}/mkmodules/mk-bedtools_getfasta"

/* _004_add_EA_percent_identity */
module_mk_004_add_EA_percent_identity = "${workflow.projectDir}/mkmodules/mk-mismatch_recalculation"

/* _005_append_queries_with_no_hits */
module_mk_005_append_queries_with_no_hits = "${workflow.projectDir}/mkmodules/mk-append_nohits"

/* _006_generate_EA_report */
module_mk_006_generate_EA_report = "${workflow.projectDir}/mkmodules/mk-EA_report"

/*
	READ INPUTS
*/

// /* Load query fasta file into channel */
Channel
	.fromPath("${params.query_fasta}")
	.set{ query_fasta_input }

// /* Load subject fasta file into channel */
Channel
	.fromPath("${params.subject_fasta}")
	.set{ subject_fasta_input }

/* Process _A1_query_EAfasta_formating */

/* Read mkfile module files */
Channel
	.fromPath("${module_mk_A1_query_EAfasta_formating}/*")
	.toList()
	.set{ mkfiles_A1 }

process _A1_query_EAfasta_formating {

	publishDir "${intermediates_dir}/_A1_query_EAfasta_formating/",mode:"symlink"

	input:
  file fasta from query_fasta_input
	file mk_files from mkfiles_A1

	output:
	file "*.EAfa" into results_A1_query_EAfasta_formating, also_results_A1_query_EAfasta_formating

	"""
	bash runmk.sh
	"""

}

/* Process _B1_subject_EAfasta_formating */

/* Read mkfile module files */
Channel
	.fromPath("${module_mk_B1_subject_EAfasta_formating}/*")
	.toList()
	.set{ mkfiles_B1 }

process _B1_subject_EAfasta_formating {

	publishDir "${intermediates_dir}/_B1_subject_EAfasta_formating/",mode:"symlink"

	input:
  file fasta from subject_fasta_input
	file mk_files from mkfiles_B1

	output:
	file "*.EAfa" into results_B1_subject_EAfasta_formating, also_results_B1_subject_EAfasta_formating

	"""
	bash runmk.sh
	"""

}

/* Process _B2_subject_blastDB_creation */

/* Read mkfile module files */
Channel
	.fromPath("${module_mk_B2_subject_blastDB_creation}/*")
	.toList()
	.set{ mkfiles_B2 }

process _B2_subject_blastDB_creation {

	publishDir "${intermediates_dir}/_B2_subject_blastDB_creation/",mode:"symlink"

	input:
  file eafasta from results_B1_subject_EAfasta_formating
	file mk_files from mkfiles_B2

	output:
  /*
    --load every n* created file, see readme at mkmodule for more info
    --specify mode flatten to avoid a downstream _001_blastn_alignment process bug
      were instead of sending database files
      it just sends a file named input.2 with the file paths
  */
	file "*.EAfa.n*" into results_B2_subject_blastDB_creation mode flatten

	"""
	bash runmk.sh
	"""

}

/* get every blastDB file into a single list to send them togheter to the next process */
results_B2_subject_blastDB_creation
  .toList()
  .set{ all_blastDB_files }

/* Process _001_blastn_alignment */

/* Read mkfile module files */
Channel
	.fromPath("${module_mk_001_blastn_alignment}/*")
	.toList()
	.set{ mkfiles_001 }

process _001_blastn_alignment {

	publishDir "${intermediates_dir}/_001_blastn_alignment/",mode:"symlink"

	input:
  file eafasta from results_A1_query_EAfasta_formating
  file dbfiles from all_blastDB_files
	file mk_files from mkfiles_001

	output:
  file "*.blastn.tsv" into results_001_blastn_alignment

  /*
  define a variable with the subject query name to be able to dinamically generate
  the path to the custom blastn EA database
  */
  script:
  dbname=file(params.subject_fasta).getName()

  /* since this module uses arguments passed to mk, we will declare them */
  /* BLAST_DATABASE uses the previously generated dbname variable to find the name for the blastDB files */
	"""
  bash runmk.sh \
    BLAST_DATABASE="${dbname}.EAfa" \
    BLAST_THREADS="${params.blastn_threads}" \
    BLAST_STRAND="${params.blastn_strand}" \
		BLAST_MAX_TARGET_SEQS="${params.blastn_max_target_seqs}" \
	  BLAST_EVALUE="${params.blastn_evalue}"
	"""

}

/* Process _001x1_recalculate_gap_mismatches */

/* Read mkfile module files */
Channel
	.fromPath("${module_mk_001x1_recalculate_gap_mismatches}/*")
	.toList()
	.set{ mkfiles_001x1 }

process _001x1_recalculate_gap_mismatches {

	publishDir "${intermediates_dir}/_001x1_recalculate_gap_mismatches/",mode:"symlink"

	input:
  file tsv from results_001_blastn_alignment
	file mk_files from mkfiles_001x1

	output:
  file "*.EAblastn.tsv" into results_001x1_recalculate_gap_mismatches

	"""
  bash runmk.sh
	"""

}

/*
  ==Pipeline branching point==
  If user asked for --number_of_hits "best" hit mode
  then the results_001x1_recalculate_gap_mismatches channel have to pass for the _001sub1_keep_besthits
*/

if ( params.number_of_hits == "best") {

  /* Process _001sub1_keep_besthits */

  /* Read mkfile module files */
  Channel
  	.fromPath("${module_mk_001sub1_keep_besthits}/*")
  	.toList()
  	.set{ mkfiles_001sub1 }

  process _001sub1_keep_besthits {

  	publishDir "${intermediates_dir}/_001sub1_keep_besthits/",mode:"symlink"

  	input:
    file blastn_tsv from results_001x1_recalculate_gap_mismatches
  	file mk_files from mkfiles_001sub1

  	output:
    file "*.EAblastnbesthit.tsv" into results_001sub1_keep_besthits

  	"""
    bash runmk.sh
  	"""

  }

}

/*
  To handle the user option of --number_of_hits = "best" | "all"
  Let's conditionally define the channel that will become the input for the next process: _002_add_EA_coordinates_for_extraction
*/

if ( params.number_of_hits == "best" ) {
  // use the channel from the best hit extraction process
  results_001sub1_keep_besthits
    .set{ conditional_input_for_002 }
} else {
  // directly use the channel from the normal EAblastn process
  results_001x1_recalculate_gap_mismatches
    .set{ conditional_input_for_002 }
}

/* Process : _002_add_EA_coordinates_for_extraction */

/* Read mkfile module files */
Channel
  .fromPath("${module_mk_002_add_EA_coordinates_for_extraction}/*")
  .toList()
  .set{ mkfiles_002 }

process _002_add_EA_coordinates_for_extraction {

  publishDir "${intermediates_dir}/_002_add_EA_coordinates_for_extraction/",mode:"symlink"

  input:
  file blastn_tsv from conditional_input_for_002
  file mk_files from mkfiles_002

  output:
  file "*.EAcoordinates.tsv" into results_002_add_EA_coordinates_for_extraction

  """
  bash runmk.sh
  """

}

/* Process _003_add_EA_extension_nucleotides */

/* Read mkfile module files */
Channel
  .fromPath("${module_mk_003_add_EA_extension_nucleotides}/*")
  .toList()
  .set{ mkfiles_003 }

process _003_add_EA_extension_nucleotides {

  publishDir "${intermediates_dir}/_003_add_EA_extension_nucleotides/",mode:"symlink"

  input:
  file ea_coordinates_tsv from results_002_add_EA_coordinates_for_extraction
  file mk_files from mkfiles_003

  output:
  file "*.extended_nucleotides.tsv" into results_003_add_EA_extension_nucleotides

	/*
		get the absolute paths for input fastas, for downstream passing to runmk.sh
	*/
	script:
	query_path=file(params.query_fasta)
	subject_path=file(params.subject_fasta)

  /* since this module uses arguments passed to mk, we will declare them */
	/* QUERY_FASTA is the path to the input query fasta */
	/* SUBJECT_FASTA is the path to the input subject fasta */
  """
  bash runmk.sh \
	 QUERY_FASTA="${query_path}" \
	 SUBJECT_FASTA="${subject_path}"
  """

}

/* Process _004_add_EA_percent_identity */

/* Read mkfile module files */
Channel
  .fromPath("${module_mk_004_add_EA_percent_identity}/*")
  .toList()
  .set{ mkfiles_004 }

process _004_add_EA_percent_identity {

  publishDir "${intermediates_dir}/_004_add_EA_percent_identity/",mode:"symlink"

  input:
  file ea_extrended_tsv from results_003_add_EA_extension_nucleotides
  file mk_files from mkfiles_004

  output:
  file "*.recalculatedmm.tsv" into results_004_add_EA_percent_identity

  """
  bash runmk.sh
  """

}

/* Process _005_append_queries_with_no_hits */

/* Read mkfile module files */
Channel
  .fromPath("${module_mk_005_append_queries_with_no_hits}/*")
  .toList()
  .set{ mkfiles_005 }

process _005_append_queries_with_no_hits {

  publishDir "${intermediates_dir}/_005_append_queries_with_no_hits/",mode:"copy"

  input:
  file ea_recalculatedmm_tsv from results_004_add_EA_percent_identity
	file eafasta from also_results_A1_query_EAfasta_formating
  file mk_files from mkfiles_005

  output:
  file "*.with_nohits.tsv" into results_005_append_queries_with_no_hits

  """
  bash runmk.sh
  """

}

/* Process _006_generate_EA_report */

/* Read mkfile module files */
Channel
  .fromPath("${module_mk_006_generate_EA_report}/*")
  .toList()
  .set{ mkfiles_006 }

process _006_generate_EA_report {

	/* Since this is the intended results file, it goes into the result directory */
	publishDir "${results_dir}/",mode:"copy"

  input:
  file ea_complete_tsv from results_005_append_queries_with_no_hits
  file mk_files from mkfiles_006

  output:
  file "*_EA_report.tsv"

  """
  bash runmk.sh
  """

}
