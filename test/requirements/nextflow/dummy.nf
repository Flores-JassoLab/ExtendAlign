params.str = "nextflow is installed"

process TEST {
  echo true

  script:
  """
  echo ${params.str}
  """
}
