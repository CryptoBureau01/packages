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



# Function to install or update Python 3 and pip
install_python() {
    # Check if Python 3 is installed
    if command -v python3 &> /dev/null; then
        # Get the current Python 3 version
        PYTHON_VERSION=$(python3 --version | grep -oP '\d+\.\d+\.\d+')
        echo "Current Python 3 version: $PYTHON_VERSION"

        # Compare the current version to 3.13.0
        if [[ $(echo "$PYTHON_VERSION < 3.13.0" | bc -l) -eq 1 ]]; then
            echo "Python 3 version is below 3.13.0. Updating Python using your custom script..."

            # Download and run the Python update script
            curl -s https://raw.githubusercontent.com/CryptoBureau01/packages/main/packages/python3-setup.sh -o python3-setup.sh && \
            chmod +x python3-setup.sh && sudo ./python3-setup.sh \
            || { echo "Python 3 update failed!" >&2; return 1; }

            echo "Python 3 updated successfully!"
        else
            echo "Python 3 is already up-to-date (version 3.13.0 or higher). No update needed."
        fi
    else
        echo "Python 3 is not installed. Exiting without any changes."
        return 1
    fi

    sudo rm -rf python3-setup.sh
}



# Main function to monitor all installations
main_fun() {
    echo "Starting package installations..."

    install_python

    echo "All package installations completed!"
}


# Call the master function first
master_fun
