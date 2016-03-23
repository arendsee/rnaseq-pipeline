#!/usr/bin/env Rscript

require(data.table, quiet=TRUE)
require(plyr, quiet=TRUE)
require(magrittr, quiet=TRUE)
require(data.table, quiet=TRUE)

fields <- list(
  experiment = c(
    'experiment_id',
    'design_description',
    'library_name',
    'library_strategy',
    'library_source',
    'instrument_model'),
  sample = c(
    'sample_id',
    'sample_title',
    'taxon_id',
    'species'),
  study = c(
    'study_id',
    'study_title',
    'abstract'),
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
  'files',
  help='experiment.tab, sample.tab, study.tab, and an idmap',
  nargs=4
)

args <- parser$parse_args()


  # files <- list(
  #   experiment='experiment.tab',
  #   sample='sample.tab',
  #   study='study.tab',
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
names(f) <- c('experiment', 'sample', 'study', 'ids')


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

d <- merge(f$ids, f$experiment, by="experiment_id", all=TRUE) %>%
     merge(       f$sample,     by="sample_id",     all=TRUE) %>%
     merge(       f$study,      by="study_id",      all=TRUE)

# d <- ddply(d, 'study_id', mutate, N=length(study_id))

write.table(d, file='merged.tab', row.names=FALSE, quote=FALSE, sep="\t")
