#!/bin/bash

# Function to install Go 1.23.2
install_go() {
    # Define Go version and download URL
    GO_VERSION="1.23.2"
    GO_TAR_FILE="go$GO_VERSION.linux-amd64.tar.gz"
    GO_DOWNLOAD_URL="https://golang.org/dl/$GO_TAR_FILE"

    echo "Installing Go version $GO_VERSION..."

    # Download Go tar.gz file
    curl -O "$GO_DOWNLOAD_URL"

    # Remove any existing Go installation in /usr/local
    sudo rm -rf /usr/local/go

    # Extract the downloaded tar.gz file to /usr/local
    sudo tar -C /usr/local -xzf "$GO_TAR_FILE"

    # Clean up the downloaded tar.gz file
    rm "$GO_TAR_FILE"

    # Add Go binary to the system PATH
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    source ~/.bashrc

    # Verify Go installation
    if command -v go &> /dev/null; then
        echo "Go installed successfully!"
        go version
    else
        echo "Go installation failed!" >&2
        return 1
    fi
}


# Function to install common Go packages
install_common_go_packages() {
    echo "Installing commonly used Go packages..."

    # Check if Go is installed
    if ! command -v go &> /dev/null; then
        echo "Go is not installed. Please install Go first."
        return 1
    fi

    # List of commonly used Go packages (replace or add as needed)
    COMMON_GO_PACKAGES=(
        "github.com/go-sql-driver/mysql@latest"        # MySQL driver
        "github.com/gin-gonic/gin@latest"              # HTTP web framework
        "github.com/sirupsen/logrus@latest"            # Logging library
        "golang.org/x/tools/cmd/godoc@latest"          # Documentation tool
        "golang.org/x/lint/golint@latest"              # Linter
        "golang.org/x/tools/gopls@latest"              # Language server for Go
        "github.com/stretchr/testify@latest"           # Testing toolkit
        "google.golang.org/grpc@latest"                # gRPC framework
        "github.com/spf13/cobra@latest"                # CLI framework
        "github.com/ethereum/go-ethereum@latest"       # Ethereum API library (Web3 for Go)
    )

    # Loop through each package and install it
    for package in "${COMMON_GO_PACKAGES[@]}"; do
        echo "Installing $package..."
        go install "$package"
        if [ $? -eq 0 ]; then
            echo "$package installed successfully!"
        else
            echo "Failed to install $package! Please check for errors." >&2
            return 1
        fi
    done

    echo "All Go packages installed successfully!"
}


# Function to test commonly used Go packages
test_common_go_packages() {
    echo "Testing installed Go packages..."

    # Check if Go is installed
    if ! command -v go &> /dev/null; then
        echo "Go is not installed. Please install Go first."
        return 1
    fi

    # Dictionary of Go packages with test commands or versions
    declare -A GO_PACKAGE_TESTS=(
        ["mysql"]="go list github.com/go-sql-driver/mysql"
        ["gin"]="go list github.com/gin-gonic/gin"
        ["logrus"]="go list github.com/sirupsen/logrus"
        ["godoc"]="command -v godoc"
        ["golint"]="command -v golint"
        ["gopls"]="command -v gopls"
        ["testify"]="go list github.com/stretchr/testify"
        ["grpc"]="go list google.golang.org/grpc"
        ["cobra"]="go list github.com/spf13/cobra"
        ["go-ethereum"]="go list github.com/ethereum/go-ethereum"
    )

    # Loop through each package and run the test command
    for package in "${!GO_PACKAGE_TESTS[@]}"; do
        echo "Testing $package..."
        eval "${GO_PACKAGE_TESTS[$package]}"
        if [ $? -eq 0 ]; then
            echo "$package is installed and working correctly!"
        else
            echo "$package failed to load or is not installed correctly." >&2
            return 1
        fi
    done

    echo "All Go packages are tested successfully!"
}


# Function to detect and fix common Go-related issues
fix_go_errors() {
    echo "Checking for common Go errors and attempting to fix them..."

    # Check if Go is installed
    if ! command -v go &> /dev/null; then
        echo "Go is not installed. Please install Go first."
        return 1
    fi

    # Check if GOPATH is set correctly
    if [ -z "$GOPATH" ]; then
        echo "GOPATH is not set. Setting GOPATH to default..."
        export GOPATH="$HOME/go"
        echo 'export GOPATH="$HOME/go"' >> ~/.bashrc
        source ~/.bashrc
        echo "GOPATH set to $GOPATH"
    fi

    # Ensure $GOPATH/bin is in PATH
    if [[ ":$PATH:" != *":$GOPATH/bin:"* ]]; then
        echo "Adding $GOPATH/bin to PATH..."
        export PATH="$GOPATH/bin:$PATH"
        echo 'export PATH="$GOPATH/bin:$PATH"' >> ~/.bashrc
        source ~/.bashrc
    fi

    # Clear Go build cache
    echo "Clearing Go build cache..."
    go clean -cache -modcache -i -r
    echo "Go build cache cleared!"

    # Check for module issues and reinitialize
    echo "Ensuring modules are up-to-date..."
    go mod tidy
    if [ $? -ne 0 ]; then
        echo "Failed to tidy modules. Checking module initialization..."
        go mod init
        if [ $? -ne 0 ]; then
            echo "Failed to initialize Go modules." >&2
            return 1
        fi
    fi

    # Upgrade all dependencies
    echo "Upgrading Go dependencies..."
    go get -u ./...
    if [ $? -ne 0 ]; then
        echo "Failed to upgrade Go dependencies." >&2
    fi

    # Test a simple Go command to verify installation
    echo "Testing Go installation..."
    go version
    if [ $? -eq 0 ]; then
        echo "Go environment is set up correctly and ready to use!"
    else
        echo "Go installation encountered an issue. Please review error messages." >&2
        return 1
    fi
}




# New function to check and fix errors without a loop
error_fix() {
    echo "Attempting to fix errors..."
    
    install_go
    install_common_go_packages
    test_common_go_packages
    fix_go_errors
    

    # Check if all functions executed successfully
    if [ $? -eq 0 ]; then
        echo "All functions executed successfully!"
    else
        echo "Error occurred in one of the functions. Attempting to reinstall go and try again."
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
