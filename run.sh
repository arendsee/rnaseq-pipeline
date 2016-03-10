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

set -u

home=$PWD
data_dir=$home/data
util_dir=$home/util

metadata_url="ftp://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata"
base=NCBI_SRA_Metadata_20160226
d_xml=$data_dir/$base
d_exp=$data_dir/experiment.tab
d_sam=$data_dir/sample.tab
d_std=$data_dir/study.tab
datfiles="$d_exp $d_sam $d_std"

sample_count=$data_dir/sample-count.tab

# all SRA ids corresponding to an RNA-seq study
rnaseq_dir=$data_dir/rnaseq
rnaseq_ids=$data_dir/RNA-Seq_ids.txt
RNAseq_table=$rnaseq_dir/RNA-seq_sra.tab

file2id (){
    sraid=${1##*/}
    sraid=${sraid/.*/}
    echo $sraid
}

# # download and extract SRA data if necessary
# if [ ! -d $d_xml ]; then
#     wget "$metadata_url/${base}.tar.gz"
#     if [ $? -ne 0 ]; then
#         echo "Failed to open URL" >&2
#         exit 1
#     fi
#     gunzip ${base}.tar.gz
#     tar -xf ${base}.tar
#     cd $base
#     rm SRA_Accessions SRA_Files_Md5 SRA_Run_Members
#     find . -name '*.xml' | xargs -I {} mv {} . 2> /dev/null
#     find . -type d | xargs rmdir 2> /dev/null
#     cd ..
#     rm ${base}.tar
#     mv $base $d_xml
# fi
#
#
# # ======================================================
# # Parse *.study.xml files
# # ======================================================
# echo -e "SRA_id\tstudy_id\tstudy_title\tabstract" > $d_std
# find $d_xml -name '*study.xml' | while read f
# do
#     sraid=`file2id $f`
#     xmlstarlet sel \
#         -t \
#         -m '/STUDY_SET/STUDY' \
#             -o $sraid \
#             -o $'\t' \
#             -v 'IDENTIFIERS/PRIMARY_ID' \
#             -o $'\t' \
#             -v 'DESCRIPTOR/STUDY_TITLE' \
#             -o $'\t' \
#             -v 'DESCRIPTOR/STUDY_ABSTRACT' \
#             -n \
#         -b $f
# done >> $d_std &
#
#
#
# # ======================================================
# # Parse *.sample.xml files
# # ======================================================
# echo -e "SRA_id\tsample_id\tsample_title\ttaxon_id\tspecies" > $d_sam
# find $d_xml -name '*sample.xml' | while read f
# do
#     sraid=`file2id $f`
#     xmlstarlet sel \
#         -t \
#         -m '/SAMPLE_SET/SAMPLE' \
#             -o $sraid \
#             -o $'\t' \
#             -v 'IDENTIFIERS/PRIMARY_ID' \
#             -o $'\t' \
#             -v 'TITLE' \
#             -o $'\t' \
#             -v 'SAMPLE_NAME/TAXON_ID' \
#             -o $'\t' \
#             -v 'SAMPLE_NAME/SCIENTIFIC_NAME' \
#             -n \
#         -b $f
# done >> $d_sam &
#
#
# # ======================================================
# # Parse *.sample.xml files extracting attributes
# # ======================================================
# echo -e "SRA_id\tsample_id\tsample_tag\tsample_value" > sample-attributes.tab
# find $d_xml '*sample.xml' | while read f
# do
#     sraid=`file2id $f`
#     xmlstarlet sel \
#         -t \
#         -m '/SAMPLE_SET/SAMPLE' \
#             -o '___'$'\t' \
#             -o $sraid \
#             -o $'\t' \
#             -v 'IDENTIFIERS/PRIMARY_ID' -n \
#             -m 'SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE' \
#                 -v 'TAG' \
#                 -o $'\t' \
#                 -v 'VALUE' \
#                 -n \
#             -b \
#         -b $f
# done |
#     awk -v OFS="\t" -v FS="\t" '
#         $1 == "___" {file=$2; id=$3}
#         $1 != "___" {print file, id, $0}
#     ' >> sample-attributes.tab &
#
#
# # ======================================================
# # Parse *.experiment.xml
# # ======================================================
# echo -e "SRA_id\texperiment_id\tsample_id\tdesign_description\tlibrary_name\tlibrary_strategy\tlibrary_source\tinstrument_model" > $d_exp
# find $d_xml '*experiment.xml' | while read f
# do
#     sraid=`file2id $f`
#     xmlstarlet sel \
#         -t \
#         -m '/EXPERIMENT_SET/EXPERIMENT' \
#             -o $sraid \
#             -o $'\t' \
#             -v 'IDENTIFIERS/PRIMARY_ID' \
#             -o $'\t' \
#             -v 'DESIGN/SAMPLE_DESCRIPTOR/IDENTIFIERS/PRIMARY_ID' \
#             -o $'\t' \
#             -v 'DESIGN/DESIGN_DESCRIPTION' \
#             -o $'\t' \
#             -v 'DESIGN/LIBRARY_DESCRIPTOR/LIBRARY_NAME' \
#             -o $'\t' \
#             -v 'DESIGN/LIBRARY_DESCRIPTOR/LIBRARY_STRATEGY' \
#             -o $'\t' \
#             -v 'DESIGN/LIBRARY_DESCRIPTOR/LIBRARY_SOURCE' \
#             -o $'\t' \
#             -v 'PLATFORM//INSTRUMENT_MODEL' \
#             -n \
#         -b $f
# done >> $d_exp &



# # ======================================================
# # Count the number of samples per submission
# # ======================================================
# wait
# echo -e "SRA_id\tsamples" > $sample_count
# cut -f1 $d_sam |
#     uniq -c |
#     awk 'BEGIN{OFS="\t"} NR > 1 {print $2, $1}' >> $sample_count
#
#
# # extract SRA ids from filenames
# for j in $datfiles
# do 
#     sed -ri 's/^[^\t]*\/([^.]+)[^\t]+/\1/' $j &
# done
#
# # count number of species per SRA id
# wait
# echo -e "SRA_id\tspecies_count" > species-per-id.tab
# awk -v FS="\t" -v OFS="\t" 'NR > 1 {print $1, $4}' $d_sam |
#     sort -u |
#     cut -f1 |
#     uniq -c |
#     awk -v OFS="\t" '{print $1, $2}' >> species-per-id.tab
 
 
# ====================================================================
# Extract RNA-Seq data
# ====================================================================
awk -F"\t" '$6 == "RNA-Seq" {print $1}' $d_exp |
    sort -u > $rnaseq_ids

[[ -d $rnaseq_dir ]] || mkdir $rnaseq_dir
for f in $datfiles
do
    out=$rnaseq_dir/`basename $f`
    head -1 $f > $out
    join -t $'\t' $rnaseq_ids <(sort $f) >> $out &
done
wait

# rm -rf $d_xml
