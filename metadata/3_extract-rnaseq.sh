#!/bin/bash
set -u

source code/lib.sh

usage (){
    echo 'Extract RNA-seq data from full metadata'
    echo '  -o RNA-seq metadata output directory'
    echo '  -e Full experiment data filename'
    echo '  -s Full sample data filename'
    echo '  -d Full study data filename'
    echo '  -i Map of ids: exp | sam | std | biosam | biopro | sub'
    exit 0
}

[[ $# -eq 0 ]] && usage

while getopts "ho:e:s:d:i:" opt; do
    case $opt in
        h)
            usage ;;
        o) 
            rnaseq_dir=$OPTARG
            mkdir -p $rnaseq_dir
            ;;
        e) 
            exp=$OPTARG ;;
        s) 
            sam=$OPTARG ;;
        d) 
            std=$OPTARG ;;
        i) 
            ids=$OPTARG ;;
    esac 
done

assert-files-are-readable "$exp" "$sam" "$std"

sra_accessions=data/SRA_Accessions.tab

if [[ ! -r "$sra_accessions" ]]
then
    wget -O $sra_accessions ftp://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/SRA_Accessions.tab 
fi

extract-rnaseq-files $rnaseq_dir $exp $sam $std $ids $sra_accessions
