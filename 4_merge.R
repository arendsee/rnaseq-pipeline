#!/usr/bin/env Rscript

require(data.table, quiet=TRUE)
require(plyr, quiet=TRUE)
require(magrittr, quiet=TRUE)
require(data.table, quiet=TRUE)

version <- '0.1'

fields <- list(
  study = c(
    'study_id',
    'study_title',
    'abstract'),
  sample = c(
    'sample_id',
    'sample_title',
    'taxon_id',
    'species'),
  experiment = c(
    'experiment_id',
    'design_description',
    'library_name',
    'library_strategy',
    'library_source',
    'instrument_model'),
  ids = c(
    'experiment_id',
    'sample_id',
    'study_id',
    'biosample',
    'bioproject',
    'submission_id')
)

suppressPackageStartupMessages(library("argparse"))
parser <- ArgumentParser(
  formatter_class='argparse.RawTextHelpFormatter',
  description='Merge metadata files from SRA analysis. This script will die hard if anything is wrong.',
  usage='merge.R [options]')

parser$add_argument(
  '-v', '--version',
  action='store_true',
  default=FALSE)

parser$add_argument(
  '-i' , '--taxids',
  help='Taxon ids to extract in the final output'
)

parser$add_argument(
  'files',
  help='study.tab, sample.tab, experiment.tab, and an idmap',
  nargs=4
)

args <- parser$parse_args()

if(args$version){
  cat(sprintf('rstab v%s\n', version))
  q()
}


  # files <- list(
  #   study='study.tab',
  #   sample='sample.tab',
  #   experiment='experiment.tab',
  #   ids='rnaseq-id-map'
  # )
files <- args$files


# # For debugging
# files=list('study.tab', 'sample.tab', 'experiment.tab')

if(any(lapply(files, file.access, mode=4) != 0)){
  stop('One or more input file is not readable')
}



f <- files %>%
  lapply(read.delim, quote='') %>%
  lapply(as.data.table)
names(f) <- c('study', 'sample', 'experiment', 'ids')


for(i in 1:length(f)){
  if(!setequal(names(f[[i]]), fields[[i]])){
    field_wanted <- fields[[i]] %>%
      sort %>%
      paste(collapse=', ')
    field_seen <- names(f[[i]]) %>%
      sort %>%
      paste(collapse=', ')
    stop(sprintf("File '%s' has incorrect fields\nRequired fields:\n[%s]\n-----\nProvided fields:\n[%s]",
      files[[i]], field_wanted, field_seen))
  }
}

d  <- merge(f$ids, f$experiment, by="experiment_id", all=TRUE) %>%
      merge(       f$sample,     by="sample_id",     all=TRUE) %>%
      merge(       f$study,      by="study_id",      all=TRUE)

d[, .(sample_counts = length(study_id)), by=study_id]

write.table(d, file='merged.tab', row.names=FALSE, quote=FALSE, sep="\t")
