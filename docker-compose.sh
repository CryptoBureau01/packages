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



# Function to install Docker Compose
install_docker_compose() {
    # Check if Docker Compose is installed
    if command -v docker-compose &> /dev/null; then
        # Get the current version
        current_version=$(docker-compose --version | awk '{print $3}' | sed 's/,//')
        
        # Compare the version
        if [ "$(printf '%s\n' "$current_version" "v2.20.2" | sort -V | head -n1)" != "v2.20.2" ]; then
            echo "Current Docker Compose version ($current_version) is less than v2.20.2. Updating..."
            
            # Remove old versions
            sudo rm /usr/bin/docker-compose
            sudo rm /usr/local/bin/docker-compose
            
            # Download the new version
            sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            
            # Apply executable permissions
            sudo chmod +x /usr/local/bin/docker-compose
            
            echo "Docker Compose updated successfully!"
        else
            echo "Docker Compose is already up to date (version: $current_version)."
        fi
    else
        echo "Docker Compose is not installed. Installing Docker Compose..."
        
        # Download the latest version of Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        
        # Apply executable permissions to the binary
        sudo chmod +x /usr/local/bin/docker-compose
        
        # Verify the installation
        if command -v docker-compose &> /dev/null; then
            echo "Docker Compose installed successfully!"
        else
            echo "Docker Compose installation failed!" >&2
        fi
    fi

    # Clear the command hash
    hash -r
    
    # Show the version
    docker-compose --version
}


# Main function to monitor all installations
main_fun() {
    echo "Starting package installations..."

    install_docker_compose


    echo "All package installations completed!"
}


# Call the master function first
master_fun
