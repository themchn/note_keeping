#!/bin/bash

# dependency check
# This script relies on both fzf and ripgrep
if which fzf > /dev/null ; then
	:
else
	echo "fzf not found in PATH. Please install fzf."
	exit 1
fi
if which rg > /dev/null ; then
	:
else
	echo "rg not found in PATH. Please install ripgrep."
	exit 1
fi

# defaults
notes_dir=""$HOME"/Nextcloud/Notes"

# functions
create_note() {
cd "$notes_dir"
# create name of note from sanitized fzf_query. Currently only removes whitespace.
note_names="$( echo ${fzf_query} | sed 's/ /_/g' ).md"
# open vim with note_names as filename and fzf_query as first line of note for markdown title.
echo -n "#${fzf_query}" | vim - +"file ${note_names}"
}

edit_notes() {
cd "$notes_dir"
# if a fzf_query was created open note to first line match
# if multiple notes are selected only the first one opens to line match
if [[ -z "$fzf_query" ]] ; then
    vim -p "${note_names[@]}"
else
	vim +/"$fzf_query" -p "${note_names[@]}"
fi
}

delete_note() {
cd "$notes_dir"
# interactive delete of all selected notes
for note in "${note_selection[@]}" ; do
	if [[ -f "$note" ]] ; then
		rm -i "$note"
	else
		:
	fi
done
}

search_notes() {
cd "$notes_dir"
# open fzf in interactive preview using ripgrep
# selections will be passed to next appropriate function
RG_DEFAULT_COMMAND="rg -i -l"
FZF_DEFAULT_COMMAND="rg --files" fzf \
  -m \
  -e \
  --ansi \
  --disabled \
  --reverse \
  --print-query \
  --bind "change:reload:$RG_DEFAULT_COMMAND {q} || true" \
  --preview "rg -i --pretty --context 2 {q} {}"
}

case "$1" in
    "")
        # TODO: Make this a nested case statement
        # read input string for fzf and query results
        readarray -t note_selection < <(search_notes)
        fzf_query="${note_selection[0]}"
        # if no query was submitted the array is empty so exit
        if [ -z "${note_selection[*]}" ] ; then
        	exit 1
        fi
        # if note_selection array contains only one entry then only the fzf_query was set and no note selected to open
        # execute create_note function to create new note from fzf_query
        if [ "${#note_selection[@]}" -eq 1 ] ; then
            create_note
        	exit 0
        fi
        # if note_selection is greater than 2 then at least one existing note has been created
        # open all selected notes in edit_notes function
        if [ "${#note_selection[@]}" -ge 2 ] ; then
            note_names=("${note_selection[@]:1}")
            edit_notes
        	exit 0
        fi
        ;;
    delete)
        # pass all selected notes to delete_note fuction
        readarray -t note_selection < <(search_notes)
        if [ -z "${note_selection[*]}" ] ; then
        	exit 1
        fi
        delete_note
        ;;
    *)
        echo "Error: Invalid option."
        ;;
esac
