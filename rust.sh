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



# Function to install Rust
install_rust() {
    # Check if Rust is installed
    if ! command -v rustc &> /dev/null; then
        echo "Rust is not installed. Installing Rust using your custom script..."

        # Download and run the Rust installation script
        curl -s https://raw.githubusercontent.com/CryptoBureau01/packages/main/packages/rust-setup.sh -o rust-setup.sh && \
        chmod +x rust-setup.sh && sudo ./rust-setup.sh \
        || { echo "Rust installation failed!" >&2; return 1; }

        echo "Rust installed successfully!"
    else
        echo "Rust is already installed. No installation needed."
    fi

    sudo rm -rf rust-setup.sh
}




# Main function to monitor all installations
main_fun() {
    echo "Starting package installations..."

    install_rust

    echo "All package installations completed!"
}


# Call the master function first
master_fun
