#!/bin/bash

NOW=$(date +%Y-%m-%dT%H:%M:%S)

# Make a temporary directory to stage the backup in before compression
mkdir /tmp/backup
mkdir /tmp/backup/media
mkdir /tmp/backup/config

# Dump database
pg_dump -U $PGUSER $PGDATABASE > /tmp/backup/data.sql

# Copy user uploads (media files)
cp -r /home/hackerspace/media/* /tmp/backup/media

# Copy configuration files (Django, nginx, systemd)
cp /home/hackerspace/website/website/local_settings.py /tmp/backup/config/local_settings.py
cp -r /etc/nginx/sites-available /tmp/backup/nginx
mkdir /tmp/backup/config/systemd
cp /etc/systemd/system/gunicorn.service /tmp/backup/config/systemd/gunicorn.service
cp /etc/systemd/system/gunicorn.socket /tmp/backup/config/systemd/gunicorn.socket

# create (c) a new tarball, be verbose (v), handle sparse files efficiently (S), run it through bzip2 (j), put it in $NOW.zip (f)
# decompress with tar -xvjf
tar -cvSjf $BACKUPDIR/daily/$NOW.tar.bz2 /tmp/backup/*

# Cleanup the staging directory
rm -rf /tmp/backup/temp
