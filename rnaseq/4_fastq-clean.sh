#!/bin/bash
set -u

usage (){
cat << EOF
Clean fastq file (elaborate)
Required Arguments
  -i FILE a single fastq file
  -o FILE a cleaned fastq file (delete original)
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
