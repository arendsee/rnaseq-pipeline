#!/bin/bash
set -u

NCBI_DIR=$HOME/ncbi/public/sra

usage (){
cat << EOF
Map reads of a single fastq file to a transcriptome creating a FPKM table
Required Arguments
  -r a run id, which is the basename of a[n] fastq file[s]
  -t a fasta transcriptome file
  -m directory in which fastq files and temporary output is stored
  -o final output directory
  -c delete fastq data
  -d the directory where fastq-dump caches downloaded files
EOF
exit 0
}

[[ $# -eq 0 ]] && usage

clean=
while getopts "hcr:o:t:m:d:" opt; do
    case $opt in
        h)
            usage ;;
        r) 
            runid=$OPTARG ;;
        t)
            transcriptome=$OPTARG ;;
        m) 
            tmpdir=$OPTARG ;;
        o)
            outdir=$OPTARG ;;
        c)
            clean=1 ;;
    esac 
done

mkdir -p $outdir


# build an index of the transcriptome for use by kallisto
if [[ $transcriptome =~ fna$ ]]
then
    kallisto index --index="$transcriptome"
    transcriptome=$(sed 's/\.fna$/.index/' <<< $transcriptome)
fi


# align reads to transcriptome index
kallisto_outdir=${tmpdir}/${runid}-bootstrap
kallisto quant                      \
    --index="$transcriptome"        \
    --bootstrap-samples=100         \
    --output-dir="$kallisto_outdir" \
    --threads=8                     \
    ${tmpdir}/${runid}_*


# move results and run details into results folder
mv $kallisto_outdir/abundance.tsv $outdir/${runid}.tsv
mv $kallisto_outdir/abundance.h5 $outdir/${runid}.h5
mv $kallisto_outdir/run_info.json $outdir/${runid}.json


# clean up
[[ $clean -eq 1 ]] && rm ${tmpdir}/${runid}*.fastq
[[ $clean -eq 1 ]] && rm -rf $kallisto_outdir
[[ $clean -eq 1 && -d "$NCBI_HOME" ]] && rm -f "$NCBI_HOME"/${runid}*
