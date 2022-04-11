#!/bin/bash

declare -a locations  # backup paths
locations=("/home/dingseboms")
basename -a ${locations[*]}

function incrementalBackup () {
    name="inc-backup$(date +"%d-%m-%y")"
    dest="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup/$name"
    
    if [ -d "$dest" ]; then
        echo "$dest exists."
    else 
        mkdir -p $dest
    fi

    for (( i=0; i<${#locations[@]}; i++ )); do    # ${#locations[@]} = locations.length
        base=$(basename ${locations[$i]})
        backupdest="$dest/$base"
        mkdir -p $backupdest
        find ${locations[$i]}/* -mmin -60 -exec cp -rf "{}"  $backupdest \;
        # find ${locations[$i]}/. -mmin -$(( 60*24 )) -exec cp -rf "{}"  $backupdest \;
    done
}

function fullBackup () {
    name="full-backup$(date +"%d-%m-%y")"
    dest="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup/$name"
    
    if [ -d "$dest" ]; then
        echo "$dest exists."
    else 
        mkdir -p $dest
    fi

    for (( i=0; i<${#locations[@]}; i++ )); do    # ${#locations[@]} = locations.length
        base=$(basename ${locations[$i]})
        backupdest="$dest/$base"
        mkdir -p $backupdest
        find ${locations[$i]}/. -exec cp -rf "{}"  $backupdest \;
    done
}

today="$(date +%A)"
backupday="Sunday"
if [ "$today" == "$backupday" ]; then
    fullBackup

    full="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup/full-backup$(date +"%d-%m-%y")"
    fullzip="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup/full-backup$(date +"%d-%m-%y").zip"

    if [ $(find $full -maxdepth 0 -type d) ]; then
        cd $(dirname $full); zip -r $(basename $full) .
        rm -rf $full
    fi

else 
    incrementalBackup

    inc="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup/inc-backup$(date +"%d-%m-%y")"
    inczip="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup/inc-backup$(date +"%d-%m-%y").zip"

    if [ $(find $inc -maxdepth 0 -type d) ]; then
        cd $(dirname $inc); zip -r $(basename $inc) .
        rm -rf $inc
    fi

fi


