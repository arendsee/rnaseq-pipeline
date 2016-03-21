#!/bin/bash
set -u

usage (){
cat << EOF
Download the fastq entry for a single run id
Required Arguments
  -r A single run id (e.g. SRR123456)
  -o output directory for fastq files
EOF
exit 0
}

[[ $# -eq 0 ]] && usage

while getopts "hr:o:" opt; do
    case $opt in
        h)
            usage ;;
        r) 
            runid=$OPTARG ;;
        o)
            outdir=$OPTARG ;;
    esac 
done


# Check whether the experiment was paired-end
if [[ $(fastq-dump -X 1 -Z --split-files $runid 2> /dev/null | wc -l) -eq 4 ]]
then
    echo "The experiment $runid is not paired-ends, skipping" >&2 
    exit 1
fi

# Options descriptions
# split-files    - split paired-end data into files suffixed with _1 and _2
# readids        - append read id (.1, .2) after spot id
# dumpbase       - output as ACGT bases rather than color-base (e.g. from SOLiD)
# clip           - remove left and right tags
# skip-technical - skip technical reads (not useable by Kallisto, also is
#                  specific to Illumina multiplexing library construction
#                  protocol)

# Load bamfile into ncbi/public/sra folder
prefetch \
    --max-size 100G \
    --transport ascp \
    --ascp-path "/opt/aspera/bin/ascp|/opt/aspera/etc/asperaweb_id_dsa.openssh" \
    $runid

# TODO
# - change outdir options to reflect preftech idiosyncracies
# - with samtools:
#     - use quickcheck to ensure the full BAM file was retrieved
#     - split into paired-end files
#     - check quality `bamtools stats`?
#     - convert to fastq
# - remove adapters (can this be done in BAM forat with samtools?)
# - filter reads, do I really need to do this?
#
# Problems:
# - do I need to skip technical replicates?
# - what about color?
# - how should I deal with non-paired-end reads?
