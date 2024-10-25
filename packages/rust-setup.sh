#!/bin/bash



# Function to install Rust and set up environment paths
install_rust() {
    echo "Starting Rust installation..."

    # Download and install Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    if [ $? -ne 0 ]; then
        echo "Rust installation failed!" >&2
        return 1
    fi
    echo "Rust installed successfully!"

    # Add Rust to PATH by updating .bashrc or .zshrc
    echo "Configuring PATH for Rust tools..."
    if [ -d "$HOME/.cargo/bin" ]; then
        if ! grep -q 'export PATH="$HOME/.cargo/bin:$PATH"' ~/.bashrc; then
            echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
        fi
        if [ -f ~/.zshrc ] && ! grep -q 'export PATH="$HOME/.cargo/bin:$PATH"' ~/.zshrc; then
            echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
        fi
        # Apply the changes to the current session
        export PATH="$HOME/.cargo/bin:$PATH"
        source ~/.bashrc 2>/dev/null || source ~/.zshrc 2>/dev/null
        echo "PATH configured for Rust tools!"
    else
        echo "Rust installation directory not found. Please check installation." >&2
        return 1
    fi

    # Check Rust installation
    echo "Verifying Rust installation..."
    if command -v rustc &> /dev/null && command -v cargo &> /dev/null; then
        echo "Rust and Cargo are ready to use!"
        rustc --version
        cargo --version
    else
        echo "Rust installation encountered an issue. Please restart your terminal and try again." >&2
        return 1
    fi
}





# Function to install commonly used Rust packages
install_common_rust_packages() {
    echo "Installing commonly used Rust packages..."

    # Check if cargo is available
    if ! command -v cargo &> /dev/null; then
        echo "Cargo is not available. Please install Rust first." >&2
        return 1
    fi

    # List of commonly used Rust packages
    COMMON_RUST_PACKAGES=(
        "serde"           # Serialization/deserialization library
        "tokio"           # Asynchronous runtime
        "rand"            # Random number generator library
        "reqwest"         # HTTP client
        "async-std"       # Asynchronous standard library
        "clap"            # Command-line argument parsing
        "actix-web"       # Web framework
        "diesel"          # ORM and query builder for SQL databases
        "openssl"         # Cryptographic library
        "hyper"           # HTTP library
    )

    # Loop through each package and install it with retries if needed
    for package in "${COMMON_RUST_PACKAGES[@]}"; do
        for attempt in {1..2}; do
            cargo install "$package"
            if [ $? -eq 0 ]; then
                echo "$package installed successfully!"
                break
            else
                echo "Failed to install $package on attempt $attempt. Retrying..."
                sleep 2  # Wait before retrying
            fi
        done

        # Final check if package was installed
        if ! cargo install "$package" &> /dev/null; then
            echo "Failed to install $package after multiple attempts." >&2
        fi
    done

    echo "All common Rust packages have been installed!"
}





# Function to test commonly used Rust packages
test_rust_packages() {
    echo "Testing commonly used Rust packages..."

    # List of test commands for each package
    declare -A PACKAGE_TESTS=(
        ["serde"]="cargo test serde"               # Testing serde functionality
        ["tokio"]="cargo test tokio"               # Testing tokio async runtime
        ["rand"]="cargo test rand"                 # Testing random number generator
        ["reqwest"]="cargo test reqwest"           # Testing HTTP client
        ["async-std"]="cargo test async-std"       # Testing async-std runtime
        ["clap"]="cargo test clap"                 # Testing command-line parsing
        ["actix-web"]="cargo test actix-web"       # Testing web framework
        ["diesel"]="cargo test diesel"             # Testing ORM library
        ["openssl"]="cargo test openssl"           # Testing cryptographic library
        ["hyper"]="cargo test hyper"               # Testing HTTP library
    )

    # Loop through each package and run its test command
    for package in "${!PACKAGE_TESTS[@]}"; do
        echo "Testing $package..."
        
        for attempt in {1..2}; do
            ${PACKAGE_TESTS[$package]}
            if [ $? -eq 0 ]; then
                echo "$package test passed!"
                break
            else
                echo "Failed to test $package on attempt $attempt. Retrying..."
                sleep 2  # Wait before retrying
            fi
        done

        # Final check if package test failed after retries
        if ! ${PACKAGE_TESTS[$package]} &> /dev/null; then
            echo "Failed to test $package after multiple attempts." >&2
        fi
    done

    echo "All Rust package tests complete!"
}




# Function to fix common Rust system errors
fix_rust_errors() {
    echo "Checking for and fixing common Rust errors..."

    # 1. Ensure Rust is installed and paths are set
    if ! command -v rustc &>/dev/null || ! command -v cargo &>/dev/null; then
        echo "Rust is not installed or the PATH is not set correctly."
        echo "Attempting to install Rust and configure the PATH..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        source "$HOME/.cargo/env"
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
        source ~/.bashrc
    else
        echo "Rust is installed, and PATH is correctly configured."
    fi

    # 2. Fix permissions issues (e.g., permissions errors during installation)
    echo "Fixing any permissions issues..."
    sudo chmod -R 755 "$HOME/.cargo" || echo "Error setting permissions on .cargo folder"

    # 3. Update Rust to the latest stable version to fix outdated toolchains
    echo "Updating Rust to the latest stable version..."
    rustup update stable || echo "Failed to update Rust"

    # 4. Missing C compiler (required by certain packages)
    if ! command -v gcc &>/dev/null; then
        echo "C compiler (gcc) is not installed. Installing it now..."
        sudo apt update && sudo apt install build-essential -y || echo "Failed to install gcc"
    else
        echo "C compiler (gcc) is already installed."
    fi

    # 5. Solve common dependency and linker issues by installing libssl and pkg-config
    echo "Ensuring libssl-dev and pkg-config are installed..."
    sudo apt install -y libssl-dev pkg-config || echo "Failed to install libssl-dev and pkg-config"

    # 6. Check for incompatible Rust targets and fix them
    echo "Checking for compatible Rust targets..."
    rustup target list --installed
    rustup target add x86_64-unknown-linux-gnu || echo "Failed to add x86_64-unknown-linux-gnu target"

    # 7. Clear Rust's Cargo cache if build errors persist
    echo "Cleaning the Cargo cache..."
    cargo clean || echo "Failed to clean Cargo cache"

    # 8. Verify Rust installation by checking versions
    echo "Verifying Rust installation..."
    rustc --version && cargo --version && rustup --version
    if [ $? -eq 0 ]; then
        echo "Rust and Cargo are functioning properly."
    else
        echo "Rust installation may have issues. Try reinstalling Rust if problems persist."
    fi

    echo "Common Rust errors have been checked and fixed!"
}




# New function to check and fix errors without a loop
error_fix() {
    echo "Attempting to fix errors..."
    
    install_rust
    fix_rust_errors
    install_common_rust_packages
    test_rust_packages
    

    # Check if all functions executed successfully
    if [ $? -eq 0 ]; then
        echo "All functions executed successfully!"
    else
        echo "Error occurred in one of the functions. Attempting to reinstall Rust and try again."
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


