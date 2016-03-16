#!/bin/bash
set -u

source shflags.sh
source lib.sh

FLAGS_HELP="Extract RNA-seq data from full metadata"

DEFINE_string 'rnaseq-dir' '' 'RNA-seq metadata output directory' 'o'
DEFINE_string 'experiment' '' 'Full experiment data filename'     'e'
DEFINE_string 'sample'     '' 'Full sample data filename'         's'
DEFINE_string 'study'      '' 'Full study data filename'          'd'
DEFINE_string 'idmap'      '' 'Map of ids: exp, sam, std, biosam, biopro, sra_id' 'i'

FLAGS "$@" || exit 1
[[ ${FLAGS_help} -eq ${FLAGS_TRUE} ]] && exit 0

[[ -d ${FLAGS_rnaseq_dir} ]] || mkdir ${FLAGS_rnaseq_dir}

for f in "${FLAGS_experiment}" "${FLAGS_sample}" "${FLAGS_study}"
do
    if [[ ! -r $f ]]
    then
        printf "Cannot open '%s'" $f >&2
        exit 1
    fi
done

sra_accessions=data/SRA_Accessions.tab

if [[ ! -r "$sra_accessions" ]]
then
    wget ftp://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/SRA_Accessions.tab 
fi

(
    LANG=C
    idmap=${FLAGS_idmap}
    echo -e "experiment_id\tsample_id\tstudy_id\tbiosample\tbioproject\tsubmission_id" > $idmap
    awk -v sf=$sra_accessions     \
        -v ef=${FLAGS_experiment} \
        'BEGIN{FS="\t"; OFS=FS}
         FILENAME == ef && $5 == "RNA-Seq" {a[$1]++}
         FILENAME == sf && $3 == "live" && $11 in a {
            experiment=$11
            sample=$12
            study=$13
            biosample=$18
            bioproject=$20
            submission=$2
            print experiment, sample, study, biosample, bioproject, submission
         }
         ' "${FLAGS_experiment}" "$sra_accessions" | sort -u >> "$idmap"

    for f in "${FLAGS_experiment}" "${FLAGS_sample}" "${FLAGS_study}"
    do
        out=${FLAGS_rnaseq_dir}/`basename $f`
        head -1 $f > $out
    done

    out=${FLAGS_rnaseq_dir}/`basename ${FLAGS_experiment}`
    join <(cut -f 1 $idmap | sort -u) \
         <(sort -k1,1 ${FLAGS_experiment}) --header -t $'\t' >> $out &

    out=${FLAGS_rnaseq_dir}/`basename ${FLAGS_sample}`
    join <(cut -f 2 $idmap | sort -u) <(sort -k1,1 ${FLAGS_sample}) --header -t $'\t' >> $out &

    out=${FLAGS_rnaseq_dir}/`basename ${FLAGS_study}`
    join <(cut -f 3 $idmap | sort -u) <(sort -k1,1 ${FLAGS_study}) --header -t $'\t' >> $out &

    wait
)
