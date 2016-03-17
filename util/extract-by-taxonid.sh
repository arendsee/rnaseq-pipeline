#!/bin/bash

usage (){
    echo "Extract species-specific metadata tables from full table"
    echo "USAGE: $0    <metadata-file> <taxonids>"
    echo "USAGE: $0 -n <metadata-file> <scientific_names>"
    echo "USAGE: $0 -r <metadata-file> <patterns>"
    exit 0
}

[[ $# -eq 0 ]] && usage

by_name= by_expression=
while getopts "hnr" opt; do
    case $opt in
        h)
            usage ;;
        n)
            by_name=1
            shift ;;
        r)
            by_expression=1
            shift ;;
    esac 
done

datfile=$1
shift

for species in $@
do
    out=${species}.tab
    echo "Extracting $species" >&2
    head -1 $datfile > "$out"
    if [[ $by_name -eq 1 ]]; then
        awk -v s="$species" 'BEGIN{FS="\t"; OFS=FS} $14 == s' $datfile >> "$out"
    elif [[ $by_expression -eq 1 ]]; then
        awk -v s="$species" 'BEGIN{FS="\t"; OFS=FS} $14 ~ s' $datfile >> "$out"
    else
        awk -v s="$species" 'BEGIN{FS="\t"; OFS=FS} $13 == s' $datfile >> "$out"
    fi
done
