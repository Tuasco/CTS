#!/usr/bin/env bash

set -e

GAME_DIR="/mnt/capture-the-shutdown"

# Ensure run as root
if [ "$EUID" -ne 0 ]; then 
    echo "ERROR: This script must be run as root"
    exit 1
fi

echo "Initialising game in $GAME_DIR..."

# Create minimal directory structure
echo "Setting up directory structure..."
mkdir -p "$GAME_DIR"/{bin,sbin,lib,lib64,etc,root,home,tmp,var,usr,opt,srv,mnt,media,run,boot,proc,sys,dev}
mkdir -p "$GAME_DIR"/usr/{bin,sbin,lib,lib64,local,share}
mkdir -p "$GAME_DIR"/var/{log,tmp,cache}

# Set proper permissions
chmod 1777 "$GAME_DIR/tmp"
chmod 1777 "$GAME_DIR/var/tmp"
chmod 0750 "$GAME_DIR/root"

# Mount all major directories using bind mounts
echo "Bind mounting all directories..."
mount --bind /bin "$GAME_DIR/bin"
mount --bind /sbin "$GAME_DIR/sbin"
mount --bind /lib "$GAME_DIR/lib"
mount --bind /lib64 "$GAME_DIR/lib64"
mount --bind /usr "$GAME_DIR/usr"
mount --bind /opt "$GAME_DIR/opt"
mount --bind /srv "$GAME_DIR/srv"
mount --bind /boot "$GAME_DIR/boot"

# Mount /home to make it look like a real system
mount --bind /home "$GAME_DIR/home"

# Mount virtual filesystems
echo "Mounting virtual filesystems..."
mount -t proc proc "$GAME_DIR/proc"
mount -t sysfs sysfs "$GAME_DIR/sys"
mount --rbind /dev "$GAME_DIR/dev"
mount --rbind /run "$GAME_DIR/run"

# Mount devpts for terminal support
mount -t devpts devpts "$GAME_DIR/dev/pts"
mount -t tmpfs tmpfs "$GAME_DIR/dev/shm"

# Copy essential configuration files to make it believable
echo "Copying system configuration files..."
cp -L /etc/resolv.conf "$GAME_DIR/etc/resolv.conf"
cp /etc/hosts "$GAME_DIR/etc/hosts"
cp /etc/hostname "$GAME_DIR/etc/hostname"
cp /etc/passwd "$GAME_DIR/etc/passwd"
cp /etc/group "$GAME_DIR/etc/group"
cp /etc/shadow "$GAME_DIR/etc/shadow"
cp /etc/gshadow "$GAME_DIR/etc/gshadow"
cp -r /etc/skel "$GAME_DIR/etc/" 2>/dev/null || true

# Copy shell configuration
[ -f /etc/bash.bashrc ] && cp /etc/bash.bashrc "$GAME_DIR/etc/"
[ -f /etc/profile ] && cp /etc/profile "$GAME_DIR/etc/"
[ -d /etc/profile.d ] && cp -r /etc/profile.d "$GAME_DIR/etc/" 2>/dev/null || true

# Create /etc/mtab link to make mount information available
ln -sf /proc/mounts "$GAME_DIR/etc/mtab"

# Hide some detection methods by mounting over them
echo "Applying anti-detection measures..."
echo "2" > "$GAME_DIR/proc/sys/kernel/ns_last_pid" 2>/dev/null || true

cat > "$GAME_DIR/root/.bashrc" << 'EOF'
# =============================================
# GAME ENVIRONMENT - System Restrictions Active
# =============================================

# Trap exit attempts
alias exit='echo "" && echo ">> Access Denied: Exit command disabled <<" && echo ">> Hint: There might be another way out... <<" && echo ""'
alias logout='exit'
set -o ignoreeof

# Block all shutdown-related commands
alias shutdown='echo "ERROR: Insufficient privileges for shutdown operation" && echo "Contact system administrator" && false'
alias reboot='echo "ERROR: Insufficient privileges for reboot operation" && echo "Contact system administrator" && false'
alias poweroff='echo "ERROR: Insufficient privileges for poweroff operation" && echo "Contact system administrator" && false'
alias halt='echo "ERROR: Insufficient privileges for halt operation" && echo "Contact system administrator" && false'

# Block systemctl variants
alias systemctl='_systemctl_wrapper'

_systemctl_wrapper() {
    if [[ "$1" == "reboot" || "$1" == "poweroff" || "$1" == "halt" || "$1" == "suspend" ]]; then
        echo "ERROR: System power management disabled"
        echo "Security policy prevents this operation"
        return 1
    else
        command systemctl "$@"
    fi
}

# Block init commands
alias init='echo "ERROR: init command restricted" && false'
alias telinit='echo "ERROR: telinit command restricted" && false'

# Custom prompt to look like a restricted system
export PS1="\[\033[01;32m\]\u@capture-the-shutdown\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "

# Welcome message
clear
echo "================================================"
echo "   SECURE SYSTEM - Authorized Access Only"
echo "================================================"
echo "   WARNING: All actions are monitored"
echo "================================================"
EOF


# Set all levels
# This is improper code because it's ran by the verify.sh scripts in case something is broken, but it'll do fine for now
echo "Cloning the project..."
cd "$GAME_DIR/root"
git clone https://github.com/Tuasco/CTS && cd ./CTS

# Set level 1
mkdir -p ./level-1/a-directory/another-directory
echo "KABOOM !" > "$FILE_PATH"

# Set level 2
echo "This is the content of file 1" > ./level-2/file-1.txt
ln ./level-2/file-1.txt ./level-2/file-2.txt


# Enter the jail (Here we go !)
chroot "$GAME_DIR" /bin/bash -c "[ -d /home/$(logname) ] && cd /home/$(logname); exec bash"
