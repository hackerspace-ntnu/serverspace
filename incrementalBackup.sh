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
            base=$(basename ${locations[$i]})
            backupdest="$dest/$base"
            mkdir -p $backupdest
            find ${locations[$i]}/* -mmin -60 -exec cp -rp "{}"  $backupdest \;
        elif [[ -f ${locations[$i]} ]]; then
            find ${locations[$i]} -maxdepth 0 -type f -mmin -60 -exec cp -rp --parents "{}" $dest \;
        else
            echo "${locations[$i]} is not valid"
            exit 1
        fi
    done

    PGUSER=production
    PGDATABASE=production
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
            base=$(basename ${locations[$i]})
            backupdest="$dest/$base"
            mkdir -p $backupdest
            find ${locations[$i]}/* -exec cp -rp "{}"  $backupdest \;
        elif [[ -f ${locations[$i]} ]]; then
            find ${locations[$i]} -maxdepth 0 -type f -exec cp -rp --parents "{}" $dest \;
        else
            echo "${locations[$i]} is not valid"
            exit 1
        fi
    done

    PGUSER=production
    PGDATABASE=production
    pg_dump -U $PGUSER $PGDATABASE > "$dest/database-production-backup.sql"
}


today="$(date +%A)"
# backupday="Sunday"
backupday="Tuesday"
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




