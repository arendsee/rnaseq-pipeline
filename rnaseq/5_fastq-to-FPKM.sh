#!/bin/bash
set -u

usage (){
cat << EOF
Map reads of a single fastq file to a transcriptome creating a FPKM table
Required Arguments
  -f FILE a single fastq file
  -t FILE a fasta transcriptome file
  -o FILE an FPKM output table
EOF
exit 0
}

[[ $# -eq 0 ]] && usage

while getopts "hf:o:t:" opt; do
    case $opt in
        h)
            usage ;;
        f) 
            fastq=$OPTARG ;;
        t)
            transcriptome=$OPTARG ;;
        o) 
            output=$OPTARG ;;
    esac 
done
