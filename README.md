# note_keeping
Wrapper script for fzf, ripgrep, and vim for the searching, viewing, editing, and creating notes.
Currently REQUIRES fzf, ripgrep, and vim.

notes.sh takes no arguments for creation/searching/reading notes but accepts delete as $1 for deleting note files.
Be sure to set the $notes_dir default if you are not using this with Nextcloud's Notes app in default direction configuration.
vim is currently hardcoded as the editor but the this could be changed relatively easily.

This repo no longer has anything to handling syncing. I've moved from gitjournal to nextcloud notes.
