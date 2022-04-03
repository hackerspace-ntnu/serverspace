#!/bin/bash

dingseboms="dingseboms@129.241.106.24"
duppeditt="duppeditt@129.241.106.25"
backup="/hackerspace-backups/$HOSTNAME-backup"

# scp file.txt remote_username@10.10.0.2:/remote/directory


# Incremental backup
inczip="$backup/inc-backup$(date +"%d-%m-%y").zip"
scp $inczip dingseboms@129.241.106.24:$backup





# Full backup
fullzip="$backup/full-backup$(date +"%d-%m-%y").zip"
# scp dingseboms@129.241.106.24:$fullzip





