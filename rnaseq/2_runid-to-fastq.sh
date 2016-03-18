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
