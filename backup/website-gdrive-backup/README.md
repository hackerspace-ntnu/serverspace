# Website Backup to Google Drive

1. Retrieve OAuth Client `credentials.json` from [Google Cloud Platform](https://console.cloud.google.com/apis/credentials)

2. Obtain `token.json` with
```
python obtain_new_token.py
```

3. Create `settings.py` from `settings_dist.py` and set `BACKUP_TEAM_DRIVE_FOLDER_ID`

4. Backup file to Google Drive with
```
python backup_to_drive.py <filename>
```
