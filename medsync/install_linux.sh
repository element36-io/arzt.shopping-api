#!/bin/bash
set -e


download() {
    local filename=$1

    local url="${baseUrl}${filename}?ref=${branch}"
    wget -O $filename $url | jq -r '.content' | base64 --decode 
}
# Function to remove existing cron entries for the script
remove_existing_cron_entries() {
    local script_name="$1"

    # Remove all existing cron entries with the specified script name
    crontab -l | grep -v "$script_name" | crontab -
}

# Function to add script to cron
add_to_cron() {
    local cron_schedule="$1"
    local script_name="$2"
    local script_parameters="$3"

    # Add script to cron with the specified schedule and parameters
    (crontab -l ; echo "$cron_schedule $PWD/$script_name $script_parameters") | crontab -
    echo "Script added to cron."
}

# Cron schedule for updater script
updater_schedule="0 17 * * *"
updater_parameters="updater"

# Cron schedule for regular script
regular_schedule="*/5 * * * *"
regular_parameters="medsync"

scriptname="medsync.sh"

# Remove existing cron entries for the updater script
remove_existing_cron_entries "$scriptname"

# Add updater script to cron
add_to_cron "$updater_schedule" "$scriptname" "$updater_parameters"

# Add regular script to cron
add_to_cron "$regular_schedule" "$scriptname" "$regular_parameters"

crontab -l

branch="${1:-medisync}"
baseUrl="https://api.github.com/repos/element36-io/arzt.shopping-api/contents//medsync/"

download "install_linux.sh"
chmod u+x ./install_linux.sh
download "medsync.sh"
chmod u+x ./medsync.sh
download "medsync.txt"
download "init.ps1"
download "updater.ps1"
download "updater.txt"



