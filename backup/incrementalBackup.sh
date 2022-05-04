#!/bin/bash

declare -a locations  # backup paths
locations=(
    "/home/hackerspace/media" 
    "/home/hackerspace/website/website/local_settings.py" 
    "/etc/nginx/sites-available" 
    "/etc/systemd/system/gunicorn.service" 
    "/etc/systemd/system/gunicorn.socket" 
)

current_date=$(date +"%Y-%m-%d")     # current date

echo " $current_date ------------------------------------------------------------"

function incrementalBackup () {
    name="$current_date-inc-backup"
    dest="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup/$name"

    if [ ! -d "$dest" ]; then
        mkdir -p $dest
    fi

    for (( i=0; i<${#locations[@]}; i++ )); do
        base=$(basename ${locations[$i]})
        if [[ -d ${locations[$i]} ]]; then
            find ${locations[$i]}/* -mmin -1440 -exec cp -rp --parents "{}"  $dest \;
        elif [[ -f ${locations[$i]} ]]; then
            find ${locations[$i]} -maxdepth 0 -type f -mmin -1440 -exec cp -rp --parents "{}" $dest \;
        else
            echo "${locations[$i]} is not valid"
            exit 1
        fi
    done

    pg_dump -U $PGUSER $PGDATABASE > "$dest/database-production-backup.sql"
}

function fullBackup () {
    name="$current_date-full-backup"
    dest="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup/$name"

    if [ ! -d "$dest" ]; then
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
fullzip="$localBackup/$current_date-full-backup.zip"
inczip="$localBackup/$current_date-inc-backup.zip"

today="$(date +%A)"
backupday="Sunday"
if [ "$today" == "$backupday" ]; then
    fullBackup

    full="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup/$current_date-full-backup"

    # Zipper backup og sletter den gamle
    if [ $(find $full -maxdepth 0 -type d) ]; then
        cd $(dirname $full); zip -r $(basename $full) ./$(basename $full)
        rm -rf $full
    fi

    # SCP til andre serveren i miljøet. Sjekker først hvem som er hvem
    if [ "$HOSTNAME" == "dingseboms" ]; then
        scp $fullzip $duppedittHack:$localBackup
    elif [ "$HOSTNAME" == "duppeditt" ]; then
        scp $fullzip $dingsebomsHack:$localBackup
    fi

    # Laster opp backupen til Google Drive
    cd /home/hackerspace/serverspace/backup/website-gdrive-backup
    python3 backup_to_drive.py $fullzip
else 
    incrementalBackup

    inc="/home/hackerspace/hackerspace-backups/$HOSTNAME-backup/$current_date-inc-backup"

    # Zipper backup og sletter den gamle
    if [ $(find $inc -maxdepth 0 -type d) ]; then
        cd $(dirname $inc); zip -r $(basename $inc) ./$(basename $inc)
        rm -rf $inc
    fi

    # SCP til andre serveren i miljøet. Sjekker først hvem som er hvem
    if [ "$HOSTNAME" == "dingseboms" ]; then
        scp $inczip $duppedittHack:$localBackup
    elif [ "$HOSTNAME" == "duppeditt" ]; then
        scp $inczip $dingsebomsHack:$localBackup
    fi

    # Laster opp backupen til Google Drive
    cd /home/hackerspace/serverspace/backup/website-gdrive-backup
    python3 backup_to_drive.py $inczip
fi

echo ""
echo ""


