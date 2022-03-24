#!/bin/bash

# dependency check
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
notes_dir=""$HOME"/gitjournal"

# functions
edit_note() {
cd "$notes_dir"
# define note filename and title
if [[ "${note_selection[1]}" == *.md ]] ; then
	note_name="${note_selection[1]}"
	note_title="$(echo "${note_selection[1]}" | cut -d'.' -f1)"
else
	note_name=""${note_selection[0]}".md"
	note_title="${note_selection[0]}"	
fi
# if note doesn't exist create it, else edit existing
if [ -f "$note_name" ] ; then
    old_mod_time=$(stat -c %y "$note_name")
	# start vim cursor at fzf_query if set
	if [[ -z "$fzf_query" ]] ; then
	    vim "$note_name"
	else
		vim +/"$fzf_query" "$note_name"
	fi
    new_mod_time=$(stat -c %y "$note_name")
    if [ "$old_mod_time" != "$new_mod_time" ] ; then
        sed -i "3s|.*|modified: $(date "+%Y-%m-%dT%H:%M:%S%:z")|g" "$note_name"
    fi
else
    # write note to /tmp initially to avoid unnecessary incron invocations
    date=$(date "+%Y-%m-%dT%H:%M:%S%:z")
    cat << EOF > /tmp/"$note_name"
---
created: ${date}
modified: ${date}
---

# ${note_title}
EOF
    vim -c "set nohlsearch" +/"$note_title" /tmp/"$note_name"
    sed -i "3s|.*|modified: $(date "+%Y-%m-%dT%H:%M:%S%:z")|g" /tmp/"$note_name"
    mv /tmp/"$note_name" "$notes_dir"/"$note_name"
fi
}

delete_note() {
cd "$notes_dir"
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
		readarray -t note_selection < <(search_notes)
		fzf_query="${note_selection[0]}"
		if [ -z "${note_selection[*]}" ] ; then
			exit 1
		fi
		if [ "${#note_selection[@]}" -gt 2 ] ; then
			echo "Error: Opening multiple notes not supported"
			exit 1
		else
			:
		fi
        edit_note
        ;;
    delete)
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
