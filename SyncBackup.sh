#!/bin/bash

echo -e "███████╗██╗   ██╗███╗   ██╗ ██████╗    ██████╗  █████╗  ██████╗██╗  ██╗██╗   ██╗██████╗ "
echo -e "██╔════╝╚██╗ ██╔╝████╗  ██║██╔════╝    ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██║   ██║██╔══██╗"
echo -e "███████╗ ╚████╔╝ ██╔██╗ ██║██║         ██████╔╝███████║██║     █████╔╝ ██║   ██║██████╔╝"
echo -e "╚════██║  ╚██╔╝  ██║╚██╗██║██║         ██╔══██╗██╔══██║██║     ██╔═██╗ ██║   ██║██╔═══╝ "
echo -e "███████║   ██║   ██║ ╚████║╚██████╗    ██████╔╝██║  ██║╚██████╗██║  ██╗╚██████╔╝██║     "
echo -e "╚══════╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     "
echo -e "@Lucaterre - 2024"


# tput sgr0


# Function to ask for a directory path and verify its existence
ask_directory() {
    local dir_type="$1"  # Either "source" or "destination"
    echo -e "Please enter the path of the $dir_type:" >&2
    read -r dir_path
    
    # Verify if the directory exists
    if [ ! -d "$dir_path" ]; then
        echo -e "\033[0;31mThe $dir_type directory does not exist. Please check the path.\033[0m" >&2
        exit 1
    fi
    echo "$dir_path"
}

# Function to synchronize files with rsync
sync_directories() {
    local source_dir="$1"
    local dest_dir="$2"
    echo ">> Synchronizing files from $source_dir to $dest_dir..."
    sudo rsync -av --progress --delete "$source_dir" "$dest_dir"
}

# Function to handle Git operations in the destination directory
handle_git_repo() {
    local dest_dir="$1"
    git config --global --add safe.directory "$dest_dir"

    if [ ! -d "$dest_dir/.git" ]; then
        echo ">> The destination directory is not a Git repository. Initializing Git..."
        cd "$dest_dir" || exit
        git init
        git add .
        git commit -m "Initial commit"
    else
        echo ">> The destination directory is already a Git repository."
        cd "$dest_dir" || exit
        git add .
        git commit -m "Automatic backup - $(date)"
    fi
}

# Ask for source and destination directories
# Ask for source directory
SOURCE_DIR=$(ask_directory "source (any folder on your local filesystem)")
if [ -z "$SOURCE_DIR" ]; then
    echo -e "\033[0;31mError: Source directory is invalid.\033[0m"
    exit 1
fi

# Ask for destination directory
DEST_DIR=$(ask_directory "destination (for example directory in your volume)")
if [ -z "$DEST_DIR" ]; then
    echo -e "\033[0;31mError: Destination directory is invalid.\033[0m"
    exit 1
fi

# Sync the directories
echo -e "\033[1;33mSynchronizing directories...\033[0m"
sync_directories "$SOURCE_DIR" "$DEST_DIR"

# Handle Git in the destination directory
handle_git_repo "$DEST_DIR"

# End message
echo -e "\033[0;42mOperation completed successfully. You can use 'git log' in your destination file to check versions and restore a good backup if you suspect your desktop is corrupted.\033[0m"

# Pause to prevent the terminal from closing immediately
echo -e "\033[1;33mPress any key to close...\033[0m"
read -n 1 -s