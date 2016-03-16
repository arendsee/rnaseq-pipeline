#!/bin/bash

# This script will retrieve metadata for all SRA datasets in the SRA database.
# Output will be the following files in the working directory.

# $PWD/
# |-- experiment.tab
# |-- rnaseq/
# |   |-- experiment.tab
# |   |-- RNA-seq_sra.tab
# |   |-- sample.tab
# |   \-- study.tab
# |-- RNA-Seq_ids.txt
# |-- sample-attributes.tab
# |-- sample-count.tab
# |-- sample.tab
# |-- species-per-id.tab
# \-- study.tab


# ===================================================================
# Global variables
# -------------------------------------------------------------------

METADATA_URL="ftp://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/"

METADATA_PATTERN='NCBI_SRA_Metadata_Full_20\d{6}\.tar\.gz'


# ===================================================================
# Function declarations
# -------------------------------------------------------------------

file2id (){
    sraid=${1##*/}
    sraid=${sraid/.*/}
    echo $sraid
}

make-header (){
    echo "$@" | tr ' ' '\t'
}

get-latest-metadata-url (){
    curl -ls $METADATA_URL |
        grep -P $METADATA_PATTERN |
        sort |
        tail -1 |
        sed "s,^,${METADATA_URL},"
}

fetch-metadata (){
    url=$1
    name=$2
    base=$(basename $1 | sed 's/\..*//')
    curl -o ${base}.tar.gz "$url"
    if [ $? -ne 0 ]; then
        echo "Failed to open '$url'" >&2
        rm
        exit 1
    fi
    echo 'Unzipping ${name}.tar.gz}'
    gunzip ${base}.tar.gz
    echo 'Extracting ${name}.tar}'
    tar -xf ${base}.tar
    [[ -d ${name} ]] && rmdir ${name}
    mv ${base} ${name}
    cd $name
    rm SRA_Accessions SRA_Files_Md5 SRA_Run_Members
    echo "Removing gratuitous nesting ${name}"
    find . -name '*.xml' | xargs -I {} mv {} . 2> /dev/null
    echo 'Removing unneeded directories'
    find . -type d | xargs rmdir 2> /dev/null
    cd -
    echo 'Removing the tar file'
    rm ${name}.tar
}

extract-study (){
    make-header study_id study_title abstract
    find $1 -name '*study.xml' | while read f
    do
        xmlstarlet sel \
            -t \
            -m '/STUDY_SET/STUDY' \
                -v 'IDENTIFIERS/PRIMARY_ID' \
                -o $'\t' \
                -v 'DESCRIPTOR/STUDY_TITLE' \
                -o $'\t' \
                -v 'DESCRIPTOR/STUDY_ABSTRACT' \
                -n \
            -b $f
    done
}

extract-sample (){
    make-header sample_id sample_title taxon_id species
    find $1 -name '*sample.xml' | while read f
    do
        xmlstarlet sel \
            -t \
            -m '/SAMPLE_SET/SAMPLE' \
                -v 'IDENTIFIERS/PRIMARY_ID' \
                -o $'\t' \
                -v 'TITLE' \
                -o $'\t' \
                -v 'SAMPLE_NAME/TAXON_ID' \
                -o $'\t' \
                -v 'SAMPLE_NAME/SCIENTIFIC_NAME' \
                -n \
            -b $f
    done
}

extract-experiment (){
    make-header experiment_id sample_id design_description library_name library_strategy library_source instrument_model
    find $1 -name '*experiment.xml' | while read f
    do
        xmlstarlet sel \
            -t \
            -m '/EXPERIMENT_SET/EXPERIMENT' \
                -v 'IDENTIFIERS/PRIMARY_ID' \
                -o $'\t' \
                -v 'DESIGN/SAMPLE_DESCRIPTOR/IDENTIFIERS/PRIMARY_ID' \
                -o $'\t' \
                -v 'DESIGN/DESIGN_DESCRIPTION' \
                -o $'\t' \
                -v 'DESIGN/LIBRARY_DESCRIPTOR/LIBRARY_NAME' \
                -o $'\t' \
                -v 'DESIGN/LIBRARY_DESCRIPTOR/LIBRARY_STRATEGY' \
                -o $'\t' \
                -v 'DESIGN/LIBRARY_DESCRIPTOR/LIBRARY_SOURCE' \
                -o $'\t' \
                -v 'PLATFORM//INSTRUMENT_MODEL' \
                -n \
            -b $f
    done
}

from-sample-extract-attributes (){
    make-header sample_id sample_tag sample_value
    find $1 -name '*sample.xml' | while read f
    do
        xmlstarlet sel \
            -t \
            -m '/SAMPLE_SET/SAMPLE' \
                -o '___'$'\t' \
                -v 'IDENTIFIERS/PRIMARY_ID' -n \
                -m 'SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE' \
                    -v 'TAG' \
                    -o $'\t' \
                    -v 'VALUE' \
                    -n \
                -b \
            -b $f
    done |
        awk -v OFS="\t" -v FS="\t" '
            $1 == "___" {file=$2; id=$3}
            $1 != "___" {print file, id, $0}
        '
}
