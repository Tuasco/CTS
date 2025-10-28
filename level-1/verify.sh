#!/usr/bin/env bash


LEVEL_PATH="$(dirname "$(readlink -f -- "$0")")"
FILE_PATH="$LEVEL_PATH/a-directory/another-directory/a-file"

if [ ! -f "$FILE_PATH" ]; then
  >&2 echo "File not found. Did you remove it ? YOU BROKE THE GAME !"
  exit 2
fi

read -rp "Alright, so give me the inode number: " inode
if [[ $(stat --format="%i" "$FILE_PATH") -eq inode ]]; then
  echo "Nice !"
  echo "You passed level 1. Proceed with level 2"
  echo "1" > "$LEVEL_PATH/.PASS"
else
  echo "Nope ! Try again."
fi
