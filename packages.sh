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
    bash ./packages/python-setup.sh
    if [ $? -eq 0 ]; then
        echo "Python installed successfully!"
    else
        echo "Python installation failed!" >&2
    fi
}



# Function to install Node.js and npm
install_node() {
    echo "Checking for existing Node.js installations..."
    max_attempts=5
    attempt=1

    while true; do
        if command -v node &> /dev/null; then
            echo "Node.js is installed. Attempting to remove existing versions..."
            sudo apt-get remove --purge -y nodejs*
            if [ $? -eq 0 ]; then
                echo "Existing Node.js installations removed successfully."
            else
                echo "Failed to remove existing Node.js installations!" >&2
                return 1
            fi
        else
            echo "No existing Node.js installation found."
            break
        fi

        if [ $attempt -ge $max_attempts ]; then
            echo "Maximum attempts reached for Node.js. Exiting." >&2
            return 1
        fi

        attempt=$((attempt + 1))
    done

    echo "Starting Node.js installation..."
    bash ./packages/node-setup.sh
    if [ $? -eq 0 ]; then
        echo "Node.js installed successfully!"
    else
        echo "Node.js installation failed!" >&2
    fi
}



# Function to install Rust
install_rust() {
    echo "Checking for existing Rust installations..."
    max_attempts=5
    attempt=1

    while true; do
        if command -v rustc &> /dev/null; then
            echo "Rust is installed. Attempting to remove existing versions..."
            sudo apt-get remove --purge -y rust*
            if [ $? -eq 0 ]; then
                echo "Existing Rust installations removed successfully."
            else
                echo "Failed to remove existing Rust installations!" >&2
                return 1
            fi
        else
            echo "No existing Rust installation found."
            break
        fi

        if [ $attempt -ge $max_attempts ]; then
            echo "Maximum attempts reached for Rust. Exiting." >&2
            return 1
        fi

        attempt=$((attempt + 1))
    done

    echo "Starting Rust installation..."
    bash ./packages/rust-setup.sh
    if [ $? -eq 0 ]; then
        echo "Rust installed successfully!"
    else
        echo "Rust installation failed!" >&2
    fi
}



# Function to install Docker
install_docker() {
    echo "Checking for existing Docker installations..."
    max_attempts=5
    attempt=1

    while true; do
        if command -v docker &> /dev/null; then
            echo "Docker is installed. Attempting to remove existing versions..."
            sudo apt-get remove --purge -y docker*
            if [ $? -eq 0 ]; then
                echo "Existing Docker installations removed successfully."
            else
                echo "Failed to remove existing Docker installations!" >&2
                return 1
            fi
        else
            echo "No existing Docker installation found."
            break
        fi

        if [ $attempt -ge $max_attempts ]; then
            echo "Maximum attempts reached for Docker. Exiting." >&2
            return 1
        fi

        attempt=$((attempt + 1))
    done

    echo "Starting Docker installation..."
    bash ./packages/docker-setup.sh
    if [ $? -eq 0 ]; then
        echo "Docker installed successfully!"
    else
        echo "Docker installation failed!" >&2
    fi
}



# Function to install Docker Compose
install_docker_compose() {
    echo "Checking for existing Docker Compose installations..."
    max_attempts=5
    attempt=1

    while true; do
        if command -v docker-compose &> /dev/null; then
            echo "Docker Compose is installed. Attempting to remove existing versions..."
            sudo apt-get remove --purge -y docker-compose*
            if [ $? -eq 0 ]; then
                echo "Existing Docker Compose installations removed successfully."
            else
                echo "Failed to remove existing Docker Compose installations!" >&2
                return 1
            fi
        else
            echo "No existing Docker Compose installation found."
            break
        fi

        if [ $attempt -ge $max_attempts ]; then
            echo "Maximum attempts reached for Docker Compose. Exiting." >&2
            return 1
        fi

        attempt=$((attempt + 1))
    done

    echo "Starting Docker Compose installation..."
    bash ./packages/docker-compose-setup.sh
    if [ $? -eq 0 ]; then
        echo "Docker Compose installed successfully!"
    else
        echo "Docker Compose installation failed!" >&2
    fi
}




# Main function to monitor all installations
main_fun() {
    echo "Starting package installations..."

    install_python
    install_node
    install_rust
    install_docker
    install_docker_compose

    echo "All package installations completed!"
}

# Call the master function first
master_fun
