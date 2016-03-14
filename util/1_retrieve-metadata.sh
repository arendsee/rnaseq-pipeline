#!/bin/bash

source functions.sh

fetch-metadata "$(get-latest-metadata-url)" $1
