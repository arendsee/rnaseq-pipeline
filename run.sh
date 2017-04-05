#!/bin/bash
set -u

source util.sh

usage (){
cat <<EOF
Extract FPKM results for a given set of sample ids
REQUIRED ARGUMENTS
  -s file of sample ids
  -t transcriptome index or fasta (*.fna) file
  -m temporary output directory of huge files (e.g. fastq)
  -o directory of output of final data
  -c the directory where fastq-dump caches downloaded files
EOF
    exit 0
}

# print help with no arguments
[[ $# -eq 0 ]] && usage

stat=0
for cmd in kallisto xmlstarlet wget
do
    if ! type $cmd
    then
        echo "'$cmd' not found in path" >&2
        stat=1
    fi
done
die_on_failure $stat "Missing required commands ... exiting"

transcriptome=
sample_ids=
tmpdir=.
outdir=final-output
while getopts "ht:s:m:o:c:" opt; do
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

run-has-been-processed (){
    ls "$outdir" | grep $1 > /dev/null
    echo $?
}

if [[ ! -r $runids ]]
then
    echo -n "Retrieving run ids ... " >&2
    ./1_get_runids.sh -i "$sample_ids" -s $outdir/samples > $runids
    printf "found %s ids\n\n" $(wc -l $runids) >&2
fi

while read id
do
    echo "---- $id ----" >&2
    if [[ $(run-has-been-processed $id) -eq 0 ]]
    then
        echo "   Run has already been processed ... skipping"
    else
        echo "   retrieving fastq file" >&2
        time ./2_runid-to-fastq.sh \
            -r $id                 \
            -o "$tmpdir"
        die_on_failure $? "   failed to retrieve fastq file ... exiting"
        echo "   aligning to index" >&2
        time ./3_fastq-to-FPKM.sh \
            -r $id                \
            -t $transcriptome     \
            -m $tmpdir            \
            -o $outdir            \
            -c
        die_on_failure $? "   failed to convert fastq to FPKM ... exiting"
        echo >&2
    fi
done < $runids
