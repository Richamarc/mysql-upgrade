# Instant MySQL 5.7 Server

## Description

This project is designed to automatically create a running instance of MySQL 5.7 to test running ansible upgrade scripts on it.

## Tech Requirements - Set-Up Instructions

### GCP

* Create a GCP [account](https://console.cloud.google.com/getting-started)
* Install gcloud using [these instructions for linux/wsl](https://cloud.google.com/sdk/docs/install#linux) or [these instructions for mac](https://cloud.google.com/sdk/docs/install#mac)
* Login to gcloud cli: `gcloud auth login`
* Create a GCP project: `gcloud projects create mysql-upgrade-[your-name] --set-as-default`
* Enable Google Compute Engine (this hosts the VMs that you will be using): `gcloud services enable compute.googleapis.com`
* Enable Google IAM API: `gcloud services enable iam.googleapis.com`
* Create a service account key: `gcloud iam service-accounts create service-mysql-upgrade --description="used for the mysql upgrade test" --display-name="mysql-ug"`
* Modify service account role: `gcloud projects add-iam-policy-binding mysql-upgrade-test --member="serviceAccount:service-mysql-upgrade@mysql-upgrade-[your-name].iam.gserviceaccount.com" --role="editor"`
* Create a service account key and download it to the Terraform directory (make sure pwd is main project folder): `gcloud iam service-accounts keys create ./terraform/gcp-private.json --iam-account="service-mysql-upgrade@mysql-upgrade-test.iam.gserviceaccount.com"`
    * The private key should be in the .gitignore file - but double check and don't upload it to github just in case! You can read more about service account keys in [Google's documentation](https://cloud.google.com/iam/docs/creating-managing-service-account-keys).
* Rename all references to `bathtub-pilot` in the code to your project name: `sed -i 's/bathtub-pilot/mysql-upgrade-[your-name]/g' ./ansible/inventory/00-gcp.yaml ./terraform/main.tf`

### Terraform

* Install using [these instructions](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* Run `cd ./terraform && terraform init` in the Terminal inside the project folder

## Provisioning and configuring server

* Inside the project folder run `cd ./terraform && terraform apply`
* Once complete, run `cd ./../ansible && ansible-playbook ./playbooks/01-python-install.yaml`
* DEV NOTE [for my own future reference]: if using WSL, can come accross time sync issue between windows and WSL -- to check if they're out of sync, enter `$ date` into terminal and compare the time. If they're out of sync, use the command `sudo hwclock -s`
