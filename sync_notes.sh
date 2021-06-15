#!/bin/bash

# Set to directory where you store notes
notedir=""$HOME"/gitjournal"

# Check if sync process is currently running via lockfile
state=`cat /run/lock/notesync`
if [ "$state" -eq 1 ] ; then
    exit 1
else
    #Lock the file
    echo 1 > /run/lock/notesync

   # sync notes
	cd "$notedir"
	gstatus=`git status --porcelain`
	
	if [ ${#gstatus} -ne 0 ]
	then
	    git add --all
	    git commit -m "$gstatus"
	
		git pull --rebase
	    git push
	else
		git pull
	fi

	#Unlock
    echo 0 > /run/lock/notesync
fi


