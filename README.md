Centos-Backup-Script
====================

The purpose of this script is to create daily backup archives (`tar.gz`) of selected directories/files and/or MYSQL dumps.

> NOTE: This script is intended for expert users, 
please read carefully the script and the instructions and use it at your own risk.

This script support:

* Backup selected directories & files.
* Backup selected MySQL Databases dump.
* Compress and archive all into one `.tar.gz` file.
* Create .tgz in a backup folder for each backup session.
* Delete older backups and keep only the latest backups (6 by default).
* Save each backup archive in a different directory (/backup/0 .. backup/6).

> root access may be required to run this script.

Documentation
-------------

### Installation

1. Clone this script from github:

	    mkdir /scripts
	    cd /scripts
	    git clone https://github.com/ET-CS/Centos-Backup-Script.git

	or copy the files manually to your prefered directory.

2. Create setting.cfg from the included settings.cfg.example.

	    cp settings.cfg.example settings.cfg

3. Edit the settings files and update with your mysql user/password

### Configure backups
Create file inside the `/lst` folder called `folders.lst`.
The script reads for directories/files to backup. Input list of all folders to backup in one row:

		/var/log/ /var/www/ /usr/files/ /tftpd/

### How backup files are saved
all backups are saved by default inside your `workdir`/backup folder. each backup inside a seperate subdirectory.

* by default, the script saves 6 older backups. this can be changed using the `BACKUP_COPIES` settings (inside settings.cfg).
* first backup will be saved at /$workdir/backup/0
* at second backup, 0 folder will renamed 1 and the new backup will be saved at /$workdir/backup/0 again.
* when all 7 folders (6 older and the current - /backup/0) are full - folder /backup/6 will be deleted; 5 will be renamed to 6; 4 to 5.. etc.. 0 again will be the newest backup.

> backup/0 is the newer backup. backup/6 is the oldest backup  

you can set the backup destination to another folder by manually editing the `backupdir` setting. 

### Enable script
By default, the script is set in test-mode (NO BACKUP). 

1. Configure the settings, Test the script in your environment in testmode and verify using the console output that everything is ok. disable testmode by changing the setting inside your settings.cfg:
 
		WRITE_CHANGES=true

### Setup cron
Setup cron to run your script daily (or at any timing you want).

for example:

	    crontab -e

add inside:

	    0 0 * * * /scripts/Centos-Backup-Script/backup.sh

by [RaveMaker][RaveMaker] & [ET][ET].
[RaveMaker]: http://ravemaker.net
[ET]: http://etcs.me
