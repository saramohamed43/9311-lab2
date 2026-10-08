#!/bin/bash
if [ $# -ne 2 ]
then
    echo "Must have 2 arguments"
    exit 1
fi

dir=$1
malicious_dir=$2
whitelist=whitelist.txt

while true 
do 
    i=1
    echo "Choose a file:"
    for file in "$malicious_dir"/*
    do
    if [ -f "$file" ]
    then
        echo "$i: $(basename "$file")"
        i=`expr $i + 1`
    else 
        echo "No malicious files to review."
        exit
    fi
    done

    echo -n "> "
    read choice
    if [ "$choice" -ge 1 ] && [ "$choice" -le `expr $i - 1` ]
    then
    selected_file=$(ls "$malicious_dir" | head -n "$choice" | tail -n 1)
    echo "For $(basename "$selected_file"):"
    echo "1: Restore this file back into dir (it was a false positive)"
    echo "2: Permanently delete this file from malicious_dir (it was genuinely malicious)"
    echo "3: Go back"
    echo -n "> "
    read input
    if [ "$input" -eq 1 ]
    then 
    cp "$malicious_dir/$selected_file" "$dir"
    rm "$malicious_dir/$selected_file"
    echo "$(basename "$selected_file")" >> "$whitelist"
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