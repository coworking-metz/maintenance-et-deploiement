#!/bin/bash

# Function to parse arguments in the form of --key=value
parse_args() {
  for arg in "$@"; do
    case $arg in
      --site_name=*)
      site_name="${arg#*=}"
      shift
      ;;
      --site_path=*)
      site_path="${arg#*=}"
      shift
      ;;
      --backup_path=*)
      backup_path="${arg#*=}"
      shift
      ;;
      --data_path=*)
      data_path="${arg#*=}"
      shift
      ;;
      --database_name=*)
      database_name="${arg#*=}"
      shift
      ;;
      *)
      # Skip unknown options
      ;;
    esac
  done
}

# Call the function to parse the command line arguments
parse_args "$@"

# Check for missing parameters and notify the user
check_required_params() {
  local missing_params=0

  if [ -z "$site_name" ]; then
    echo "Missing required parameter: --site_name"
    missing_params=1
  fi

  if [ -z "$site_path" ]; then
    echo "Missing required parameter: --site_path"
    missing_params=1
  fi

  if [ -z "$backup_path" ]; then
    echo "Missing required parameter: --backup_path"
    missing_params=1
  fi

  if [ -z "$data_path" ]; then
    echo "Missing required parameter: --data_path"
    missing_params=1
  fi

  if [ -z "$database_name" ]; then
    echo "Missing required parameter: --database_name"
    missing_params=1
  fi

  if [ "$missing_params" -ne 0 ]; then
    exit 1
  fi
}

# Verify required parameters are set
check_required_params

# Current timestamp
timestamp=$(date +%Y-%m-%d-%H-%M-%S)

# Paths for backup
mysql_backup="${backup_path}/mysql"
site_backup="${backup_path}/site"

echo "Backups for: ${site_name}"


# Ensure backup directories exist
mkdir -p $mysql_backup
mkdir -p $site_backup

# Export and zip the database
mysqldump -u backups --skip-password $database_name > "${mysql_backup}/mysql-${timestamp}.sql"
zip -j "${mysql_backup}/mysql-${timestamp}.zip" "${mysql_backup}/mysql-${timestamp}.sql"

# Remove the raw sql file to save space
rm "${mysql_backup}/mysql-${timestamp}.sql"

# Zip the site_path folder
echo "Site compression to zip"
cd $site_path
zip -q -r --symlinks "${site_backup}/site-${timestamp}.zip" .  -x "${site_path}/.git/*"

# MySQL Backup Rotation: Delete files older than 30 days
find $mysql_backup -type f -name '*.zip' -mtime +30 -exec rm {} \;

# WWW Backup Rotation: Delete files older than 15 days
find $site_backup -type f -name '*.zip' -mtime +15 -exec rm {} \;

echo "Sync to S3"
rclone sync -v --ignore-existing $backup_path  "s3-ovh:coworking-metz/${site_name}/site"
rclone sync  -v --ignore-existing $data_path  "s3-ovh:coworking-metz/${site_name}/data" 

# Notify completion
echo "Backups and rotations completed: ${timestamp}"
