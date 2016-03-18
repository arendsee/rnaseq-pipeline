#!/bin/bash
set -u

usage (){
cat << EOF
Map reads of a single fastq file to a transcriptome creating a FPKM table
Required Arguments
  -r FILE a single fastq file
  -t FILE a fasta transcriptome file
  -o FILE an FPKM output table
  -c      delete fastq data
EOF
exit 0
}

[[ $# -eq 0 ]] && usage

clean=
while getopts "hcr:o:t:" opt; do
    case $opt in
        h)
            usage ;;
        r) 
            runid=$OPTARG ;;
        t)
            transcriptome=$OPTARG ;;
        o) 
            output=$OPTARG ;;
        c)
            clean=1 ;;
    esac 
done

mkdir -p final-output


# build an index of the transcriptome for use by kallisto
if [[ $transcriptome =~ fna$ ]]
then
    kallisto quant --index="$transcriptome"
    transcriptome=$(sed 's/\.fna$/.index/' <<< $transcriptome)
fi


# align reads to transcriptome index
kallisto quant                      \
    --index="$transcriptome"        \
    --bootstrap-samples=100         \
    --output-dir=${runid}-bootstrap \
    --threads=8                     \
    ${runid}_*


# move results and run details into results folder
mv ${runid}-bootstrap/abundance.tsv final-output/${runid}.tsv
mv ${runid}-bootstrap/run_info.json final-output/${runid}.json


# clean up
[[ $clean -eq 1 ]] && rm ${runid}*.fastq
[[ $clean -eq 1 ]] && rm -rf ${runid}-bootstrap
