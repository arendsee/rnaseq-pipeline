#!/bin/bash

sample=$1          # sample.tab
sra_accessions=$2  # SRA_Accessions.tab
taxid=$3           # 3702

if [[ -z $sample || -z $sra_accessions || -z $taxid ]]; then
cat << EOF
USAGE: $0 <SAMPLES> <SRA_TABLE> <TAXID>
Where
    * SAMPLES and SRA_TABLE are tab delimited files
    * column 1 of SAMPLES is the sra sample id
    * column 12 of SRA_TABLE is the SRA sample id
    * SRA_TABLE is from ftp://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/SRA_Accessions.tab
    * TAXID is a NCBI taxonomy id e.g.
      - 3702 for Arabidopsis thaliana
      - 4932 for yeast
DESCRIPTION:
    select from SRA_TABLE by sample_id where taxid == TAXID 
EOF
exit 1
fi

echo -ne "Sample_id\t"
head -1 $sra_accessions
join -1 1 -2 12 -t $'\t' \
    <(cut -f1,3 $sample |
      awk -v taxid=$taxid '$2 == taxid {print $1}' |
      sort -u) \
    <(sort -t  $'\t' -k12,12 $sra_accessions)
