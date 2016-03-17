#!/bin/bash
set -u

source lib.sh

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

# TODO remove the hard-coding
sra_accessions=data/SRA_Accessions.tab

if [[ ! -r "$sra_accessions" ]]
then
    wget ftp://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/SRA_Accessions.tab 
fi

(
    LANG=C # make sort very fast
    idmap=$ids
    echo -e "experiment_id\tsample_id\tstudy_id\tbiosample\tbioproject\tsubmission_id" > $idmap
    awk -v sf=$sra_accessions \
        -v ef=$exp \
        'BEGIN{FS="\t"; OFS=FS}
         FILENAME == ef && $4 == "RNA-Seq" {a[$1]++}
         FILENAME == sf && $3 == "live" && ($11 in a || ($7 == "EXPERIMENT" && $1 in a)) {
            if($7 == "EXPERIMENT"){
                experiment=$1
            } else {
                experiment=$11
            }
            sample=$12
            study=$13
            biosample=$18
            bioproject=$20
            submission=$2
            if(sample != "-"){
                print experiment, sample, study, biosample, bioproject, submission
            } else {
                print experiment " is missing a sample" > "log"
            }
         }
         ' "$exp" "$sra_accessions" | sort -u >> "$idmap"

    for f in "$exp" "$sam" "$std"
    do
        out=$rnaseq_dir/`basename $f`
        head -1 $f > $out
    done

    out=$rnaseq_dir/`basename $exp`
    join <(tail -n +2 $idmap | cut -f 1 | sort -u) \
         <(tail -n +2 $exp | sort -k1,1 $exp) -t $'\t' >> $out &

    out=$rnaseq_dir/`basename $sam`
    join <(tail -n +2 $idmap | cut -f 2 | sort -u) \
         <(tail -n +2 $sam | sort -k1,1) -t $'\t' >> $out &

    out=$rnaseq_dir/`basename $std`
    join <(tail -n +2 $idmap | cut -f 3 | sort -u) \
         <(tail -n +2 $std | sort -k1,1) -t $'\t' >> $out &

    wait
)
