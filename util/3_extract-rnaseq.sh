#!/bin/bash
set -u

__version=v0.1

function usage ()
{
    echo "Usage : $0 [options] [--]

    Extract RNA-seq data from metadata

    Options:
    -h|help	    Display this message
    -v|version	Display script version"
}

while getopts ":hv" opt
do
    case $opt in

    h|help ) usage; exit 0 ;;

    v|version ) echo "$0 $__version"; exit 0 ;;

    o|outdir ) rnaseq_dir=$OPTARG ;; 

    e|experiment ) d_exp=$OPTARG ;;

    s|sample ) d_sam=$OPTARG ;;

    d|study ) d_std=$OPTARG ;;

    * ) echo -e "\n  Unsupported option : $OPTARG\n"
        usage; exit 1 ;;
    esac
done

[[ -d $rnaseq_dir ]] || mkdir $rnaseq_dir
for f in $d_exp $d_sam $d_std
do
    out=$rnaseq_dir/`basename $f`
    head -1 $f > $out
    join -t $'\t' \
        <(awk -F"\t" '$6 == "RNA-Seq" {print $1}' $d_exp | sort -u) \
        <(sort $f) >> $out &
done
wait
