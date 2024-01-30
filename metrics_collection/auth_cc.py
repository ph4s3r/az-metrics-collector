#!/usr/bin/python3
#   about: Auth module for Azure SDKs using Client Secret creds
#  author: Peter Karacsonyi <peter.karacsonyi@domain.com>
#    date: 05 Apr 2023
# license: GNU General Public License, version 2
#####

from pathlib import Path
from azure.identity import ClientSecretCredential

CREDS_FILENAME = '.azure_creds' # should be in the user's home directory

def Auth_ClientSecretCredential():

    # read azure creds from file
    creds_file_path = Path.home().joinpath(CREDS_FILENAME)
    if not creds_file_path.is_file():
        raise FileNotFoundError(
          f"did not find credentials file @ {creds_file_path} for azure, exiting"
          )

    client_id = None
    client_secret = None

    with open(creds_file_path, 'r', encoding = 'utf-8') as f:
        client_id = f.readline().strip()
        client_secret = f.readline().strip()

    credential = ClientSecretCredential(
          tenant_id="<tenantId>",
          client_id=client_id,
          client_secret=client_secret
      )

    print(f"Authenticated successfully to azure with {client_id}")

    return credential
