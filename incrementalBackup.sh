#!/bin/bash


# Må sette opp cronjob. Alternativ til task scheduler

# Directory path
declare -a loc
loc=("/home/alexamol/foo/goo" "/home/alexamol/foo/hoo")
basename -a ${loc[*]}


function incrementalBackup () {
    name="inc-backup$(date +"%d-%m-%y")"
    dest="/home/alexamol/$HOSTNAME-backup/$name"
    
    if [ -d "$dest" ]; then
        echo "$dest exists."
    else 
        mkdir -p $dest
    fi

    for (( i=0; i<${#loc[@]}; i++ )); do    # ${#loc[@]} = loc.length
        base=$(basename ${loc[$i]})
        backupdest="$dest/$base"
        mkdir -p $backupdest
        find ${loc[$i]}/* -mmin -60 -exec cp -rf "{}"  $backupdest \;
        # find ${loc[$i]}/. -mmin -$(( 60*24 )) -exec cp -rf "{}"  $backupdest \;
    done
}

function fullBackup () {
    name="full-backup$(date +"%d-%m-%y")"
    dest="/home/alexamol/$HOSTNAME-backup/$name"
    
    if [ -d "$dest" ]; then
        echo "$dest exists."
    else 
        mkdir -p $dest
    fi

    for (( i=0; i<${#loc[@]}; i++ )); do    # ${#loc[@]} = loc.length
        base=$(basename ${loc[$i]})
        backupdest="$dest/$base"
        mkdir -p $backupdest
        find ${loc[$i]}/. -exec cp -rf "{}"  $backupdest \;
    done
}

today="$(date +%A)"
backupday="Sunday"
if [ "$today" == "$backupday" ]; then

    echo "$today is $backupday"
    echo "Full backup"
    fullBackup

    full="/home/alexamol/$HOSTNAME-backup/full-backup$(date +"%d-%m-%y")"
    fullzip="/home/alexamol/$HOSTNAME-backup/full-backup$(date +"%d-%m-%y").zip"

    if [ $(find $full -maxdepth 0 -type d) ]; then
        cd $(dirname $full); zip -r $(basename $full) .
        rm -rf $full
    fi

else 
    echo "$today is not $backupday"
    echo "Incremental backup"
    incrementalBackup

    inc="/home/alexamol/$HOSTNAME-backup/inc-backup$(date +"%d-%m-%y")"
    inczip="/home/alexamol/$HOSTNAME-backup/inc-backup$(date +"%d-%m-%y").zip"

    if [ $(find $inc -maxdepth 0 -type d) ]; then
        cd $(dirname $inc); zip -r $(basename $inc) .
        rm -rf $inc
    fi

fi


