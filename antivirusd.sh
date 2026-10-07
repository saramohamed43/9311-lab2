#!/bin/bash
if [ $# -ne 3 ]
then 
    echo "Must have 3 arguments"
    exit 1
fi

dir=$1
malicious_dir=$2
interval_secs=$3