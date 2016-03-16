#!/bin/bash
set -u
set -e

if [[ ! -r shflags.sh ]]
then 
    git clone https://github.com/kward/shflags
    cp shflags/src/shflags shflags.sh
    rm -rf shflags
fi

DATA_DIR=${PWD}/data
D_XML=${DATA_DIR}/metadata-dump

D_EXP=${DATA_DIR}/experiment.tab
D_SAM=${DATA_DIR}/sample.tab
D_STD=${DATA_DIR}/study.tab
D_ATR=${DATA_DIR}/sample-attributes.tab

RNASEQ_DIR=${DATA_DIR}/rnaseq
RNASEQ_TABLE=${RNASEQ_DIR}/RNA-seq_sra.tab

R_EXP=${RNASEQ_DIR}/experiment.tab
R_SAM=${RNASEQ_DIR}/sample.tab
R_STD=${RNASEQ_DIR}/study.tab
R_ATR=${RNASEQ_DIR}/sample-attributes.tab

mkdir -p ${DATA_DIR}
mkdir -p ${RNASEQ_DIR}

# bash 1_retrieve-metadata.sh ${D_XML}
#
# bash 2_prepare-data.sh \
#     -e ${D_EXP} \
#     -s ${D_SAM} \
#     -d ${D_STD} \
#     -a ${D_ATR} \
#     -x ${D_XML} \
#     -r ${RNASEQ_DIR}
#
# bash 3_extract-rnaseq.sh \
#     -o ${RNASEQ_DIR} \
#     -e ${D_EXP} \
#     -s ${D_SAM} \
#     -d ${D_STD}

Rscript 4_merge.R ${R_STD} ${R_SAM} ${R_EXP} 
