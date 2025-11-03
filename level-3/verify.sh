#!/usr/bin/env bash


LEVEL_PATH="$(dirname "$(readlink -f -- "$0")")"
SCRIPT_PATH="$LEVEL_PATH/usr/local/bin/whoami.sh"
LINK1_PATH="$LEVEL_PATH/usr/bin/whoami.sh"
LINK2_PATH="$LEVEL_PATH/bin/whoami.sh"


# Check that level 2 has been passed
if [ ! -f "$LEVEL_PATH/../level-2/.PASS" ] || [ "$(cat "$LEVEL_PATH/../level-2/.PASS")" != "1" ]; then
  >&2 echo "To attempt this level, you must first pass the previous level !"
  exit 2
fi

# Check that the original script exists
if [ ! -f "$SCRIPT_PATH" ]; then
  >&2 echo "Have you deleted the script ? Good job, YOU BROKE THE GAME ! Here, I fixed it..."
  mkdir -p "$LEVEL_PATH/bin"
  mkdir -p "$LEVEL_PATH/usr/bin"
  mkdir -p "$LEVEL_PATH/usr/local/bin"
  echo -e "#!/usr/bin/env bash\n\nwhoami" > "$SCRIPT_PATH"
  chmod a+x ./level-3/usr/local/bin/whoami.sh
  exit 2
fi

# Check that link 1 exists and is correct
if [ ! -h "$LINK1_PATH" ] || [ "$(readlink -f "$LINK1_PATH")" != "$SCRIPT_PATH" ]; then
  echo "You messed up on the first link. Fix it and come back."
  exit 2
fi

# Check that link 2 exists and is correct
if [ ! -h "$LINK2_PATH" ] || [ "$(readlink -f "$LINK2_PATH")" != "$SCRIPT_PATH" ]; then
  echo "You messed up on the second link. Fix it and come back."
  exit 2
fi

echo "Okay good job ! If you have a btrfs file system or if you are on the Live CD, please skip level 4."
echo "1" > "$LEVEL_PATH/.PASS"

# Ask to automatically skip level 4
echo "Do you want me to skip it for you? (y/N)"
read -r confirm
if [[ $confirm =~ ^[Yy]$ ]]; then
    echo "Skipping..."
    echo "1" > "$LEVEL_PATH/../level-4/.PASS"
else
    echo "Alright then, go for it champ !"
fi
