#!/bin/bash

# Current timestamp
timestamp=$(date +%Y-%m-%d-%H-%M-%S)

# Paths for backup
site_path="/home/coworking/www"
backup_path="/home/coworking/backups"
mysql_backup="${backup_path}/mysql"
site_backup="${backup_path}/site"

# Ensure backup directories exist
mkdir -p $mysql_backup
mkdir -p $site_backup

# Export and zip the database
mysqldump -u backups --skip-password coworking > "${mysql_backup}/mysql-${timestamp}.sql"
zip -j "${mysql_backup}/mysql-${timestamp}.zip" "${mysql_backup}/mysql-${timestamp}.sql"

# Remove the raw sql file to save space
rm "${mysql_backup}/mysql-${timestamp}.sql"

# Zip the /home/coworking/www folder
echo "Site compression to zip"
cd $site_path
zip -q -r --symlinks "${site_backup}/site-${timestamp}.zip" .  -x "${site_path}/.git/*"

# MySQL Backup Rotation: Delete files older than 30 days
find $mysql_backup -type f -name '*.zip' -mtime +30 -exec rm {} \;

# WWW Backup Rotation: Delete files older than 15 days
find $site_backup -type f -name '*.zip' -mtime +15 -exec rm {} \;


echo "Sync to S3"
rclone sync -v --ignore-existing /home/coworking/backups  s3-ovh:coworking-metz/wordpress
rclone sync -v --ignore-existing /home/coworking/data  s3-ovh:coworking-metz/wordpress/data

# Notify completion
echo "Backups and rotations completed: ${timestamp}"
