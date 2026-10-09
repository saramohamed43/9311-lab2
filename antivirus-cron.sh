#!/bin/bash
if [ $# -ne 2 ]
then 
    echo "Must have 2 arguments"
    exit 1
fi

dir=$1
malicious_dir=$2
whitelist=/home/sara-os/9311-lab2/whitelist.txt
last_file=/home/sara-os/9311-lab2/directory-info.last
new_file=/home/sara-os/9311-lab2/directory-info.new

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

ls -l "$dir" > "$new_file"
if [ ! -f "$last_file" ] || ! cmp -s "$last_file" "$new_file"
then 
    check_files
    ls -l "$dir" > "$last_file"
fi