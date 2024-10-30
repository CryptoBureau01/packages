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



# Function to install or update Rust
install_rust() {
    # Required Rust version
    required_version="1.81.0"

    # Check if Rust is installed and get the current version
    if command -v rustc &> /dev/null; then
        current_version=$(rustc --version | awk '{print $2}')

        # Compare current version with required version
        if [[ "$current_version" == "$required_version" || "$current_version" > "$required_version" ]]; then
            echo "Rust is already up-to-date (version $current_version). No installation needed."
            return 0
        else
            echo "An older version of Rust ($current_version) is installed. Updating Rust..."
        fi
    else
        echo "Rust is not installed. Installing Rust using your custom script..."
    fi

    # Download and run the Rust installation script
    curl -s https://raw.githubusercontent.com/CryptoBureau01/packages/main/packages/rust-setup.sh -o rust-setup.sh && \
    chmod +x rust-setup.sh && sudo ./rust-setup.sh \
    || { echo "Rust installation failed!" >&2; return 1; }

    echo "Rust installed successfully!"
    
    # Clean up installation script
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
