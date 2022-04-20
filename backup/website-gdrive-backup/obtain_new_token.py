import os.path
from sys import exit

from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials

from settings import *


# Code based on https://developers.google.com/drive/api/v3/quickstart/python#step_2_configure_the_sample
creds = None
if os.path.exists(TOKEN_FILENAME):
    creds = Credentials.from_authorized_user_file(TOKEN_FILENAME, GOOGLE_API_SCOPES)
if creds and creds.valid:
    continue_anyway = input("A valid token already exists. Obtain a new one anyway? (y/n) ")
    continue_anyway_lower = continue_anyway.lower()
    if continue_anyway_lower == "n":
        print("Exiting.")
        exit(0)
    elif continue_anyway_lower != "y":
        print(f"Unable to understand '{continue_anyway}'. Exiting.")
        exit(0)

if creds and creds.expired and creds.refresh_token:
    creds.refresh(Request())
else:
    flow = InstalledAppFlow.from_client_secrets_file(CREDENTIALS_FILENAME, GOOGLE_API_SCOPES)
    creds = flow.run_console()
# Save the credentials for the next run
with open(TOKEN_FILENAME, 'w') as token:
    token.write(creds.to_json())

print("Successfully obtained and wrote new token.")
