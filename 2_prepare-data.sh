#!/bin/bash
set -u
set -e

usage (){
    echo "Load RNA-seq data"
    echo "  -e EXP  experiment data"
    echo "  -s SAM  sample data"
    echo "  -d STD  study data"
    echo "  -a ATR  sample attributes data"
    echo "  -x XML  The directory where the metadata should be"
    echo "  -r RNA  output RNA data directory"
    exit 0
}

[[ $# -eq 0 ]] && usage

while getopts "he:s:d:a:x:r:" opt; do
    case $opt in
        h) 
            usage ;;
        e) 
            exp=$OPTARG ;;
        s)
            sam=$OPTARG ;;
        d)
            std=$OPTARG ;;
        a)
            atr=$OPTARG ;;
        x)
            xml=$OPTARG ;;
        r)
            rna=$OPTARG ;;
    esac 
done

source lib.sh

[[ -d ${rna} ]] || mkdir -p ${rna}

extract-experiment             ${xml} > ${exp} &
extract-sample                 ${xml} > ${sam} &
extract-study                  ${xml} > ${std} &
from-sample-extract-attributes ${xml} > ${atr} &

wait
