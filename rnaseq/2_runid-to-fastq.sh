#!/bin/bash
set -u

usage (){
cat << EOF
Download the fastq entry for a single run id
Required Arguments
  -r ID A single run id (e.g. SRR123456)
EOF
exit 0
}

[[ $# -eq 0 ]] && usage

while getopts "hr:" opt; do
    case $opt in
        h)
            usage ;;
        r) 
            runid=$OPTARG ;;
    esac 
done


# Options descriptions
# split-files    - split paired-end data into files suffixed with _1 and _2
# readids        - append read id (.1, .2) after spot id
# dumpbase       - output as ACGT bases rather than color-base (e.g. from SOLiD)
# clip           - remove left and right tags
# skip-technical - skip technical reads (not useable by Kallisto, also is
#                  specific to Illumina multiplexing library construction
#                  protocol)

fastq-dump --readids --split-files --dumpbase --skip-technical --clip  $runid
