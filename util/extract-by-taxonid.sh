#!/bin/bash

datfile=data/rnaseq/RNA-seq_sra.tab

arabidopsis="Arabidopsis thaliana"
yeast="Saccharomyces cerevisiae"
maize="Zea mays"

for species in "$arabidopsis" "$yeast" "$maize"
do
    awk -v FS="\t" -v s="$species" \
        '$8 == s {print $2, $8}' \
        "$datfile" |
    sort -u
done
