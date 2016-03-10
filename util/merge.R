#!/usr/bin/env Rscript

require(data.table, quiet=TRUE)
require(plyr, quiet=TRUE)
require(magrittr, quiet=TRUE)
require(data.table, quiet=TRUE)

version <- '0.1'

fields <- list(
  study = c(
    'SRA_id',
    'study_id',
    'study_title',
    'abstract'),
  sample = c(
    'SRA_id',
    'sample_id',
    'sample_title',
    'taxon_id',
    'species'),
  experiment = c(
    'SRA_id',
    'experiment_id',
    'sample_id',
    'design_description',
    'library_name',
    'library_strategy',
    'library_source',
    'instrument_model')
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
  'files',
  help='study.tab, sample.tab, and experiment.tab files.',
  nargs=3
)

args <- parser$parse_args()

if(args$version){
  cat(sprintf('rstab v%s\n', version))
  q()
}

files <- args$files

# # For debugging
files=list('study.tab', 'sample.tab', 'experiment.tab')

if(any(lapply(files, file.access, mode=4) != 0)){
  stop('One or more input file is not readable')
}



f <- files %>%
  lapply(read.delim) %>%
  lapply(as.data.table)
names(f) <- c('study', 'sample', 'experiment')


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

d <- merge(f$study, f$sample, by="SRA_id", all=TRUE) %>%
  merge(f$experiment, by="sample_id", all=TRUE)

d[, .(sample_counts.x = length(SRA_id.x)), by=SRA_id.x]
d[, .(sample_counts.y = length(SRA_id.y)), by=SRA_id.y]

write.table(d, file='merged.tab', row.names=FALSE, quote=FALSE, sep="\t")
