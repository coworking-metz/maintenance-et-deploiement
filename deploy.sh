#!/bin/bash

# Initialize variable to track if force flag is set
FORCE_UPDATE=0

# Parse arguments
for i in "$@"
do
case $i in
    --folder=*)
    FOLDER="${i#*=}"
    shift # past argument=value
    ;;
    --site=*)
    SITE="${i#*=}"
    shift # past argument=value
    ;;
    --force)
    FORCE_UPDATE=1
    shift # past argument with no value
    ;;
    *)
    # unknown option
    ;;
esac
done

if [ -z "$FOLDER" ]; then
    if [ -z "$SITE" ]; then
    echo "Sitename missing."
    exit 1
    fi
  FOLDER="/home/coworking/$SITE"
fi

if [ ! -d "$FOLDER" ]; then
    echo "Folder $FOLDER does not exist."
    exit 1
fi

if [ ! -d "$FOLDER/.git" ]; then
    echo "Folder $FOLDER is not a GIT repo."
    exit 1
fi

echo "Deploying $FOLDER"

# Initialize a variable to track if an update occurred
UPDATED=0

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
            UPDATED=1 # Success, new code was pulled
        else
            echo "No new updates found."
        fi
    else
        echo "The specified folder does not appear to be a git repository."
    fi
}

# Function to run deploy.sh if exists
run_deploy_script() {
    if [ -f "$FOLDER/deploy.sh" ]; then
        echo "Running deploy.sh script..."
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
            npm --prefix "$FOLDER" ci
            npm --prefix "$FOLDER" run build
        else
            echo "No build command found in package.json."
        fi
    else
        echo "No package.json found."
    fi
}

purge_cloudflare() {
    wget --spider -q https://webhooks.coworking-metz.fr/cloudflare/purge
}

# Main script execution
update_repo
if [ $UPDATED -eq 1 ] || [ $FORCE_UPDATE -eq 1 ]; then
    run_deploy_script
    run_build_command
    purge_cloudflare
fi
