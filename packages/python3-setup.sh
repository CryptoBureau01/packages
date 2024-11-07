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

    # Optional: Set Python 3.13 as the default python3
    read -p "Do you want to set Python 3.13 as the default python3? (y/n): " set_default
    if [[ $set_default == "y" ]]; then
        echo "Setting Python 3.13 as the default python3..."
        
        sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 1
        echo "Python 3.13 set as default."
    else
        echo "Python 3.13 installed, but not set as default."
    fi
    
    echo "Configuring Python installation..."
    ./configure --enable-optimizations

    echo "Building and installing Python..."
    make -j "$(nproc)"
    sudo make altinstall

    echo "Cleaning up..."
    cd .. || exit
    rm -rf Python-$PYTHON_VERSION*
    echo "Python $PYTHON_VERSION installed successfully!"

    # Install python3-venv
    echo "Installing python3-venv..."
    sudo apt install -y python3-venv

    # Add virtual environment path to ~/.bashrc
    echo "Adding venv path to ~/.bashrc..."
    echo 'export PATH="/home/user/myenv/bin:$PATH"' >> ~/.bashrc

    # Source ~/.bashrc to apply the changes
    echo "Applying changes..."
    source ~/.bashrc

    echo "Setup completed successfully!"
}


# Function to install pip and test installation
install_pip() {
    echo "Installing pip..."
    for i in {1..2}; do
        sudo apt-get install -y python3-pip
        if command -v pip3 &> /dev/null; then
            echo "pip installed successfully!"
            return
        else
            echo "pip installation failed. Retrying... ($i)"
            sleep 1  # Wait for a second before retrying
        fi
    done
    echo "Failed to install pip after 2 attempts!" >&2
}


# Function to install Poetry with a retry loop
install_poetry() {
    for attempt in {1..2}; do
        echo "Attempt $attempt to install Poetry..."

        # Download and run the Poetry installer script
        curl -sSL https://install.python-poetry.org | python3 -

        # Add Poetry to PATH in ~/.bashrc
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

        # Apply the PATH changes
        source ~/.bashrc

        # Check Poetry version to confirm installation
        poetry --version

        # Check if Poetry installed successfully
        if [ $? -eq 0 ]; then
            echo "Poetry installed successfully!"
            break  # Exit the loop if installation is successful
        else
            echo "Poetry installation failed. Retrying... ($attempt)"
            sleep 2  # Wait before the next attempt
        fi
    done

    # If all attempts fail, display an error message
    if [ $? -ne 0 ]; then
        echo "Failed to install Poetry after 2 attempts!" >&2
    fi
}




# Function to check apt installations
check_apt_installation() {
    echo "Checking apt installations..."
    for i in {1..2}; do
        if sudo apt-get update; then
            echo "apt is working properly!"
            return
        else
            echo "apt update failed. Retrying... ($i)"
            sleep 1  # Wait for a second before retrying
        fi
    done
    echo "Failed to run apt update after 2 attempts!" >&2
}




# Function to handle common apt errors
fix_apt_errors() {
    echo "Checking and fixing common apt errors..."

    # Install python3-apt if it's not installed
    if ! dpkg -l | grep -q python3-apt; then
        echo "Installing python3-apt..."
        sudo apt-get install -y python3-apt || { echo "Failed to install python3-apt. Exiting..."; return 1; }
    fi

    # Check for and reinstall command-not-found
    if dpkg -l | grep -q command-not-found; then
        echo "Reinstalling command-not-found..."
        sudo apt remove -y command-not-found || { echo "Failed to remove command-not-found. Exiting..."; return 1; }
    fi
    sudo apt install -y command-not-found || { echo "Failed to install command-not-found. Exiting..."; return 1; }

    # Clear apt lists and cache
    echo "Clearing apt lists and cache..."
    sudo rm -rf /var/lib/apt/lists/* || { echo "Failed to clear apt lists. Exiting..."; return 1; }
    sudo rm -rf /var/cache/apt/archives/* || { echo "Failed to clear apt archives. Exiting..."; return 1; }

    # Fix broken installs
    echo "Fixing broken installs..."
    sudo apt --fix-broken install -y || { echo "Failed to fix broken installs. Exiting..."; return 1; }

    # Update command-not-found
    echo "Updating command-not-found..."
    sudo update-command-not-found || { echo "Failed to update command-not-found. Exiting..."; return 1; }

    echo "All common apt errors have been checked and fixed."
}






# Function to install commonly used Python packages with retry logic
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
        "web3"  # Added Web3 package
        "virtualenv"
        "requests"
        "beautifulsoup4"
    )

    # Loop through each package and install it, retrying up to 5 times if installation fails
    for package in "${COMMON_PACKAGES[@]}"; do
        for attempt in {1..2}; do
            echo "Attempt $attempt to install $package..."
            pip3 install "$package"
            if [ $? -eq 0 ]; then
                echo "$package installed successfully!"
                break  # Exit the retry loop if installation was successful
            else
                echo "Failed to install $package. Retrying... ($attempt)"
                sleep 2  # Wait before the next attempt
            fi

            # If 5 attempts fail, display an error message
            if [ $attempt -eq 2 ]; then
                echo "Failed to install $package after 2 attempts!" >&2
            fi
        done
    done

    echo "All packages attempted for installation!"
}




# Function to test the installation of packages and reinstall if necessary
test_fun() {
    echo "Testing installed packages..."

    # List of packages to test with proper import names
    COMMON_PACKAGES=(
        "web3"  # Web3 package
        "virtualenv"
        "requests"
        "beautifulsoup4:bs4"  # 'beautifulsoup4' installs as 'bs4'
    )

    # Loop through each package
    for package in "${COMMON_PACKAGES[@]}"; do
        pkg_name="${package%%:*}"  # Package name for installation
        import_name="${package##*:}"  # Import name for testing

        # Test the import
        echo "Testing $pkg_name..."
        python3 -c "import $import_name" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "$pkg_name is working properly!"
        else
            echo "Error: $pkg_name is not working! Reinstalling..."
            pip install --upgrade --force-reinstall "$pkg_name"
            
            # Re-test the package after reinstalling
            python3 -c "import $import_name" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "$pkg_name has been reinstalled and is now working!"
            else
                echo "Error: $pkg_name could not be reinstalled. Please check manually."
                return 1  # Exit if package still fails
            fi
        fi
    done

    echo "All packages are working correctly!"
}





switch_to_python3_13() {
    echo "Checking installed Python versions..."
    ls /usr/bin/python3* 2>/dev/null
    ls /usr/local/bin/python3* 2>/dev/null
    
    # Set Python 3.13 path based on common installation directories
    if [ -f "/usr/local/bin/python3.13" ]; then
        PYTHON_PATH="/usr/local/bin/python3.13"
    elif [ -f "/usr/bin/python3.13" ]; then
        PYTHON_PATH="/usr/bin/python3.13"
    else
        echo "Python 3.13 is not installed in /usr/local/bin or /usr/bin."
        echo "Please install Python 3.13 before running this function."
        return 1
    fi
    
    echo "Adding Python 3.13 to alternatives..."
    sudo update-alternatives --install /usr/bin/python3 python3 "$PYTHON_PATH" 2
    
    echo "Setting Python 3.13 as the default version..."
    sudo update-alternatives --set python3 "$PYTHON_PATH"
    
    # Confirm the version
    echo "Default Python version is now set to:"
    python3 --version
}



# New function to check and fix errors without a loop
error_fix() {
    echo "Attempting to fix errors..."
    
    install_python
    install_pip
    install_poetry
    check_apt_installation
    fix_apt_errors
    all_func
    test_fun
    switch_to_python3_13

    # Check if all functions executed successfully
    if [ $? -eq 0 ]; then
        echo "All functions executed successfully!"
    else
        echo "Error occurred in one of the functions. Attempting to reinstall Python and try again."
    fi
}



# Call the error_fix function
error_fix

# Update and upgrade the system at the end
echo "Updating and upgrading the system..."
sudo apt-get update && sudo apt-get upgrade -y
echo "Python version Set Globally..."
switch_to_python3_13

if [ $? -eq 0 ]; then
    echo "System updated and upgraded successfully!"
else
    echo "Failed to update and upgrade the system!" >&2
fi
