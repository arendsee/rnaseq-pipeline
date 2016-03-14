#!/bin/bash
set -u
set -e

while getopts "he:s:d:a:x:r:" opt; do
    case $opt in
        h)
            echo "Load RNA-seq data"
            echo "REQUIRED ARGUMENTS"
            echo "  -e EXP  experiment data"
            echo "  -s SAM  sample data"
            echo "  -d STD  study data"
            echo "  -a ATR  sample attributes data"
            echo "  -x XML  The directory where the metadata should be"
            echo "  -r RNA  output RNA data directory"
            exit 0 ;;
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

source functions.sh

[[ -d ${rna} ]] || mkdir ${rna}

[[ -d ${exp} ]] || extract-experiment             ${xml} > ${exp}
[[ -d ${sam} ]] || extract-sample                 ${xml} > ${sam}
[[ -d ${std} ]] || extract-study                  ${xml} > ${std}
[[ -d ${atr} ]] || from-sample-extract-attributes ${xml} > ${atr}

extract-rnaseq-data ${rna} ${exp} ${sam} ${std}
