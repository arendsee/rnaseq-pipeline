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


# TODO
(thanks to @aseetharam for pointing out these issues)
 - [ ] check for dependencies: xmlstarlet, sratoolkit, kallisto and aspera packages to be installed before you run them
 - [ ] find aspera key automatically (e.g. with `which` of `find`) rather than hard-coding it
 - [ ] allow the user to specify the temporary file directory (currently hardcoded to `$HOME/ncbi/public/sra`), make it default to `$PWD`.
 - [ ] if the performance penalty is negligible, compress fastq files `--gzip` option in `fastq-dump` command (kallisto can use these directly)
 - [ ] allow user to set the number of threads for kallisto (currently set to `8`)
 - [ ] use `gnu-parallel` where applicable (eg. when checking for paired-end or single-end reads)
