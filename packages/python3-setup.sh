#!/bin/bash

# Function to install Python 3
install_python() {
    echo "Updating package index..."
    sudo apt-get update && sudo apt-get upgrade -y

    echo "Installing required packages..."
    sudo apt-get install -y \
        build-essential \
        libssl-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        libffi-dev \
        zlib1g-dev \
        wget

    # Define Python version
    PYTHON_VERSION="3.13.0"  # Set to the latest stable release

    echo "Downloading Python $PYTHON_VERSION..."
    wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz

    echo "Extracting Python..."
    tar -xvf Python-$PYTHON_VERSION.tgz
    cd Python-$PYTHON_VERSION || exit

    echo "Configuring Python installation..."
    ./configure --enable-optimizations

    echo "Building and installing Python..."
    make -j "$(nproc)"
    sudo make altinstall

    echo "Cleaning up..."
    cd .. || exit
    rm -rf Python-$PYTHON_VERSION*
    echo "Python $PYTHON_VERSION installed successfully!"
}

# Function to install pip and test installation
install_pip() {
    echo "Installing pip..."
    for i in {1..5}; do
        sudo apt-get install -y python3-pip
        if command -v pip3 &> /dev/null; then
            echo "pip installed successfully!"
            return
        else
            echo "pip installation failed. Retrying... ($i)"
            sleep 1  # Wait for a second before retrying
        fi
    done
    echo "Failed to install pip after 5 attempts!" >&2
}

# Function to check apt installations
check_apt_installation() {
    echo "Checking apt installations..."
    for i in {1..5}; do
        if sudo apt-get update; then
            echo "apt is working properly!"
            return
        else
            echo "apt update failed. Retrying... ($i)"
            sleep 1  # Wait for a second before retrying
        fi
    done
    echo "Failed to run apt update after 5 attempts!" >&2
}

# Function to handle common apt errors
fix_apt_errors() {
    echo "Checking and fixing common apt errors..."

    # Install python3-apt if it's not installed
    if ! dpkg -l | grep -q python3-apt; then
        echo "Installing python3-apt..."
        sudo apt-get install -y python3-apt
    fi

    # Remove and reinstall command-not-found
    sudo apt remove -y command-not-found
    sudo apt install -y command-not-found

    # Clear apt lists and cache
    sudo rm -rf /var/lib/apt/lists/*
    sudo rm -rf /var/cache/apt/archives/*

    # Fix broken installs
    sudo apt --fix-broken install -y

    # Update command-not-found
    sudo update-command-not-found
}

# Function to install commonly used Python packages
all_func() {
    echo "Installing commonly used Python packages..."

    # Check if inside a virtual environment
    if [ -z "$VIRTUAL_ENV" ]; then
        echo "Please activate a virtual environment before running this script."
        return 1  # Exit the function if not in a venv
    fi

    # Upgrade pip
    pip3 install --upgrade pip

    # List of commonly used Python packages
    COMMON_PACKAGES=(
        "requests"
        "beautifulsoup4"
        "pytest"
        "jupyter"
        "web3"  # Added Web3 package
    )

    # Loop through each package and install it, retrying if installation fails
    for package in "${COMMON_PACKAGES[@]}"; do
        while true; do
            pip3 install "$package"
            if [ $? -eq 0 ]; then
                echo "$package installed successfully!"
                break  # Exit the loop if installation was successful
            else
                echo "Failed to install $package! Retrying..."
                sleep 2  # Wait for a couple of seconds before retrying
            fi
        done
    done

    echo "All packages installed!"
}
# Function to test the installation of packages
test_fun() {
    echo "Testing installed packages..."

    # List of packages to test
    COMMON_PACKAGES=(
       "requests"
        "beautifulsoup4"
        "pytest"
        "jupyter"
        "web3"  # Added Web3 package
    )

    for package in "${COMMON_PACKAGES[@]}"; do
        echo "Testing $package..."
        python3 -c "import $package" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "$package is working properly!"
        else
            echo "Error: $package is not working! Reinstalling..."
            all_func  # Call all_func to reinstall packages
            return  # Exit after attempting to reinstall
        fi
    done

    echo "All packages are working correctly!"
}

# New function to check and fix errors
error_fix() {
    for attempt in {1..5}; do
        echo "Attempt $attempt to fix errors..."
        
        install_pip
        check_apt_installation
        fix_apt_errors
        all_func
        test_fun

        # Check if all functions executed successfully
        if [ $? -eq 0 ]; then
            echo "All functions executed successfully!"
            break  # Exit the loop if successful
        else
            echo "Error occurred in one of the functions. Retrying all functions... ($attempt)"
            sleep 2  # Wait before the next attempt
            install_python  # Reinstall Python if there's an error
        fi
    done
    echo "Failed to fix errors after 5 attempts!" >&2
}

# Call the error_fix function
error_fix

# Update and upgrade the system at the end
echo "Updating and upgrading the system..."
sudo apt-get update && sudo apt-get upgrade -y
if [ $? -eq 0 ]; then
    echo "System updated and upgraded successfully!"
else
    echo "Failed to update and upgrade the system!" >&2
fi
