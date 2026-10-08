#!/bin/bash
if [ $# -ne 3 ]
then 
    echo "Must have 3 arguments"
    exit 1
fi

dir=$1
malicious_dir=$2
interval_secs=$3
whitelist=whitelist.txt

check_files() {
    for file in "$dir"/*
    do
        if [ -f "$file" ]
        then
            if grep -q -s -x -F "$(basename "$file")" "$whitelist"
            then
                continue
            elif echo "$file" | grep -q -E "\.exe$|\.bat$|\.vbs$|\.scr$|\.ps1$"
            then
                echo "$(basename "$file") is malicious and it is DELETED"
                cp "$file" "$malicious_dir" && rm "$file"
            elif  grep -q -E -i "virus|trojan|malware|worm|ransomware" "$file"
            then
                echo "$(basename "$file") is malicious and it is DELETED"
                cp "$file" "$malicious_dir" && rm "$file"
            fi
        fi
    done
}

while true
do
ls -l "$dir" > directory-info.new
if [ ! -f directory-info.last ] || ! cmp -s directory-info.last directory-info.new
then 
    check_files
    ls -l "$dir" > directory-info.last
fi
sleep "$interval_secs"
done 

