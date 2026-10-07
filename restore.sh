#!/bin/bash
if [ $# -ne 2 ]
then
    echo "Must have 2 arguments"
    exit 1
fi

dir=$1
malicious_dir=$2

while true 
do 
    i=1

    for file in "$malicious_dir"/*
    do
    if [ -f "$file" ]
    then
        echo "$i. $(basename "$file")"
        i=`expr $i + 1`
    else 
        echo "No malicious files to review."
        exit
    fi
    done

    read -p "Pick a file by number: " choice
    if [ "$choice" -ge 1 ] && [ "$choice" -le `expr $i - 1` ]
    then
    selected_file=$(ls "$malicious_dir" | head -n "$choice" | tail -n 1)
    read -p "• Input 1: Restore this file back into dir (it was a false positive)
            • Input 2: Permanently delete this file from malicious_dir (it was genuinely malicious)
            • Input 3: Leave this file as-is and go back to the list" input
    if [ "$input" -eq 1 ]
    then 
    cp "$malicious_dir/$selected_file" "$dir"
    rm "$malicious_dir/$selected_file"
    echo "Restored $selected_file to $dir."
    elif [ "$input" -eq 2 ]
    then
    rm "$malicious_dir/$selected_file"
    echo "$selected_file permanently deleted."
    elif [ "$input" -eq 3 ]
    then
    continue
    else
        echo "Invalid choice."
    fi
else
    echo "Invalid choice."
fi
done 