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



# Function to install Python and pip
install_python() {
    echo "Checking for existing Python installations..."
    max_attempts=5
    attempt=1

    while true; do
        if command -v python3 &> /dev/null; then
            echo "Python 3 is installed. Attempting to remove existing versions..."
            sudo apt-get remove --purge -y python3*
            if [ $? -eq 0 ]; then
                echo "Existing Python installations removed successfully."
            else
                echo "Failed to remove existing Python installations!" >&2
                return 1
            fi
        else
            echo "No existing Python 3 installation found."
            break
        fi

        if [ $attempt -ge $max_attempts ]; then
            echo "Maximum attempts reached for Python. Exiting." >&2
            return 1
        fi

        attempt=$((attempt + 1))
    done

    echo "Starting Python installation..."
    bash <(curl -s https://raw.githubusercontent.com/CryptoBureau01/packages/main/packages/python3-setup.sh)
    if [ $? -eq 0 ]; then
        echo "Python installed successfully!"
    else
        echo "Python installation failed!" >&2
    fi
}




# Main function to monitor all installations
main_fun() {
    echo "Starting package installations..."

    install_python

    echo "All package installations completed!"
}


# Call the master function first
master_fun
