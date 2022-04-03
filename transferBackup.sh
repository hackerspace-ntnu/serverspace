#!/bin/bash

dingseboms="dingseboms@129.241.106.24"
duppeditt="duppeditt@129.241.106.25"

dest=$HOSTNAME-backup
backup="/hackerspace-backups/$dest"

# scp file.txt remote_username@10.10.0.2:/remote/directory


# Incremental backup
inczip="$backup/inc-backup$(date +"%d-%m-%y").zip"
scp $inczip $duppeditt:$backup





# Full backup
fullzip="$backup/full-backup$(date +"%d-%m-%y").zip"
scp $fullzip $duppeditt:$backup





