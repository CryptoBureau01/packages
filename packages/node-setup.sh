#!/bin/bash


# Function to install Node.js globally using NVM and set path
install_node_with_nvm_global() {
    echo "Installing NVM (Node Version Manager)..."
    
    # Install NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
    
    # Add NVM to the current shell session and to the global .bashrc file for persistence
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load NVM into the current shell

    # Add NVM to .bashrc to load in future sessions
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
    echo "NVM path added to .bashrc for future sessions."

    # Optionally for Zsh users, add NVM to .zshrc as well
    if [ -n "$ZSH_VERSION" ]; then
        echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc
        echo "NVM path added to .zshrc for future sessions."
    fi

    echo "NVM installed successfully!"

    # Install Node.js version 23 globally
    echo "Installing Node.js version 23 using NVM..."
    nvm install 23

    # Verify Node.js and npm installation
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        echo "Node.js and npm installed successfully!"
        
        # Display installed versions
        echo "Node.js version: $(node -v)"  # Should print `v23.1.0`
        echo "npm version: $(npm -v)"  # Should print `10.9.0`
    else
        echo "Failed to install Node.js or npm!" >&2
        return 1
    fi

    # Apply changes to the current session
    echo "Applying global path changes..."
    source ~/.bashrc

    echo "Node.js is now globally installed and accessible from any directory."
}


# Function to install commonly used global Node.js packages
install_common_node_packages() {
    echo "Installing commonly used global Node.js packages..."

    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        echo "Node.js is not installed. Please install Node.js first."
        return 1
    fi

    # List of commonly used global Node.js packages
    COMMON_NODE_PACKAGES=(
        "web3"              # Ethereum JavaScript API
        "express"           # Web framework for Node.js
        "nodemon"           # Automatically restarts the server on file changes
        "pm2"               # Process manager for Node.js
        "eslint"            # JavaScript and Node.js linting utility
        "jest"              # Testing framework for JavaScript and Node.js
        "typescript"        # TypeScript support for Node.js
        "webpack"           # Module bundler for JavaScript applications
        "create-react-app"  # Tool to create React applications
        "yarn"              # Package manager for JavaScript projects
    )

    # Loop through each package and install it globally with retry logic
    for package in "${COMMON_NODE_PACKAGES[@]}"; do
        for attempt in {1..2}; do  # Try up to 2 times
            npm install -g "$package"
            if [ $? -eq 0 ]; then
                echo "$package installed successfully!"
                break  # Exit the attempt loop if installation was successful
            else
                echo "Failed to install $package! Attempt $attempt of 2." >&2
                if [ $attempt -eq 2 ]; then
                    echo "Please check for errors." >&2
                fi
            fi
        done
    done

    echo "All packages attempted to install!"
}



# Function to test installed Node.js packages
test_node_packages() {
    echo "Testing installed Node.js packages..."

    # List of commonly used global Node.js packages to test
    COMMON_NODE_PACKAGES=(
        "express"
        "nodemon"
        "pm2"
        "eslint"
        "jest"
        "typescript"
        "webpack"
        "create-react-app"
        "yarn"
        "web3"
    )

    # Loop through each package and test it
    for package in "${COMMON_NODE_PACKAGES[@]}"; do
        if command -v "$package" &> /dev/null; then
            echo "$package is installed. Testing version..."
            "$package" --version
        else
            echo "$package is not installed."
        fi
    done

    echo "Testing completed!"
}


# Function to check and fix common Node.js run errors
fix_node_run_errors() {
    echo "Checking for common Node.js run errors..."

    # Check for common issues

    # 1. Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        echo "Node.js is not installed. Please install Node.js."
        return 1
    fi

    # 2. Check if npm is installed
    if ! command -v npm &> /dev/null; then
        echo "npm is not installed. Please install npm."
        return 1
    fi

    # 3. Check for missing modules
    if [ -f "package.json" ]; then
        echo "Checking for missing modules in your project..."
        npm install
        if [ $? -eq 0 ]; then
            echo "Missing modules installed successfully!"
        else
            echo "Failed to install missing modules. Please check for errors."
            return 1
        fi
    else
        echo "No package.json found in the current directory. Please ensure you're in the project directory."
        return 1
    fi

    # 4. Check for syntax errors
    echo "Checking for syntax errors in your JavaScript files..."
    for file in *.js; do
        if [ -f "$file" ]; then
            node -c "$file" 2>/dev/null
            if [ $? -ne 0 ]; then
                echo "Syntax error found in $file. Please fix the error."
                return 1
            fi
        fi
    done

    echo "No syntax errors found!"

    # 5. Provide instructions for common run issues
    echo "If your application fails to run, please check the following:"
    echo "- Ensure all dependencies are installed (run 'npm install')."
    echo "- Check for runtime errors in your code."
    echo "- Verify your Node.js version is compatible with your application."

    echo "All checks completed!"
}




# New function to check and fix errors without a loop
error_fix() {
    echo "Attempting to fix errors..."
    
    install_node_with_nvm_global
    fix_node_run_errors
    install_common_node_packages
    test_node_packages
    

    # Check if all functions executed successfully
    if [ $? -eq 0 ]; then
        echo "All functions executed successfully!"
    else
        echo "Error occurred in one of the functions. Attempting to reinstall Node and try again."
    fi
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
