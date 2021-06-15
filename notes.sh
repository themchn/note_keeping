#!/bin/bash

note_title="$1"
note_name=""$note_title".md"
notes_dir=""$HOME"/gitjournal"

if [ -z "$note_title" ] ; then
    echo "Please provide note name."
    exit 1
fi

cd "$notes_dir"
if [ -f "$note_name" ] ; then
    old_mod_time=$(stat -c %y "$note_name")
    vim "$note_name"
    new_mod_time=$(stat -c %y "$note_name")
    if [ old_mod_time != new_mod_time ] ; then
        sed "3s|.*|modified: $(date "+%Y-%m-%dT%H:%M:%S%:z")|g" "$note_name"
    fi
else
    # write note to /tmp initially to avoid unnecessary incron invocations
    date=$(date "+%Y-%m-%dT%H:%M:%S%:z")
    cat << EOF > /tmp/"$note_name"
---
created: "$date"
modified: "$date"
---

# "$note_title"
EOF
    vim /tmp/"$note_name"
    sed "3s|.*|modified: $(date "+%Y-%m-%dT%H:%M:%S%:z")|g" /tmp/"$note_name"
    mv /tmp/"$note_name" "$notes_dir"/"$note_name"
fi
