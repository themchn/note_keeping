#!/bin/bash

state=`cat /run/lock/notesync`
if [ "$state" -eq 1 ] ; then
    exit 1
else
    #Lock the file
    echo 1 > /run/lock/notesync

   # sync notes
	cd "$HOME"/gitjournal
	gstatus=`git status --porcelain`
	
	if [ ${#gstatus} -ne 0 ]
	then
	    git add --all >> "$HOME"/incron.log
	    git commit -m "$gstatus"
	
		git pull --rebase >> "$HOME"/incron.log
	    git push >> "$HOME"/incron.log
	else
		git pull
	fi

	#Unlock
    echo 0 > /run/lock/notesync
fi


