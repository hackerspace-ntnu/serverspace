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
else 
    echo "$today is not $backupday"
    echo "Incremental backup"
    incrementalBackup
fi




