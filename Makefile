.ONESHELL:

DATA_DIR=$(PWD)/data
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

${RNASEQ_TABLE} : ${R_EXP} ${R_SAM} ${R_STD} ${R_ATR}
	(
		cd util
		4_merge.R ${R_STD} ${R_SAM} ${R_EXP} 
	)

${R_EXP} ${R_SAM} ${R_STD} ${R_ATR} : ${RNASEQ_DIR} ${D_EXP} ${D_SAM} ${D_STD} ${D_ATR}
	(
		cd util
		bash 3_extract-rnaseq.sh \
			-o ${RNASEQ_DIR} \
			-e ${D_EXP} \
			-s ${D_SAM} \
			-d ${D_STD}
	)

${D_EXP} ${D_SAM} ${D_STD} ${D_ATR} : ${D_XML} ${DATA_DIR}
	(
		cd util
		bash 2_prepare-data.sh \
			-e ${D_EXP} \
			-s ${D_SAM} \
			-d ${D_STD} \
			-a ${D_ATR} \
			-x ${D_XML} \
			-r ${RNASEQ_DIR}
	)

${D_XML}: ${DATA_DIR}
	(
		cd util
		bash 1_retrieve-metadata.sh ${D_XML}	
	)

${DATA_DIR}:
	mkdir -p ${DATA_DIR}

.PHONY: clean
clean:
	rm -rf data
