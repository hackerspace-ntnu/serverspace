from datetime import datetime
import os.path
from sys import argv, exit
import mimetypes

from apiclient.http import MediaFileUpload
from googleapiclient.discovery import build
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials

from settings import *


if len(argv) != 2:
    print("Usage: python3.9 backup_to_drive.py <filename>")
    exit(1)

file_type_dot = argv[1].rfind(".")
original_name = argv[1]
#filetype = argv[1][file_type_dot + 1:]

backup_name = f'backup_{datetime.now().strftime("%Y-%m-%d_%Hh_%Mm")}.{original_name}'
mimetype, _encoding = mimetypes.guess_type(backup_name)

# Code based on https://developers.google.com/drive/api/v3/quickstart/python#step_2_configure_the_sample
creds = None
if os.path.exists(TOKEN_FILENAME):
    creds = Credentials.from_authorized_user_file(TOKEN_FILENAME, GOOGLE_API_SCOPES)
if not creds or not creds.valid:
    if creds and creds.expired and creds.refresh_token:
        creds.refresh(Request())
    else:
        print("Must obtain new token. Please run 'obtain_new_token.py' manually.")
        exit(1)
    # Save the credentials for the next run
    with open('token.json', 'w') as token:
        token.write(creds.to_json())

service = build('drive', 'v3', credentials=creds)

print(f"Uploading {original_name} to drive with the filename {backup_name}")
media = MediaFileUpload(original_name, mimetype=mimetype)
service.files().create(
    supportsTeamDrives=True,
    media_body=media,
    body={
        "parents": [BACKUP_TEAM_DRIVE_FOLDER_ID],
        "name": backup_name,
    }
).execute()
print("Backup finished.")
