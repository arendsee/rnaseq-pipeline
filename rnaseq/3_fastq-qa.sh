#!/bin/bash
set -u

usage (){
cat << EOF
Assess the quality of a single fastq file
Required Arguments
  -i FILE a single fastq file
  -o FILE pdf file describing fastq quality
EOF
exit 0
}

[[ $# -eq 0 ]] && usage

while getopts "hi:o:" opt; do
    case $opt in
        h)
            usage ;;
        i) 
            input=$OPTARG ;;
        o) 
            output=$OPTARG ;;
    esac 
done
