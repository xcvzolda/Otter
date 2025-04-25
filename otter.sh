#!/bin/bash

REPO_DIR="$HOME/otter-repo"
OTTER_SCRIPT_PATH="/usr/local/bin/otter"

# Ensure the repository exists
if [ ! -d "$REPO_DIR" ]; then
    echo "Repository not found. Cloning from GitHub..."
    git clone --depth=1 https://github.com/xcvzolda/otter-repo.git "$REPO_DIR"
fi

# Function to display available commands
function show_help {
    echo "Available commands:"
    echo "  help           - Show all commands"
    echo "  install-gui    - Browse categories to install GUI packages"
    echo "  install <name> - Search & install package with sudo"
    echo "  delete         - Deletes otter (must use '--otter' at the end)"
    echo "  update-repo    - Updates the repository"
}

# Function to navigate folders and select a package
function install_gui {
    local current_dir="$REPO_DIR"

    while true; do
        echo "Available categories/packages in: $current_dir"
        mapfile -t entries < <(find "$current_dir" -mindepth 1 -maxdepth 1 -type d -or -type f -name "install*.sh" -printf "%f\n")

        if [ ${#entries[@]} -eq 0 ]; then
            echo "No packages or subdirectories found."
            return
        fi

        select entry in "${entries[@]}" "Go Back" "Cancel"; do
            if [[ "$entry" == "Cancel" ]]; then
                echo "Installation cancelled."
                return
            elif [[ "$entry" == "Go Back" ]]; then
                current_dir="${current_dir%/*}"
                break
            elif [[ -d "$current_dir/$entry" ]]; then
                current_dir="$current_dir/$entry"
                break
            elif [[ -f "$current_dir/$entry" ]]; then
                echo "Found installation script: $current_dir/$entry"
                chmod +x "$current_dir/$entry"
                sudo "$current_dir/$entry"
                return
            else
                echo "Invalid selection. Try again."
            fi
        done
    done
}

# Function to search all folders for a matching installation script and execute it with sudo
function search_and_install {
    echo "Searching for package: $1..."
    INSTALL_SCRIPT=$(find "$REPO_DIR" -type f -name "*$1*.sh" | head -n 1)

    if [ -n "$INSTALL_SCRIPT" ]; then
        echo "Found installation script: $INSTALL_SCRIPT"
        chmod +x "$INSTALL_SCRIPT"
        sudo "$INSTALL_SCRIPT"
    else
        echo "No installation script found for '$1'. Check package name or try install-gui."
    fi
}

# Function to update repository
function update_repo {
    echo "Updating repository..."
    cd "$REPO_DIR" && git pull
}

# Function to delete otter (removes repo and otter.sh)
function delete_otter {
    if [[ "$1" == "--otter" ]]; then
        echo "Deleting otter..."
        sudo rm -rf "$REPO_DIR"

        if [ -f "$OTTER_SCRIPT_PATH" ]; then
            sudo rm "$OTTER_SCRIPT_PATH"
            echo "Otter script removed."
        fi

        echo "Otter has been completely removed."
    else
        echo "Invalid command! Use 'delete --otter' to remove otter."
    fi
}

# Command handling
case "$1" in
    help) show_help ;;
    install-gui) install_gui ;;
    install) search_and_install "$2" ;;
    delete) delete_otter "$2" ;;
    update-repo) update_repo ;;
    *) echo "Unknown command! Use 'help' for available commands." ;;
esac
