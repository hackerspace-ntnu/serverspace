#!/bin/bash

# Full destination
full="/home/alexamol/$HOSTNAME-backup/full-backup$(date +"%d-%m-%y")"
fullzip="/home/alexamol/$HOSTNAME-backup/full-backup$(date +"%d-%m-%y").zip"

# Incremental destination
inc="/home/alexamol/$HOSTNAME-backup/inc-backup$(date +"%d-%m-%y")"
inczip="/home/alexamol/$HOSTNAME-backup/inc-backup$(date +"%d-%m-%y").zip"

# Installerer zip og unzip pakken
# sudo apt install zip unzip -y

# zip [options] zipfile files_list
if [ $(find $full -maxdepth 0 -type d) ]; then
    cd $(dirname $full); zip -r $(basename $full) .
    rm -rf $full
fi

if [ $(find $inc -maxdepth 0 -type d) ]; then
    cd $(dirname $inc); zip -r $(basename $inc) .
    rm -rf $inc
fi
