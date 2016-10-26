#!/bin/bash
set -u

NCBI_DIR=$HOME/ncbi/public/sra

usage (){
cat << EOF
Download the fastq entry for a single run id
Required Arguments
  -r A single run id (e.g. SRR123456)
  -o output directory for fastq files
Note: *.sra files are first downloaded into the \$HOME/ncbi/public/sra
direcotry. The fastq files are then extracted, and then the *.sra files are
deleted (to conserve space).
EOF
exit 0
}

[[ $# -eq 0 ]] && usage

logfile=fastq.log
while getopts "hr:o:" opt; do
    case $opt in
        h)
            usage ;;
        r) 
            runid=$OPTARG ;;
        o)
            outdir=$OPTARG ;;
        d)
            logfile=$OPTARG ;;
    esac 
done


# Check whether the experiment was paired-end
if [[ $(fastq-dump -X 1 -Z --split-files $runid 2> /dev/null | wc -l) -eq 4 ]]
then
    echo "The experiment $runid is not paired-ends, skipping" >&2 
    exit 1
fi

# Load sra archive into ncbi/public/sra folder
prefetch             \
    --max-size 100G  \
    --transport ascp \
    --ascp-path "/opt/aspera/bin/ascp|/opt/aspera/etc/asperaweb_id_dsa.openssh" \
    $runid

# Options descriptions
# split-files    - split paired-end data into files suffixed with _1 and _2
# readids        - append read id (.1, .2) after spot id
# dumpbase       - output as ACGT bases rather than color-base (e.g. from SOLiD)
# clip           - remove left and right tags
# skip-technical - skip technical reads (not useable by Kallisto, also is
#                  specific to Illumina multiplexing library construction
#                  protocol)
time fastq-dump        \
    --readids          \
    --split-files      \
    --dumpbase         \
    --skip-technical   \
    --clip             \
    --qual-filter-1    \
    --outdir "$outdir" \
    $NCBI_DIR/${runid}.sra 2>&1 >> $logfile

rm -f $NCBI_DIR/${runid}.*
