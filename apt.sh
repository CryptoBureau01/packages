#!/bin/bash




# Function to update the apt sources list
apt_sources_list_update() {
    echo "Backing up the current sources list..."
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak || { echo "Failed to back up sources list. Exiting..."; return 1; }

    echo "Removing old sources list..."
    echo "" | sudo tee /etc/apt/sources.list > /dev/null || { echo "Failed to clear sources list. Exiting..."; return 1; }

    echo "Creating new sources list..."
    sudo bash -c 'cat <<EOL > /etc/apt/sources.list
# Ubuntu Main Repositories
deb http://asi-fs-d.contabo.net/ubuntu jammy main restricted
deb http://asi-fs-d.contabo.net/ubuntu jammy-updates main restricted
deb http://asi-fs-d.contabo.net/ubuntu jammy universe
deb http://asi-fs-d.contabo.net/ubuntu jammy-updates universe
deb http://asi-fs-d.contabo.net/ubuntu jammy multiverse
deb http://asi-fs-d.contabo.net/ubuntu jammy-updates multiverse
deb http://asi-fs-d.contabo.net/ubuntu jammy-backports main restricted universe
deb http://security.ubuntu.com/ubuntu jammy-security main restricted
deb http://security.ubuntu.com/ubuntu jammy-security universe
deb http://security.ubuntu.com/ubuntu jammy-security multiverse
EOL' || { echo "Failed to create new sources list. Exiting..."; return 1; }

    echo "Updating package list..."
    sudo apt-get update || { echo "Failed to update package list. Exiting..."; return 1; }

    echo "Apt sources list updated successfully."
}




# Function to handle common apt update errors
fix_apt_update_errors() {
    echo "Running sudo apt update..."
    if sudo apt update; then
        echo "APT update completed successfully."
        return 0
    else
        echo "APT update encountered errors. Analyzing..."

        # Check for common errors
        if grep -q "Could not resolve" /var/log/apt/term.log; then
            echo "Error: Could not resolve package repository. Check your internet connection or the sources list."
            echo "Attempting to fix DNS resolution..."
            sudo apt-get install --reinstall resolvconf
        elif grep -q "E: Unable to locate package" /var/log/apt/term.log; then
            echo "Error: Unable to locate package. This may be due to an incorrect sources list."
            apt_sources_list_update
        elif grep -q "E: Package '.*' has no installation candidate" /var/log/apt/term.log; then
            echo "Error: Package has no installation candidate. This may indicate a missing repository."
            echo "Updating the sources list..."
            apt_sources_list_update
        elif grep -q "E: Unable to lock the administration directory" /var/log/apt/term.log; then
            echo "Error: Unable to lock the administration directory. Another package manager may be running."
            echo "Please ensure that no other apt/dpkg processes are running and try again."
        else
            echo "Encountered an unexpected error. Please check the logs for details."
        fi

        # Attempt to fix broken packages
        echo "Attempting to fix broken packages..."
        sudo apt --fix-broken install -y
        echo "Attempting to clean up..."
        sudo apt-get autoremove -y
        sudo apt-get clean

        # Retry the update
        echo "Retrying sudo apt update..."
        if sudo apt update; then
            echo "APT update completed successfully after fixing errors."
        else
            echo "Failed to resolve errors after retrying."
        fi
    fi
}






# Function to handle common apt errors
fix_apt_errors() {
    echo "Checking and fixing common apt errors..."

    # Install python3-apt if it's not installed
    if ! dpkg -l | grep -q python3-apt; then
        echo "Installing python3-apt..."
        sudo apt-get install -y python3-apt || { echo "Failed to install python3-apt. Exiting..."; return 1; }
    fi

    # Check for and reinstall command-not-found
    if dpkg -l | grep -q command-not-found; then
        echo "Reinstalling command-not-found..."
        sudo apt remove -y command-not-found || { echo "Failed to remove command-not-found. Exiting..."; return 1; }
    fi
    sudo apt install -y command-not-found || { echo "Failed to install command-not-found. Exiting..."; return 1; }

    # Clear apt lists and cache
    echo "Clearing apt lists and cache..."
    sudo rm -rf /var/lib/apt/lists/* || { echo "Failed to clear apt lists. Exiting..."; return 1; }
    sudo rm -rf /var/cache/apt/archives/* || { echo "Failed to clear apt archives. Exiting..."; return 1; }

    # Attempt to update APT
    echo "Running sudo apt update..."
    if ! sudo apt update; then
        echo "APT update encountered errors. Analyzing..."

        # Check for common errors in the update process
        if grep -q "Could not resolve" /var/log/apt/term.log; then
            echo "Error: Could not resolve package repository. Check your internet connection or the sources list."
            echo "Attempting to fix DNS resolution..."
            sudo apt-get install --reinstall resolvconf || { echo "Failed to fix DNS issues. Exiting..."; return 1; }
        elif grep -q "E: Unable to locate package" /var/log/apt/term.log; then
            echo "Error: Unable to locate package. This may be due to an incorrect sources list."
            apt_sources_list_update || { echo "Failed to update sources list. Exiting..."; return 1; }
        elif grep -q "E: Package '.*' has no installation candidate" /var/log/apt/term.log; then
            echo "Error: Package has no installation candidate. This may indicate a missing repository."
            apt_sources_list_update || { echo "Failed to update sources list. Exiting..."; return 1; }
        elif grep -q "E: Unable to lock the administration directory" /var/log/apt/term.log; then
            echo "Error: Unable to lock the administration directory. Another package manager may be running."
            echo "Please ensure that no other apt/dpkg processes are running and try again."
            return 1
        else
            echo "Encountered an unexpected error. Please check the logs for details."
        fi

        # Attempt to fix broken packages
        echo "Attempting to fix broken packages..."
        sudo apt --fix-broken install -y || { echo "Failed to fix broken installs. Exiting..."; return 1; }
        
        # Clean up
        echo "Attempting to clean up..."
        sudo apt-get autoremove -y || { echo "Failed to autoremove packages. Exiting..."; return 1; }
        sudo apt-get clean || { echo "Failed to clean apt cache. Exiting..."; return 1; }

        # Retry the update
        echo "Retrying sudo apt update..."
        if ! sudo apt update; then
            echo "Failed to resolve errors after retrying."
        else
            echo "APT update completed successfully after fixing errors."
        fi
    else
        echo "APT update completed successfully."
    fi

    # Update command-not-found
    echo "Updating command-not-found..."
    sudo update-command-not-found || { echo "Failed to update command-not-found. Exiting..."; return 1; }

    echo "All common apt errors have been checked and fixed."
}






# New function to check and fix errors without a loop
error_fix() {
    echo "Attempting to fix errors..."
    
    apt_sources_list_update
    fix_apt_update_errors
    fix_apt_errors
    
    

    # Check if all functions executed successfully
    if [ $? -eq 0 ]; then
        echo "All functions executed successfully!"
    else
        echo "Error occurred in one of the functions. Attempting to reinstall Rust and try again."
    fi
}



# Call the error_fix function
error_fix

# Update and upgrade the system at the end
echo "Updating and upgrading the system..."
sudo apt-get update && sudo apt-get upgrade -y
if [ $? -eq 0 ]; then
    echo "System updated and upgraded successfully!"
else
    echo "Failed to update and upgrade the system!" >&2
fi


