# Instant MySQL 5.7 Server

## Description

This project is designed to automatically create a running instance of MySQL 5.7 to test running ansible upgrade scripts on it.

## Tech Requirements - Set-Up Instructions

### Clone repo

* `git clone https://github.com/Richamarc/mysql-upgrade.git`
* `cd mysql-upgrade`

### GCP

* Create a GCP [account](https://console.cloud.google.com/getting-started)
* Install gcloud using [these instructions for linux/wsl](https://cloud.google.com/sdk/docs/install#linux) or [these instructions for mac](https://cloud.google.com/sdk/docs/install#mac)
* Login to gcloud cli: `gcloud auth login`
* Add billing account: https://console.cloud.google.com/billing
* Create a GCP project: `gcloud projects create mysql-upgrade-[your-name] --set-as-default`
* Enable Google Compute Engine (this hosts the VMs that you will be using): `gcloud services enable compute.googleapis.com`
* Enable Google IAM API: `gcloud services enable iam.googleapis.com`
* Create a service account key: `gcloud iam service-accounts create service-mysql-upgrade --description="used for the mysql upgrade test" --display-name="mysql-ug"`
* Modify service account role: `gcloud projects add-iam-policy-binding mysql-upgrade-[your-name] --member="serviceAccount:service-mysql-upgrade@mysql-upgrade-[your-name].iam.gserviceaccount.com" --role="roles/editor"`
* Create a service account key and download it to the Terraform directory (make sure pwd is main project folder): `gcloud iam service-accounts keys create ./terraform/gcp-private.json --iam-account="service-mysql-upgrade@mysql-upgrade-[your-name].iam.gserviceaccount.com"`
    * The private key should be in the .gitignore file - but double check and don't upload it to github just in case! You can read more about service account keys in [Google's documentation](https://cloud.google.com/iam/docs/creating-managing-service-account-keys).
* Rename all references to `bathtub-pilot` in the code to your project name: `sed -i 's/bathtub-pilot/mysql-upgrade-[your-name]/g' ./ansible/inventory/00-gcp.yaml ./terraform/main.tf`

### Terraform

* Install using [these instructions](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* Run `cd ./terraform && terraform init` in the Terminal inside the project folder

## Provisioning and configuring server

* Inside the project folder run `cd ./terraform && terraform apply`
* Once complete, run `cd ./../ansible && ansible-playbook ./playbooks/01-python-install.yaml`
* DEV NOTE [for my own future reference]: if using WSL, can come accross time sync issue between windows and WSL -- to check if they're out of sync, enter `$ date` into terminal and compare the time. If they're out of sync, use the command `sudo hwclock -s`


## TODO - apt-get

download mysql package
wget https://dev.mysql.com/get/mysql-apt-config_0.8.12-1_all.deb
run through set up, select 5.7

add the mysql package to the apt-key ring file location
sudo wget -q -O - https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 | sudo apt-key add -

https://dev.mysql.com/downloads/gpg/?file=mysql-apt-config_0.8.24-1_all.deb&p=37

## TODO - please ignore for now
The below is a list of items to add as an ansible playbook or several roles to an ansible playbook

mysql dependencies?
sudo yum install\
    https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm -y
sudo yum install mysql-community-server -y

install percona-toolkit

sudo yum install https://downloads.percona.com/downloads/percona-toolkit/3.5.1/binary/redhat/7/x86_64/percona-toolkit-3.5.1-2.el7.x86_64.rpm -y
sudo yum install https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.27/binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.27-1.el7.x86_64.rpm

When uninstalling mysql - sometimes there are issues correctly parsing the programs you'd like to uninstall. This removes all of them
sudo yum remove mysql-*
sudo yum remove mysql57*

check for any packages
rpm -qa | grep mysql

download proper GPG-key / public key
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022

make backup of the my.cnf file
sudo cp /etc/my.cnf /etc/my.cnf_bak

remove all mysql installations
sudo yum  remove `rpm -qa | "grep -i mysql-comm" | tr "\n" " "`
sudo yum clean all --verbose



start mysqld
systemctl start mysqld
systemctl status mysqld

once started, need to get temp password
grep 'A temporary password' /var/log/mysqld.log |tail -1

in this case it was: Pu2*,>hux7iU
reset to new password: Pu3*,>hux7iU

run the /usr/bin/mysql_secure_installation script --> $ /usr/bin/mysql_secure_installation 
say yes to everything

Create a user:
CREATE USER 'db_user'@'localhost' IDENTIFIED BY 'd2!mK5%h30,2';

Give user permissions to do things:
GRANT ALL ON test.* TO 'db_user'@'localhost';

Reload the privileges to make sure they're in effect:
FLUSH PRIVILEGES;

Create a test database:
CREATE DATABASE test;
USE test;
CREATE TABLE users (
  id SERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL, 
  password VARCHAR(255) NOT NULL
);
CREATE TABLE categories (
  id SERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(255) NOT NULL,
  display VARCHAR(255) NOT NULL
);
CREATE TABLE todos (
  id SERIAL PRIMARY KEY NOT NULL,
  category_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  text VARCHAR(255) NOT NULL,
  completed BOOLEAN DEFAULT false NOT NULL
);

Add some users:
-- pw: gn
INSERT INTO users (name, email, password) 
VALUES ('G', 'g@dev.com', '$2a$10$aGJ7UuZqewkp8S8XsOnkgOumnltYd4kTneDAR5W9xugl12r4Jnnde');

-- pw: mr
INSERT INTO users (name, email, password)
VALUES ('M', 'm@dev.com', '$2a$10$hMSuJCANi7kC40VOhAomLurdZzYEv0L4zEtqRGqsEdLPsJkxRFa1e');

Add some data:
INSERT INTO categories (name, display) VALUES ('music', 'To Listen');
INSERT INTO categories (name, display) VALUES ('movie', 'To Watch - Movie');
INSERT INTO categories (name, display) VALUES ('tv show', 'To Watch - TV');
INSERT INTO categories (name, display) VALUES ('food', 'To Eat');
INSERT INTO categories (name, display) VALUES ('book', 'To Read');
INSERT INTO categories (name, display) VALUES ('other', 'Other');
INSERT INTO todos (text, category_id, user_id) VALUES ('The Beatles', 1, 1);
INSERT INTO todos (text, category_id, user_id) VALUES ('Paddington Bear', 2, 1);
INSERT INTO todos (text, category_id, user_id) VALUES ('Milk', 4, 1);
INSERT INTO todos (text, category_id, user_id) VALUES ('The Wire', 3, 1);
INSERT INTO todos (text, category_id, user_id) VALUES ('The Communist Manifesto', 5, 1);
INSERT INTO todos (text, category_id, user_id) VALUES ('Lady Gaga', 1, 2);
INSERT INTO todos (text, category_id, user_id) VALUES ('James Bond', 2, 2);
INSERT INTO todos (text, category_id, user_id) VALUES ('Bread', 4, 2);
INSERT INTO todos (text, category_id, user_id) VALUES ('Rugrats', 3, 2);
INSERT INTO todos (text, category_id, user_id) VALUES ('Automate the Boring Stuff With Python', 5, 2);
INSERT INTO todos (text, category_id, user_id, completed) VALUES ('The Necronomicon', 5, 2, true);
INSERT INTO todos (text, category_id, user_id, completed) VALUES ('Getting the love you want', 5, 1, true);
INSERT INTO todos (text, category_id, user_id, completed) VALUES ('Frozen Pizza', 4, 2, true);
INSERT INTO todos (text, category_id, user_id, completed) VALUES ('Brocolli', 4, 1, true);
INSERT INTO todos (text, category_id, user_id, completed) VALUES ('James Brown', 1, 1, true);
INSERT INTO todos (text, category_id, user_id, completed) VALUES ('Nicki Minaj', 1, 2, true);
INSERT INTO todos (text, category_id, user_id, completed) VALUES ('The Dark Knight', 2, 1, true);
INSERT INTO todos (text, category_id, user_id, completed) VALUES ('Lord of the Rings', 2, 2, true);
INSERT INTO todos (text, category_id, user_id, completed) VALUES ('The Good Place', 3, 1, true);
INSERT INTO todos (text, category_id, user_id, completed) VALUES ('Friday Night Lights', 3, 2, true);
INSERT INTO todos (text, category_id, user_id, completed) VALUES ('Bioneer Youtube Series', 6, 1, true);
INSERT INTO todos (text, category_id, user_id, completed) VALUES ('Buy Tennis Racket', 6, 2, true);

Run test using Percona Xtrabackup

Create a backup authorized user

CREATE USER 'backup'@'localhost' IDENTIFIED BY 'Backup@321';
GRANT RELOAD, SUPER, PROCESS ON *.* TO 'backup'@'localhost';
GRANT CREATE, INSERT, DROP, UPDATE ON mysql.backup_progress TO 'backup'@'localhost';
GRANT CREATE, INSERT, SELECT, DROP, UPDATE, ALTER ON mysql.backup_history 
    TO 'backup'@'localhost';
GRANT REPLICATION CLIENT ON *.* TO 'backup'@'localhost';
GRANT SELECT ON performance_schema.replication_group_members TO 'backup'@'localhost';
FLUSH PRIVILEGES;


Check the grants you have:
show grants;

Create backup directory:
sudo mkdir /data
sudo mkdir /data/backups

https://www.youtube.com/watch?v=KYN8171vARU (his privileges aren't correct for 5.7)
Create backup
$ sudo xtrabackup --backup --user=backup --password='Backup@321' --target-dir=/data/backup-20230301

Shutdown mysql
sudo systemctl stop mysqld

Prepare backup:
$ sudo xtrabackup --prepare --target-dir=/data/backup-20230301

OPTIONAL - delete the mysql datadir to demonstrate that you can do it!
$ sudo rm -rf /var/lib/mysql/*

Restore mysql:
$ sudo xtrabackup --copy-back --target-dir=/data/backup-20230301

Make sure that the data is owned / writable by mysql
sudo chown -R mysql:mysql /var/lib/mysql

MAKE SURE THAT THE SELinux permissions are correctly set
check the security contexts
$ ls -Z
May have to do the below if type is set to default_t and not mysqld_db_t:
$ sudo restorecon -R /var/lib/mysql/


Now for the test upgrade:
* stop the mysql process
* run config changes (no config changes needed yet)
* uninstall / remove binaries of mysql 5.7
sudo yum remove mysql-*
sudo yum remove mysql57*
* confirm uninstall complete
rpm -qa | grep mysql
* download mysql 8.0 binaries (get from https://dev.mysql.com/downloads/repo/yum/)
sudo yum install\
    https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm -y
sudo yum install mysql-community-server -y
* download xtrabackup used for mysql 5.7 (in case you need to use your backup files from 5.7)
sudo yum install https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.27/binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.27-1.el7.x86_64.rpm
* download percona-toolkit 8.0s
sudo yum install https://downloads.percona.com/downloads/percona-toolkit/3.5.1/binary/redhat/7/x86_64/percona-toolkit-3.5.1-2.el7.x86_64.rpm -y

* start mysql 8.0 on old datadir using modified config file

* shutdown and start the server (restart)
* uninstall old xtrabackup, install 8.0 compatible version
sudo yum install https://downloads.percona.com/downloads/Percona-XtraBackup-8.0/Percona-XtraBackup-8.0.31-24/binary/redhat/7/x86_64/percona-xtrabackup-80-8.0.31-24.1.el7.x86_64.rpm -y
