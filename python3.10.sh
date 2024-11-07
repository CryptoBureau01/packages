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


# Function to install or update Python 3.10 and pip
install_python() {
    # Update and install necessary prerequisites
    echo "Updating package list and installing prerequisites..."
    sudo apt update
    sudo apt install -y software-properties-common

    # Add deadsnakes PPA (a reliable source for Python packages)
    echo "Adding deadsnakes PPA for Python packages..."
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt update

    # Install Python 3.10
    echo "Installing Python 3.10..."
    sudo apt install -y python3.10

    # Verify installation
    echo "Verifying Python 3.10 installation..."
    python3.10 --version

    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
    sudo update-alternatives --set python3 /usr/bin/python3.10

    sudo apt install python3.10-dev
    sudo apt install python3.10-distutils
    sudo apt install build-essential
    python3.11 -m pip install virtualenv
    pip install -r requirements.txt 


    # Clean up by removing the script file if it exists
    [[ -f "python3.10.sh" ]] && sudo rm -rf python3.10.sh
}



# Main function to monitor all installations
main_fun() {
    echo "Starting package installations..."

    install_python

    echo "All package installations completed!"
}


# Call the master function first
master_fun
