#!/bin/bash

declare -a locations  # backup paths
locations=(
    "/home/hackerspace/media" 
    "/home/hackerspace/website/website/local_settings.py" 
    "/etc/nginx/sites-available" 
    "/etc/systemd/system/gunicorn.service" 
    "/etc/systemd/system/gunicorn.socket" 
)

function incrementalBackup () {
    name="inc-backup$(date +"%d-%m-%y")"
    dest="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup/$name"
    
    if [ -d "$dest" ]; then
        echo "$dest exists."
    else 
        mkdir -p $dest
    fi

    for (( i=0; i<${#locations[@]}; i++ )); do
        base=$(basename ${locations[$i]})
        if [[ -d ${locations[$i]} ]]; then
            find ${locations[$i]}/* -mmin -60 -exec cp -rp --parents "{}"  $dest \;
        elif [[ -f ${locations[$i]} ]]; then
            find ${locations[$i]} -maxdepth 0 -type f -mmin -60 -exec cp -rp --parents "{}" $dest \;
        else
            echo "${locations[$i]} is not valid"
            exit 1
        fi
    done

    pg_dump -U $PGUSER $PGDATABASE > "$dest/database-production-backup.sql"
}

function fullBackup () {
    name="full-backup$(date +"%d-%m-%y")"
    dest="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup/$name"

    if [ -d "$dest" ]; then
        echo "$dest exists."
    else 
        mkdir -p $dest
    fi

    for (( i=0; i<${#locations[@]}; i++ )); do
        base=$(basename ${locations[$i]})
        if [[ -d ${locations[$i]} ]]; then
            find ${locations[$i]}/* -exec cp -rp --parents "{}"  $dest \;
        elif [[ -f ${locations[$i]} ]]; then
            find ${locations[$i]} -maxdepth 0 -type f -exec cp -rp --parents "{}" $dest \;
        else
            echo "${locations[$i]} is not valid"
            exit 1
        fi
    done

    pg_dump -U $PGUSER $PGDATABASE > "$dest/database-production-backup.sql"
}

# Database variabler
PGUSER="production"
PGDATABASE="production"

# Variabler for SCP
dingsebomsHack="hackerspace@129.241.106.24"
duppedittHack="hackerspace@129.241.106.25"
localBackup="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup"
fullzip="$localBackup/full-backup$(date +"%d-%m-%y").zip"
inczip="$localBackup/inc-backup$(date +"%d-%m-%y").zip"

today="$(date +%A)"
backupday="Sunday"
if [ "$today" == "$backupday" ]; then
    fullBackup

    full="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup/full-backup$(date +"%d-%m-%y")"
    fullzip="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup/full-backup$(date +"%d-%m-%y").zip"

    # Zipper backup og sletter den gamle
    if [ $(find $full -maxdepth 0 -type d) ]; then
        cd $(dirname $full); zip -r $(basename $full) .
        rm -rf $full
    fi

    # SCP til andre serveren i miljøet. Sjekker først hvem som er hvem
    if [ "$HOSTNAME" == "dingseboms" ]; then
        scp $fullzip $duppedittHack:$localBackup
    elif [ "$HOSTNAME" == "duppeditt" ]; then
        scp $fullzip $dingsebomsHack:$localBackup
    fi

else 
    incrementalBackup

    inc="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup/inc-backup$(date +"%d-%m-%y")"
    inczip="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup/inc-backup$(date +"%d-%m-%y").zip"

    # Zipper backup og sletter den gamle
    if [ $(find $inc -maxdepth 0 -type d) ]; then
        cd $(dirname $inc); zip -r $(basename $inc) .
        rm -rf $inc
    fi

    # SCP til andre serveren i miljøet. Sjekker først hvem som er hvem
    if [ "$HOSTNAME" == "dingseboms" ]; then
        scp $inczip $duppedittHack:$localBackup
    elif [ "$HOSTNAME" == "duppeditt" ]; then
        scp $inczip $dingsebomsHack:$localBackup
    fi
fi




