#!/bin/bash

source util/functions.sh

D_XML=$1

[[ -d ${D_XML} ]] || fetch-metadata "$(get-latest-metadata-url)" ${D_XML}
