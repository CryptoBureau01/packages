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







# New function to check and fix errors without a loop
error_fix() {
    echo "Attempting to fix errors..."
    
    apt_sources_list_update
    fix_apt_update_errors
    install_common_rust_packages
    test_rust_packages
    

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


