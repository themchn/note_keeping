# note_keeping
Scripts for creation and syncronizatin of notes.
Currently REQUIRES fzf and ripgrep.

notes.sh takes no arguments for creation/searching/reading notes but accepts delete as $1 for deleting note files.
vim is currently hardcoded as the editor but that can be changes easily enough.

sync_notes.sh pulls and pushes changes to git.
This was designed to be used in conjunction with incrond for automatic syncing to git.

This was written with gitjournal for android in mind https://gitjournal.io/ and note creation follows gitjournals template for seamless transition.
