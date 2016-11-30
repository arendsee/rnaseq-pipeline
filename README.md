# Kallisto-based RNA-seq pipeline

Given a list of SRA sample ids and a reference transcriptome, these scripts
will download the raw SRA data, count estimate transcript expression (with
Kallisto), print FPKM tables, and delete the raw SRA data.

# Usage

```
./run.sh                      \
 -s sample-ids.tct            \
 -t transcriptome.fna         \
 -m /path/to/temp/dir         \
 -o /path/to/final/output/dir \
 -c /path/to/fastq-dump/cache
```
