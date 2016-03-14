DATA_DIR=$(PWD)/data
D_XML=${DATA_DIR}/metadata-dump

D_EXP=${DATA_DIR}/experiment.tab
D_SAM=${DATA_DIR}/sample.tab
D_STD=${DATA_DIR}/study.tab
D_ATR=${DATA_DIR}/sample-attributes.tab

RNASEQ_DIR=${DATA_DIR}/rnaseq
RNASEQ_TABLE=${RNASEQ_DIR}/RNA-seq_sra.tab



${D_EXP} ${D_SAM} ${D_STD} ${D_ATR} : ${D_XML} ${DATA_DIR}
	bash util/prepare-data.sh \
		-e ${D_EXP} \
		-s ${D_SAM} \
		-d ${D_STD} \
		-a ${D_ATR} \
		-x ${D_XML} \
		-r ${RNASEQ_DIR}

${D_XML}: ${DATA_DIR}
	bash util/retrieve-metadata.sh ${D_XML}	

${DATA_DIR}:
	mkdir -p ${DATA_DIR}

.PHONY: clean
clean:
	rm -rf data
