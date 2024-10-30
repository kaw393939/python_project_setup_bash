#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display info messages
function echo_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to display success messages
function echo_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to display error messages
function echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
function command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to prompt user for license
function select_license() {
    echo "Select a license:"
    echo "1) MIT"
    echo "2) Apache 2.0"
    echo "3) GNU GPLv3"
    echo "4) None"
    read -p "Enter choice [1-4]: " license_choice

    case $license_choice in
        1)
            LICENSE="MIT"
            ;;
        2)
            LICENSE="Apache-2.0"
            ;;
        3)
            LICENSE="GPL-3.0"
            ;;
        4)
            LICENSE="None"
            ;;
        *)
            echo_error "Invalid choice. Defaulting to MIT."
            LICENSE="MIT"
            ;;
    esac
}

# Function to generate LICENSE file
function create_license() {
    if [ "$LICENSE" != "None" ]; then
        echo_info "Adding $LICENSE license"
        case $LICENSE in
            "MIT")
                cat > LICENSE <<EOL
MIT License

Copyright (c) $(date +%Y) [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy...
[Full MIT License Text]
EOL
                ;;
            "Apache-2.0")
                cat > LICENSE <<EOL
Apache License 2.0

Copyright (c) $(date +%Y) [Your Name]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
...
[Full Apache 2.0 License Text]
EOL
                ;;
            "GPL-3.0")
                cat > LICENSE <<EOL
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

...
[Full GPLv3 License Text]
EOL
                ;;
        esac
        echo_success "$LICENSE license added."
    fi
}

# Check for required commands
REQUIRED_COMMANDS=("git" "python3" "pip3")
for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command_exists "$cmd"; then
        echo_error "Required command '$cmd' is not installed. Please install it and try again."
        exit 1
    fi
done

# Check if GitHub CLI is installed for remote repository setup
GITHUB_CLI_INSTALLED=false
if command_exists "gh"; then
    GITHUB_CLI_INSTALLED=true
fi

# Parse arguments
if [ -z "$1" ]; then
    echo_error "No project name provided."
    echo "Usage: ./setup_project.sh <project_name>"
    exit 1
fi

PROJECT_NAME=$1

# Prompt for additional options (optional)
# For simplicity, we proceed without additional options

# Check if directory exists
if [ -d "$PROJECT_NAME" ]; then
    echo_error "Directory '$PROJECT_NAME' already exists."
    exit 1
fi

# Create project directory
echo_info "Creating project directory: $PROJECT_NAME"
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Initialize Git repository
echo_info "Initializing Git repository"
git init -b main

# Create .gitignore
echo_info "Creating .gitignore file"
cat > .gitignore << EOL
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# Virtual environment
venv/
ENV/
env/
.venv/

# Test reports
htmlcov/
coverage.xml
*.cover
*.py,cover

# IDEs and editors
.vscode/
.idea/
*.sublime-project
*.sublime-workspace

# Logs
*.log

# Other
.DS_Store
EOL

# Create Python virtual environment
echo_info "Creating Python virtual environment"
python3 -m venv venv

# Activate virtual environment
echo_info "Activating virtual environment"
source venv/bin/activate

# Upgrade pip
echo_info "Upgrading pip"
pip install --upgrade pip

# Install dependencies
echo_info "Installing pytest, pytest-cov, pylint, black"
pip install pytest pytest-cov pylint black

# Freeze dependencies to requirements.txt
echo_info "Creating requirements.txt"
pip freeze > requirements.txt

# Create requirements-dev.txt
echo_info "Creating requirements-dev.txt"
pip freeze > requirements-dev.txt

# Deactivate virtual environment
deactivate

# Create basic project structure
echo_info "Creating basic project structure"
mkdir src tests
touch src/__init__.py
touch tests/__init__.py
touch tests/test_sample.py

# Add sample test
echo_info "Adding a sample test in tests/test_sample.py"
cat > tests/test_sample.py << EOL
def test_sample():
    assert 1 + 1 == 2
EOL

# Create configuration files

# Pytest configuration
echo_info "Creating pytest configuration (pytest.ini)"
cat > pytest.ini << EOL
[pytest]
minversion = 6.0
addopts = -ra -q --cov=src
testpaths = tests
EOL

# Pylint configuration
echo_info "Creating pylint configuration (.pylintrc)"
pip install pylint
pylint --generate-rcfile > .pylintrc

# Coverage configuration
echo_info "Creating coverage configuration (.coveragerc)"
cat > .coveragerc << EOL
[run]
source = src
branch = True
EOL

# Create Makefile for common tasks
echo_info "Creating Makefile for common tasks"
cat > Makefile << EOL
.PHONY: venv install test lint format

venv:
	python3 -m venv venv

install:
	pip install --upgrade pip
	pip install -r requirements.txt
	pip install -r requirements-dev.txt

test:
	pytest

lint:
	pylint src/

format:
	black src/ tests/
EOL

# Create README.md with enhanced setup instructions
echo_info "Creating README.md with setup instructions"
cat > README.md << EOL
# $PROJECT_NAME

![Build Status](https://img.shields.io/github/actions/workflow/status/yourusername/$PROJECT_NAME/main.yml?branch=main)
![Coverage](https://img.shields.io/coverage/github/yourusername/$PROJECT_NAME)
![License](https://img.shields.io/github/license/yourusername/$PROJECT_NAME)

## Overview

$PROJECT_NAME is a Python project configured with Git, a virtual environment, and testing tools including Pytest, Pytest-Cov, Pylint, and Black. It ensures code quality and consistency through automated linting and formatting.

## Setup Instructions

### Prerequisites

- **Python 3.6+**: Ensure you have Python installed. You can download it from [Python's official website](https://www.python.org/downloads/).
- **Git**: Install Git from [Git's official website](https://git-scm.com/downloads).
- **GitHub CLI (optional)**: For initializing remote repositories, install GitHub CLI from [GitHub CLI](https://cli.github.com/).

### Installation

1. **Clone the Repository**

   \`\`\`bash
   git clone https://github.com/yourusername/$PROJECT_NAME.git
   cd $PROJECT_NAME
   \`\`\`

2. **Create a Virtual Environment**

   It's recommended to use a virtual environment to manage dependencies.

   \`\`\`bash
   python3 -m venv venv
   \`\`\`

3. **Activate the Virtual Environment**

   - **On macOS and Linux:**

     \`\`\`bash
     source venv/bin/activate
     \`\`\`

   - **On Windows:**

     \`\`\`bash
     venv\Scripts\activate
     \`\`\`

4. **Upgrade pip**

   \`\`\`bash
   pip install --upgrade pip
   \`\`\`

5. **Install Dependencies**

   \`\`\`bash
   pip install -r requirements.txt
   pip install -r requirements-dev.txt
   \`\`\`

### Running Tests

This project uses **Pytest** for testing, along with **Pytest-Cov** for coverage reports and **Pylint** for linting.

- **Run All Tests:**

  \`\`\`bash
  pytest
  \`\`\`

- **Run Tests with Coverage:**

  \`\`\`bash
  pytest --cov=src
  \`\`\`

- **Run Pylint:**

  \`\`\`bash
  pylint src/
  \`\`\`

### Code Formatting

The project uses **Black** for code formatting. You can format your code by running:

\`\`\`bash
make format
\`\`\`

### Linting

To lint your code using Pylint, run:

\`\`\`bash
make lint
\`\`\`

### Deactivating the Virtual Environment

After you're done working, you can deactivate the virtual environment:

\`\`\`bash
deactivate
\`\`\`

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the [${LICENSE} License](LICENSE).

## Contact

For any inquiries or suggestions, please contact [Your Name](mailto:your.email@example.com).
EOL

# Optionally Add GitHub Repository and CI Workflow

if [ "$GITHUB_CLI_INSTALLED" = true ]; then
    read -p "Would you like to create a GitHub repository and set it as remote? (y/n): " create_remote
    if [[ "$create_remote" =~ ^[Yy]$ ]]; then
        read -p "Enter GitHub username: " github_user
        read -p "Enter repository description: " repo_desc
        read -p "Is the repository private? (y/n): " is_private

        if [[ "$is_private" =~ ^[Yy]$ ]]; then
            PRIVATE=true
        else
            PRIVATE=false
        fi

        echo_info "Creating GitHub repository"
        if [ "$PRIVATE" = true ]; then
            gh repo create "$PROJECT_NAME" --private --source=. --description "$repo_desc" --remote=origin
        else
            gh repo create "$PROJECT_NAME" --public --source=. --description "$repo_desc" --remote=origin
        fi
        git branch -M main
        git push -u origin main

        # Create GitHub Actions workflow for CI
        echo_info "Setting up GitHub Actions workflow"
        mkdir -p .github/workflows
        cat > .github/workflows/python-app.yml << EOL
name: Python application

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:

    runs-on: ubuntu-latest

    strategy:
      matrix:
        python-version: [3.8, 3.9, 3.10, 3.11]

    steps:
    - uses: actions/checkout@v3
    - name: Set up Python \${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: \${{ matrix.python-version }}
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install -r requirements-dev.txt
    - name: Lint with pylint
      run: |
        pylint src/
    - name: Test with pytest
      run: |
        pytest
    - name: Check code formatting
      run: |
        black --check src/ tests/
EOL
        git add .github/workflows/python-app.yml
        git commit -m "Add GitHub Actions CI workflow"
        git push
        echo_success "GitHub repository and CI workflow set up successfully."
    fi
fi

# Initial Git commit
echo_info "Making initial Git commit"
git add .
git commit -m "Initial project setup with virtual environment and testing tools"

# Optionally push to remote repository
if [ "$GITHUB_CLI_INSTALLED" = true ] && [[ "$create_remote" =~ ^[Yy]$ ]]; then
    git push -u origin main
fi

# Completion Message
echo_success "Project '$PROJECT_NAME' has been successfully set up!"
echo "To get started:"
echo "1. Navigate to the project directory: cd $PROJECT_NAME"
echo "2. Activate the virtual environment: source venv/bin/activate"
echo "3. Install dependencies: pip install -r requirements.txt && pip install -r requirements-dev.txt"
echo "4. Start coding!"
