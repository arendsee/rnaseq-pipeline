#!/bin/bash
set -u

usage (){
cat << EOF
Read file of SRA sample_ids (SRS*), output run_ids (SRR*)
Required Arguments
  -i SAMPLES file of sample ids
EOF
exit 0
}

[[ $# -eq 0 ]] && usage

while getopts "hi:o:" opt; do
    case $opt in
        h)
            usage ;;
        i) 
            ids=$OPTARG ;;
        o)
            output=$OPTARG ;;
    esac 
done

eusrc() {
    db=$1
    term=$2
    retmax=${3-1000}
    src_url="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"
    url="$src_url?db=$db&term=$term&retmax=$retmax&usehistory=y"
    out=$(wget -qO /dev/stdout $url | 
          xmlstarlet sel --template      \
            --match '/eSearchResult'     \
                --value-of 'WebEnv' --nl \
                --value-of 'QueryKey'    \
            --break 2> /dev/null)
    webenv=$(echo $out | awk '{print $1}')
    query_key=$(echo $out | awk '{print $2}')
    printf "db=%s&WebEnv=%s 1 %s %s" $db $webenv $query_key $retmax
}

eufet() {
    read opts first_key nkeys retmax
    base="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"
    for k in `seq $first_key $nkeys`; do
        loopopts="retmax=$retmax&query_key=$k"
        cmd="$base?$opts&$loopopts"
        wget -qO /dev/stdout "$cmd"
    done
}

mkdir -p samples

while read id
do
    eusrc sra $id | eufet |
        xmlstarlet fo | tee samples/${id}.xml |
        xmlstarlet sel --template \
            --match 'EXPERIMENT_PACKAGE_SET/EXPERIMENT_PACKAGE/RUN_SET/RUN/IDENTIFIERS' \
                --value-of 'PRIMARY_ID' --nl \
            --break
    sleep 1 # so they don't block my ip address
done < "$ids" | sort -u > "$output"