#!/bin/bash

# Display startup message
echo "============================"
echo "  Packages Manager by CryptoBureau"
echo "  For support, please fix any errors as per instructions."
echo "============================"


# Function to check system type and root privileges
master_fun() {
    echo "Checking system requirements..."

    # Check if the system is Ubuntu
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" != "ubuntu" ]; then
            echo "This script is designed for Ubuntu. Exiting."
            exit 1
        fi
    else
        echo "Cannot detect operating system. Exiting."
        exit 1
    fi

    # Check if the user is root
    if [ "$EUID" -ne 0 ]; then
        echo "You are not running as root. Please enter root password to proceed."
        sudo -k  # Force the user to enter password
        if sudo true; then
            echo "Switched to root user."
        else
            echo "Failed to gain root privileges. Exiting."
            exit 1
        fi
    else
        echo "You are running as root."
    fi

    echo "System check passed. Proceeding to package installation..."
    main_fun  # Call main function if all checks pass
}



# Function to install or update Node.js and NPM
install_node() {
    # Check if Node.js is installed
    if command -v node &> /dev/null; then
        echo "Node.js is already installed. Updating Node.js using your custom script..."

        # Download and run the Node.js update script
        curl -s https://raw.githubusercontent.com/CryptoBureau01/packages/main/packages/node-setup.sh -o node-setup.sh && chmod +x node-setup.sh && sudo ./node-setup.sh \
        || { echo "Node.js update failed!" >&2; return 1; }

        echo "Node.js updated successfully!"
    else
        echo "Node.js is not installed. Please install Node.js first."
        return 1
    fi
}





# Main function to monitor all installations
main_fun() {
    echo "Starting package installations..."

    install_node

    echo "All package installations completed!"
}


# Call the master function first
master_fun
