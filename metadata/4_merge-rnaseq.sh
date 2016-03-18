#!/bin/bash
set -u

usage (){
    echo 'Merge RNA-seq data into single table'
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

./code/merge-rnaseq.R "$exp" "$sam" "$std" "$ids"
