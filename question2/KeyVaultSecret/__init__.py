
import logging

import azure.functions as func
import os
from azure.identity import ManagedIdentityCredential
from azure.keyvault.secrets import SecretClient


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')
    if name:
        credential = ManagedIdentityCredential()
        secret_client = SecretClient(vault_url="https://"+name+".vault.azure.net/", credential=credential)
        secret = secret_client.get_secret("VaronisAssignmentSecret")
        httt_out = f"""
        {'-'*40}
         Name of the Key Vault =  { name }
         Name of the Key Vault secret=VaronisAssignmentSecret
         The Creation date of the secret= {secret.value } 
         The secret value= {secret.value}
         {'-'*40}
        """

        return func.HttpResponse(httt_out)
    else:
        return func.HttpResponse("Enter valid Key vault name name=< Key vault name>", status_code=200)
