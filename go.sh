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



# Function to install or update Go
install_go() {
    # Check if Go is installed
    if command -v go &> /dev/null; then
        # Get the current Go version
        GO_VERSION=$(go version | grep -oP '\d+\.\d+\.\d+')
        echo "Current Go version: $GO_VERSION"

        # Compare the current version to 1.23.2
        if [[ $(echo "$GO_VERSION < 1.23.2" | bc -l) -eq 1 ]]; then
            echo "Go version is below 1.23.2. Updating Go using your custom script..."

            # Download and run the Go update script
            curl -s https://raw.githubusercontent.com/CryptoBureau01/packages/main/packages/go-setup.sh -o go-setup.sh && \
            chmod +x go-setup.sh && sudo ./go-setup.sh \
            || { echo "Go update failed!" >&2; return 1; }

            echo "Go updated successfully!"
        else
            echo "Go is already up-to-date (version 1.23.2 or higher). No update needed."
        fi
    else
        echo "Go is not installed. Exiting without any changes."
        return 1
    fi
}



# Main function to monitor all installations
main_fun() {
    echo "Starting package installations..."

    install_go

    echo "All package installations completed!"
}


# Call the master function first
master_fun




