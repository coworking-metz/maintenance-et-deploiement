#!/bin/bash

# Parse arguments
for i in "$@"
do
case $i in
    --folder=*)
    FOLDER="${i#*=}"
    shift
    ;;
    *)
    # unknown option
    ;;
esac
done

# Function to check for new commits and update the repo
update_repo() {
    echo "Checking for updates in the repository at $FOLDER"
    cd "$FOLDER"
    
    # Check if the directory is a git repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Fetch changes and check for new commits
        git fetch
        LOCAL=$(git rev-parse @)
        REMOTE=$(git rev-parse @{u})

        if [ $LOCAL != $REMOTE ]; then
            echo "New updates found. Updating to the latest version..."
            git pull
        else
            echo "No new updates found."
        fi
    else
        echo "The specified folder does not appear to be a git repository."
        return 1
    fi
}

# Function to run deploy.sh if exists
run_deploy_script() {
    if [ -f "$FOLDER/deploy.sh" ]; then
        echo "Running deploy.sh script..."
        chmod +x "$FOLDER/deploy.sh"
        "$FOLDER/deploy.sh"
    else
        echo "No deploy.sh script found."
    fi
}

# Function to run build command from package.json if exists
run_build_command() {
    if [ -f "$FOLDER/package.json" ]; then
        BUILD_CMD=$(cat "$FOLDER/package.json" | grep '"build":' | awk -F '"' '{print $4}')
        if [ -n "$BUILD_CMD" ]; then
            echo "Running build command: $BUILD_CMD"
            npm run build
        else
            echo "No build command found in package.json."
        fi
    else
        echo "No package.json found."
    fi
}

# Main script execution
update_repo
run_deploy_script
run_build_command
