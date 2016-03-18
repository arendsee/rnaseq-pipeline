#!/bin/bash
set -u

usage (){
cat <<EOF
Extract FPKM results for a given set of sample ids
REQUIRED ARGUMENTS
  -s file of sample ids
  -t transcriptome index or fasta (*.fna) file
  -m temporary output directory of huge files (e.g. fastq)
  -o directory of output of final data
EOF
    exit 0
}

# print help with no arguments
[[ $# -eq 0 ]] && usage

transcriptome= sample_ids= tmpdir=. outdir=final-output
while getopts "ht:s:m:o:" opt; do
    case $opt in
        h)
            usage ;;
        t) 
            transcriptome=$OPTARG ;;
        s)
            sample_ids=$OPTARG ;;
        m)
            tmpdir=$OPTARG ;;
        o)
            outdir=$OPTARG ;;
    esac 
done

mkdir -p "$tmpdir"
mkdir -p "$outdir"

runids="$tmpdir"/runids.tab

./1_get_runids.sh -i "$sample_ids" > $runids

while read id
do
    ./2_runid-to-fastq.sh -r $id -o "$tmpdir"
    ./3_fastq-to-FPKM.sh -r $id -t $transcriptome -m $tmpdir -o $outdir -c
done < $runids
