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




# Function to install or update Node.js and NPM
install_node() {
    # Check if Node.js is installed
    if command -v node &> /dev/null; then
        # Get the current version of Node.js
        NODE_VERSION=$(node -v | grep -oP '\d+\.\d+\.\d+' | head -1)
        echo "Current Node.js version: $NODE_VERSION"

        # Compare the current version to 23.0.0
        if [[ $(echo "$NODE_VERSION < 23" | bc -l) -eq 1 ]]; then
            echo "Node.js version is below 23. Updating Node.js using your custom script..."

            # Download and run the Node.js update script
            curl -s https://raw.githubusercontent.com/CryptoBureau01/packages/main/packages/node-setup.sh -o node-setup.sh && \
            chmod +x node-setup.sh && sudo ./node-setup.sh \
            || { echo "Node.js update failed!" >&2; return 1; }

            echo "Node.js updated successfully!"
        else
            echo "Node.js is already up-to-date (version 23 or higher). No update needed."
        fi
    else
        echo "Node.js is not installed. Please install Node.js first."
        return 1
    fi

    sudo rm -rf node-setup.sh
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

    sudo rm -rf go-setup.sh
}



# Function to install Docker
install_docker() {
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
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
    else
        echo "Docker is already installed. No installation needed."
    fi
}



# Function to install Docker Compose
install_docker_compose() {
    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null; then
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
    else
        echo "Docker Compose is already installed. No installation needed."
    fi
}




# Main function to monitor all installations
main_fun() {
    echo "Starting package installations..."

    install_python
    install_node
    install_rust
    install_go
    install_docker
    install_docker_compose

    echo "All package installations completed!"
}

# Call the master function first
master_fun
