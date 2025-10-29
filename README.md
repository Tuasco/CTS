# Capture The Shutdown !
## TL;DR
This is a detective-style game to learn about inodes, links and filesystems in Linux. This game has multiple levels increasingly difficult, and the user wins when they shutdown their computer from within the same terminal.

## Context
You suddenly wake up and find yourself in a weird environment. You follow crumb trails and find a bunch of weird folders, the levels.

Inside, you will be greeted by hints left by previous users who couldn't make it. Will you be the one who succeeds ? You win this game if you are able to shutdown your pc from within the same terminal where you launched the game. Seems simple right :eyes: ?

## Installation
To set your environment, you can either clone the repository :
```bash
git clone https://github.com/Tuasco/CTS
```
then cd into the repository's directory and execute *start.sh* :
```bash
cd CTS
sudo bash start.sh
```

## Uninstall properly
Removing the new directory created by git isn't enough to get rid of the game from your computer.

After you're done (whether successfully or not), you should restart your computer, then execute the *stop.sh* script to clean up any remaining files, mounts and other system changes :
```bash
sudo bash stop.sh
```

> :warning: **If you have a Live CD**: Restarting your computer is sufficient

## Levels
> :heavy_exclamation_mark: **If you haven't played the game yet**: The following parts contain spoilers ! Please proceed with playing the game and only refer to the following sections if you have a (very) hard time figuring the game out.

### Level 0
The user has to execute the *start.sh* script. Then, they will have to do some reading to understand the basics about inodes.
This level strictly sets the user and the computer up to be ready to attempt the challenge.

### Level 1
A script is mysteriously found in the folder. It will be helpful all along the challenge if you want to visualize the state of a directory and its files and sub-directories in the filesystem.
In this level, the user has to see the inode number of specific files and folders and give the correct number to a verification script. Simple stuff to get familiar with the concept.

### Level 2
A file left by a previous user tells us that the inode number of the root directory should be a power of 2. What is ours ? Weird...

To pass the level, the user has to resolve an issue that make files linked (writing in one results in the other being modified) and find out that files can share a single inode (hardlinks).

### Level 3
A note says that we're imprisoned. WHAT ?

Here the user has to navigate a symlink path and fix a symlink loop at the end of it, that makes a file non accessible by the symlinks because of a configuration error.

### Level 4
A python script. Interesting... But what does it do ?

To pass this level, the user has to notice that the root directory's hardlink count is off. In fact, there is one more than what we can count manually. Are we missing something ?

> :warning: This level doesn't work on all devices. On btrfs and Live CDs, it will be automatically skipped.

### Level 5
But hang on a second !

We can't shutdown, the root inode number isn't 2, we have one more link to it that what we can count, someone said we're in prison. That's right ! A chroot jail ! But what about that python script ? The user wins if he can use the script to break out of the jail and shutdown his PC.

## Bypass a level
If you choose not to pass a level the regular way, you can always bypass it (cheater).
You need to write *1* in a file named `.PASS` in the same directory as the level you chose to override.
