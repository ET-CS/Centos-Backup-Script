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

	and update your mysql user/password inside.
	update also the `workdir` folder to the location of this script

### Configure backups
Create file inside the `/lst` folder called `folders.lst`.
The script reads for directories/files to backup. Input list of all folders to backup, one folder per line:

		/var/log/
        /var/www/
        /usr/files/
        /tftpd/
        
Create file inside the `/lst` folder called `db.lst`.
The script reads for MySQL schemas to backup, if `SQL_BACKUP_ALL` is changed to `false`. Input list of all schemas to backup, one schema per line:

		wordpress
        phpmyadmin

### (Optional) Configure remote backup via SMB/CIFS
*This is turned off by default.

In order to enable:
in the settings.cfg.example you'll see a setting "BACKUP_REMOTELY=false" change to true.

To configure the remote host:
In the settings.cfg.example find "#Remote settings (cifs/smb)." You'll see an example of a remote host, this is where you'll need to change the host(remote) IP of the machine, the "share" name on the PC, along with your user and pass for the remote machine.

The backup will fail if these settings aren't correct and you'll need to correct what it says in the terminal before you'll be able to successfully backup.

Where is the share mounted to:
"$backupdir"

How to keep the remote share mounted after backup:
At the very bottom you'll see a setting "unmountremote=true". This is for if you'd like to keep the remote share mounted after backup is complete. Having to set to the default (true) will automatically unmount the remote share.

How do you setup a SMB/CIFS share?
You may need to enable it in the programs and features > additional features. Then you'll need to create a folder somewhere and right click > give access to > specific people. Make sure the user you're sharing access to has permissions on the folder and while in the permissions tab delete the "Everyone" permission in order to only allow the user you want to be able to access your backups. 

When in doubt google it. There's a ton of info out there on this. 

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

Authors: [RaveMaker][RaveMaker] & [ET][ET].

[RaveMaker]: http://ravemaker.net
[ET]: http://etcs.me
