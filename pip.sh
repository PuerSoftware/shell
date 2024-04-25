#!/bin/bash

source 'poetry.sh'

# Function to create basic Python package structure
create_package_structure() {
    # Get the name of the current directory to use as the package name
    PACKAGE_NAME=$(basename "$PWD")
    SHELL_PATH="$HOME/shell"

    echo "Creating package structure for $PACKAGE_NAME..."

    mkdir -p "./$PACKAGE_NAME"
    touch "./$PACKAGE_NAME/__init__.py"
    cp "$SHELL_PATH/pip/setup.py" "."
    cp "$SHELL_PATH/pip/version.py" "."
    sed -i "s/__NAME__/$PACKAGE_NAME/" ./setup.py
    echo "Package structure and scripts created successfully."
}

# Function to create pip package with optional package name
pip_package() {
    # Determine the package name: use the first argument or default to the current directory name
    local package_name="${1:-$(basename "$(pwd)")}"

    # Check if setup.py exists
    if [ -f "./setup.py" ]; then
        echo "setup.py found for package '$package_name'."
    else
        echo "setup.py not found for package '$package_name'."
        create_package_structure "$package_name"
    fi

    # Ensure wheel is installed for building the wheel distribution
    echo "Checking for the wheel package..."
    python3 -m pip show wheel > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Wheel package not installed. Installing now..."
        python3 -m pip install wheel
    else
        echo "Wheel package is already installed."
    fi

    # Init poetry environment
    if [ -f "./pyproject.toml" ]; then
        echo "pyproject.toml found"
    else
        poetry init --no-interaction
        poetry env use python3
        poetry add pytest toml
    fi

    # Build the package
    echo "Building the package for '$package_name'..."
    python3 setup.py sdist bdist_wheel

    echo "Package creation for '$package_name' complete."
}

# Function to deploy pip package
pip_deploy() {
    rm -rf build/ dist/ *.egg-info
    python version.py $1
    python3 setup.py sdist bdist_wheel
    twine upload --verbose dist/*
}

# Helper function to check if commands exist
command_exists() {
    type "$1" &> /dev/null
}
