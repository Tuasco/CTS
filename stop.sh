#!/usr/bin/env bash

# SAFE Cleanup Script

GAME_DIR="/mnt/capture-the-shutdown"

echo "====================="
echo " Safe Cleanup Script "
echo "====================="
echo ""

# Ensure run as root
if [ "$EUID" -ne 0 ]; then 
    echo "ERROR: This script must be run as root"
    exit 1
fi

# Ensure dir exists
if [ ! -d "$GAME_DIR" ]; then
    echo "Directory $GAME_DIR does not exist. Nothing to clean."
    exit 0
fi

# Kill any processes using the chroot
echo "[1/5] Checking for processes using $GAME_DIR..."
PROCS=$(lsof +D "$GAME_DIR" 2>/dev/null | wc -l)
if [ "$PROCS" -gt 0 ]; then
    echo "WARNING: Processes are still using $GAME_DIR"
    echo "Active processes:"
    lsof +D "$GAME_DIR" 2>/dev/null
    echo ""
    echo "Kill these processes? (y/n)"
    read -r response
    if [[ "$response" == "y" ]]; then
        fuser -km "$GAME_DIR" 2>/dev/null
        sleep 2
    else
        echo "Cannot continue with active processes. Exiting."
        echo "Please restart your computer and retry."
        exit 1
    fi
fi

# Unmount everything
echo "[2/5] Unmounting all filesystems in $GAME_DIR..."

# Try graceful unmount first
umount "$GAME_DIR/dev/shm" 2>/dev/null
umount "$GAME_DIR/dev/pts" 2>/dev/null
umount -R "$GAME_DIR/dev" 2>/dev/null
umount -R "$GAME_DIR/run" 2>/dev/null
umount "$GAME_DIR/sys" 2>/dev/null
umount "$GAME_DIR/proc" 2>/dev/null
umount "$GAME_DIR/root" 2>/dev/null
umount "$GAME_DIR/home" 2>/dev/null
umount "$GAME_DIR/boot" 2>/dev/null
umount "$GAME_DIR/srv" 2>/dev/null
umount "$GAME_DIR/opt" 2>/dev/null
umount "$GAME_DIR/usr" 2>/dev/null
umount "$GAME_DIR/lib64" 2>/dev/null
umount "$GAME_DIR/lib" 2>/dev/null
umount "$GAME_DIR/sbin" 2>/dev/null
umount "$GAME_DIR/bin" 2>/dev/null

# Final recursive unmount
umount -R "$GAME_DIR" 2>/dev/null

# Lazy unmount as last resort
echo "[3/5] Performing lazy unmount to catch any stragglers..."
umount -l "$GAME_DIR" 2>/dev/null

sleep 2

# Verify nothing is mounted
echo "[4/5] Verifying all mounts are cleared..."
MOUNTS=$(mount | grep "$GAME_DIR" | wc -l)

if [ "$MOUNTS" -gt 0 ]; then
    echo "ERROR: Some filesystems are still mounted:"
    mount | grep "$GAME_DIR"
    echo ""
    echo "REFUSING to delete directory for safety!"
    echo "Manual intervention required. (Reboot ?)"
    exit 1
fi

echo "✓ All mounts cleared successfully"

# Final safety confirmation
echo ""
echo "[5/5] Ready to delete $GAME_DIR"
echo "This will permanently remove the directory structure."
echo "Type 'DELETE' to confirm: "
read -r confirm

if [[ "$confirm" != "DELETE" ]]; then
    echo "Deletion cancelled. Directory preserved."
    exit 0
fi

# Safe deletion - only remove the directory structure
echo "Deleting chroot directory..."
rm -rf "$GAME_DIR"

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Chroot directory deleted successfully"
    echo "✓ Cleanup complete"
else
    echo ""
    echo "ERROR: Failed to delete directory"
    echo "Please restart your computer and retry."
    exit 1
fi
