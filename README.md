# Instant Slack App

## Description

This project is designed to automatically create a running instance of a slack app using Flask, Terraform, Ansible, and GCP.

## Tech Requirements - Set-Up Instructions

### GCP

* [Instructions from Terraform Site](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build)
* Create a GCP account
* Create a GCP project
* Enable Google Compute Engine (this hosts the VMs that you will be using)

Create a service account key
* Select the project you created in the previous step.
* Click "Create Service Account".
* Give it any name you like and click "Create".
* For the Role, choose "Project -> Editor", then click "Continue".
* Skip granting additional users access, and click "Done".

After you create your service account, download your service account key:
* Select your service account from the list.
* Select the "Keys" tab.
* In the drop down menu, select "Create new key".
* Leave the "Key Type" as JSON.
* Click "Create" to create the key and save the key file to your system.
You can read more about service account keys in [Google's documentation](https://cloud.google.com/iam/docs/creating-managing-service-account-keys).

* Add private key as separate file inside `slack-app/terraform` folder called `gcp-private.json` - then add it to `.gitignore` if necessary to ensure not to publically upload it.

### Terraform

* Install using [these instructions](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* Run `cd ./terraform && terraform init` in the Terminal inside the project folder

## Running Server

* Inside the project folder run `cd ./terraform && terraform apply`
* Once complete, run `cd ./../ansible && ansible-playbook ./playbooks/01-python-install.yaml`
* Then run `ansible-playbook ./playbooks/02-load-app.yaml` 
* In the terminal, there will be an output called "Web-server-URL" that will have a link to the url the app will eventually be listening on
* TO BE CREATED: automated running of bolt-app
* DEV NOTE [for my own future reference]: if using WSL, can come accross time sync issue between windows and WSL -- to check if they're out of sync, enter `$ date` into terminal and compare the time. If they're out of sync, use the command `sudo hwclock -s`

## Using Google Cloud SDK Cli

* Install using [these instructions](https://cloud.google.com/sdk/docs/install#linux)