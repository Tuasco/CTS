#!/usr/bin/env bash


LEVEL_PATH="$(dirname "$(readlink -f -- "$0")")"
FILE1_PATH="$LEVEL_PATH/file-1.txt"
FILE2_PATH="$LEVEL_PATH/file-2.txt"

# Check that level 1 has been passed
if [ ! -f "$LEVEL_PATH/../level-1/.PASS" ] || [ "$(cat "$LEVEL_PATH/../level-1/.PASS")" != "1" ]; then
  >&2 echo "To attempt this level, you must first pass the previous level !"
  exit 2
fi

# Check that file-1 exists
if [ ! -f "$FILE1_PATH" ]; then
  >&2 echo "Have you deleted one of the files ? YOU BROKE THE GAME ! I'll fix it for ya..."
  echo "This is the content of file 1" > "$FILE1_PATH"
  exit 2
fi

# Check that file-2 exists
if [ ! -f "$FILE2_PATH" ]; then
  >&2 echo "You have removed file 2. You're on track !"
  exit 2
fi

# Check that the content file-1.txt is not modified
if [ "$(cat "$FILE1_PATH")" != "This is the content of file 1" ]; then
  >&2 echo "You have (potentially indirectly) modified the content of file-1.txt"
  exit 2
fi

# Check that the content file-2.txt is modified to the expected result
if [ "$(cat "$FILE2_PATH")" != "This is the content of file 2" ]; then
  >&2 echo "I don't know what you've been doing, but this doesn't cut it. Try again !"
  exit 2
fi

echo "Congratulations ! How hard was it ? Kidding, don't care. Go next."
echo "1" > "$LEVEL_PATH/.PASS"
