#!/bin/bash

# Function to create basic Python package structure
create_package_structure() {
    # Get the name of the current directory to use as the package name
    PACKAGE_NAME=$(basename "$PWD")

    echo "Creating package structure for $PACKAGE_NAME..."

    mkdir -p "./$PACKAGE_NAME"
    touch "./$PACKAGE_NAME/__init__.py"
    echo "from .module import *" > "./$PACKAGE_NAME/__init__.py"

    cat > "./setup.py" <<EOM
from setuptools import setup, find_packages

setup(
    name='$PACKAGE_NAME',
    version='0.1.0',
    packages=find_packages(),
    install_requires=[],
)
EOM

    # Create increment_version.py script
    cat > "./increment_version.py" <<EOM
import re
from pathlib import Path

def increment_version():
    setup_path = Path('setup.py')
    content = setup_path.read_text()
    version_match = re.search(r"version\s*=\s*['\"](\d+\.\d+\.\d+)['\"]", content)
    if version_match:
        current_version = version_match.group(1)
        major, minor, patch = map(int, current_version.split('.'))
        new_version = f"{major}.{minor}.{patch + 1}"
        new_content = re.sub(r"version\s*=\s*['\"]\d+\.\d+\.\d+['\"]", f"version='{new_version}'", content)
        setup_path.write_text(new_content)
        print(f"Version updated to: {new_version}")
    else:
        raise ValueError("Version string not found in setup.py")

if __name__ == "__main__":
    increment_version()
EOM

    echo "Package structure and scripts created successfully."
}


# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
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

    # Build the package
    echo "Building the package for '$package_name'..."
    python3 setup.py sdist bdist_wheel

    echo "Package creation for '$package_name' complete."
}

# Function to deploy pip package
pip_deploy() {
    # Check for necessary tools: Python, twine
    if ! command_exists python3 || ! command_exists twine ; then
        echo "Please ensure Python and Twine are installed."
        return 1
    fi

    # Increment version automatically using a robust Python script
    echo "Incrementing patch version in setup.py using a robust Python approach..."
    if ! python3 -c 'import re
                     with open("setup.py", "r") as file:
                         content = file.read()
                     new_content = re.sub(r"(version=['\"])(\d+\.\d+\.)(\d+)(['\"])", 
                                          lambda x: f"{x.group(1)}{x.group(2)}{str(int(x.group(3)) + 1)}{x.group(4)}",
                                          content)
                     if content == new_content:
                         print("No version increment needed or version not found.")
                         exit(1)
                     with open("setup.py", "w") as file:
                         file.write(new_content)' ; then
        echo "Failed to increment version."
        return 1
    fi
    echo "Version incremented successfully."

    # Ensure old build artifacts are removed
    echo "Cleaning up old build artifacts..."
    rm -rf build/ dist/ *.egg-info
    echo "Cleanup complete."

    # Build the package
    echo "Building the package..."
    if ! python3 setup.py sdist bdist_wheel; then
        echo "Failed to build the package."
        return 1
    fi
    echo "Package built successfully."

    # Upload the package to PyPI using Twine with verbose output
    echo "Uploading to PyPI..."
    if ! twine upload --verbose dist/*; then
        echo "Failed to upload the package. Check the verbose output above for details."
        return 1
    fi
    echo "Package uploaded successfully."

    echo "Deployment complete."
}

# Helper function to check if commands exist
command_exists() {
    type "$1" &> /dev/null
}
