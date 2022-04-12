#!/bin/bash

# Dingseboms_local -> Duppeditt_hackerspace
dingsebomsHack="hackerspace@129.241.106.24"
duppedittHack="hackerspace@129.241.106.25"

dest=$HOSTNAME-backup
localBackup="/home/$USER/hackerspace-backups/$dest"    # ~/hackerspace-backups/LAPTOP-40AKUSI6-backup

today="$(date +%A)"
# backupday="Sunday"
backupday="Tuesday"
if [ "$today" == "$backupday" ]; then
    fullzip="$localBackup/full-backup$(date +"%d-%m-%y").zip"
    scp $fullzip $duppedittHack:$localBackup
else
    inczip="$localBackup/inc-backup$(date +"%d-%m-%y").zip"
    scp $inczip $duppedittHack:$localBackup
fi


# # Duppeditt_local -> Dingseboms_hackerspace
# dingsebomsHack="hackerspace@129.241.106.24"
# duppedittHack="hackerspace@129.241.106.25"

# dest=$HOSTNAME-backup
# localBackup="/home/$USER/hackerspace-backups/$dest"    # ~/hackerspace-backups/LAPTOP-40AKUSI6-backup

# today="$(date +%A)"
# backupday="Sunday"
# if [ "$today" == "$backupday" ]; then
#     fullzip="$localBackup/full-backup$(date +"%d-%m-%y").zip"
#     scp $fullzip $dingsebomsHack:$localBackup
# else
#     inczip="$localBackup/inc-backup$(date +"%d-%m-%y").zip"
#     scp $inczip $dingsebomsHack:$localBackup
# fi



