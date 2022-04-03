#!/bin/bash


# Må sette opp cronjob. Alternativ til task scheduler

# Directory path
declare -a loc
loc=("/home/dingseboms/foo" "/home/dingseboms/goo")
basename -a ${loc[*]}


function incrementalBackup () {
    name="inc-backup$(date +"%d-%m-%y")"
    dest="/hackerspace-backups/$HOSTNAME-backup/$name"
    
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
    dest="/hackerspace-backups/$HOSTNAME-backup/$name"
    
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

    # echo "$today is $backupday"
    # echo "Full backup"
    fullBackup

    full="/hackerspace-backups/$HOSTNAME-backup/full-backup$(date +"%d-%m-%y")"
    fullzip="/hackerspace-backups/$HOSTNAME-backup/full-backup$(date +"%d-%m-%y").zip"

    if [ $(find $full -maxdepth 0 -type d) ]; then
        cd $(dirname $full); zip -r $(basename $full) .
        rm -rf $full
    fi

else 
    # echo "$today is not $backupday"
    # echo "Incremental backup"
    incrementalBackup

    inc="/hackerspace-backups/$HOSTNAME-backup/inc-backup$(date +"%d-%m-%y")"
    inczip="/hackerspace-backups/$HOSTNAME-backup/inc-backup$(date +"%d-%m-%y").zip"

    if [ $(find $inc -maxdepth 0 -type d) ]; then
        cd $(dirname $inc); zip -r $(basename $inc) .
        rm -rf $inc
    fi

fi


