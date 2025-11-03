#!/usr/bin/env bash
set -euo pipefail


LEVEL_PATH="$(dirname "$(readlink -f -- "$0")")"
FILE_PATH="$LEVEL_PATH/a-directory/another-directory/a-file"

# Check that the file is present, fix it instead
if [ ! -f "$FILE_PATH" ]; then
  >&2 echo "File not found. Did you remove it ? YOU BROKE THE GAME ! I'll fix it for ya..."
  mkdir -p "a-directory/another-directory"
  echo "KABOOM !" > "$FILE_PATH"
  exit 2
fi

read -rp "Alright, so give me the inode number: " inode

# Validate that the input is an integer.
if ! [[ "$inode" =~ ^[0-9]+$ ]]; then
    >&2 echo "Your input is not a valid number."
    exit 2
fi

# Check that the inode number is correct
if [[ "$(stat --format="%i" "$FILE_PATH")" -ne "$inode" ]]; then
  >&2 echo "Nope ! Try again."
  exit 2
fi

echo "Nice !"
echo "You passed level 1 ! Proceed with level 2."
echo "1" > "$LEVEL_PATH/.PASS"
