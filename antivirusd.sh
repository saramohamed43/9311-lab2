#!/bin/bash
if [ $# -ne 3 ]
then 
    echo "Must have 3 arguments"
    exit 1
fi

dir=$1
malicious_dir=$2
interval_secs=$3

for file in "$dir"/*
    do
        if [ -f "$file" ]
        then
            if echo "$file" | grep -q -E "\.exe$|\.bat$|\.vbs$|\.scr$|\.ps1$"
            then
            echo "$(basename "$file") is malicious and it is DELETED"
            cp "$file" "$malicious_dir"
            rm "$file"
            elif  grep -q -E -i "virus|trojan|malware|worm|ransomware" "$file"
            then
                echo "$(basename "$file") is malicious and it is DELETED"
                cp "$file" "$malicious_dir"
                rm "$file"
            fi
        else
            continue
        fi
done
