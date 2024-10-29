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



# Function to install Docker
install_docker() {
    # Check if Docker is installed
    if command -v docker &> /dev/null; then
        # Get the current version
        current_version=$(docker --version | awk '{print $3}' | sed 's/,//')
        
        # Compare the version
        if [ "$(printf '%s\n' "$current_version" "27.3.1" | sort -V | head -n1)" != "27.3.1" ]; then
            echo "Current Docker version ($current_version) is less than 27.3.1. Updating..."
            
            # Remove old versions
            sudo apt-get remove docker docker-engine docker.io containerd runc -y
            sudo apt-get remove --purge docker-ce -y
            
            # Update the package index
            sudo apt update
            
            # Install required packages
            sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
            
            # Add Docker’s official GPG key
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            
            # Add Docker repository
            echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
            
            # Update the package index again
            sudo apt update
            
            # Install Docker
            sudo apt install docker-ce -y
            
            # Start Docker service
            sudo systemctl start docker
            
            # Enable Docker to start on boot
            sudo systemctl enable docker
            
            echo "Docker updated successfully!"
        else
            echo "Docker is already up to date (version: $current_version)."
        fi
    else
        echo "Docker is not installed. Installing Docker..."
        
        # Update the package index
        sudo apt update
        
        # Install required packages
        sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
        
        # Add Docker’s official GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        
        # Add Docker repository
        echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
        
        # Update the package index again
        sudo apt update
        
        # Install Docker
        sudo apt install docker-ce -y
        
        # Start Docker service
        sudo systemctl start docker
        
        # Enable Docker to start on boot
        sudo systemctl enable docker
        
        echo "Docker installed successfully!"
    fi

    # Show the version
    docker --version
}





# Main function to monitor all installations
main_fun() {
    echo "Starting package installations..."

    install_docker


    echo "All package installations completed!"
}


# Call the master function first
master_fun
