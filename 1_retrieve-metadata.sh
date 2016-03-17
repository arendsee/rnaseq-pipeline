#!/bin/bash
set -u

source lib.sh

usage (){
    echo "Retrieve SRA metadata from the SRA database"
    echo "  -u  directory for SRA metadata XML dump"
    exit 0
}

[[ $# -eq 0 ]] && usage

while getopts "hu:" opt; do
    case $opt in
        h)
            usage ;;
        u) 
            outdir=$OPTARG ;;
    esac 
done

if [[ -z $outdir ]]
then
    echo "Please specify an output directory (-u option)" >&2
    exit 1
fi

mkdir -p $outdir

fetch-metadata "$(get-latest-metadata-url)" $outdir
