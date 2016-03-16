#!/bin/bash
set -u

source shflags.sh
source lib.sh

DEFINE_string 'output-directory' 'data/metadata' 'directory for SRA metadata XML dump' 'u'

FLAGS_HELP="Retrieve SRA metadata from the SRA database"

FLAGS "$@" || exit 1
[[ ${FLAGS_help} -eq ${FLAGS_TRUE} ]] && exit 0

if [[ -z ${FLAGS_output_directory} ]]
then
    echo "Please specify an output directory (-u option)" >&2
    exit 1
fi

mkdir -p ${FLAGS_output_directory}

fetch-metadata "$(get-latest-metadata-url)" ${FLAGS_output_directory}
