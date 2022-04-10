#!/bin/bash

dingseboms="dingseboms@129.241.106.24"
duppeditt="duppeditt@129.241.106.25"

dest=$HOSTNAME-backup
backup="/hackerspace-backups/$dest"


# currentuser=$USER   # Scriptet kjøres i sudo så må lagre brukeren som backupes


# scp file.txt remote_username@10.10.0.2:/remote/directory


# Incremental backup
inczip="$backup/inc-backup$(date +"%d-%m-%y").zip"
scp $inczip $duppeditt:$backup

scp $inczip $duppeditt:$backup -i ~/.ssh/gh-actions-update-keys



# Full backup
fullzip="$backup/full-backup$(date +"%d-%m-%y").zip"
scp $fullzip $duppeditt:$backup

scp $fullzip $duppeditt:$backup -i ~/.ssh/gh-actions-update-keys



# Local-Dingseboms

dingsebomsbackup="hackerspace@129.241.106.24"

fullzip="$backup/full-backup$(date +"%d-%m-%y").zip"
scp $fullzip $dingseboms:/home/dingseboms/dingseboms-backup



# scp $fullzip $duppeditt:$backup -i ~/.ssh/gh-actions-update-keys




