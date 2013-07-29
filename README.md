Centos-Backup-Script
====================
by [RaveMaker][RaveMaker] & [ET][ET].

This script purpose is to create daily backup archives (`tar.gz`) of selected directories/files and/or MYSQL dumps.

> NOTE: This script is in intended for expert users, 
please read carefully the script and the instructions and use it at your own risk.

This script support:

* Backup selected directories & files.
* Backup selected MySQL Databases dump.
* Compress and archive all into one `.tar.gz` file.
* Create .tgz in a backup folder for each backup session.
* Delete older backups and keep only the last backups (6 by default).
* Save each backup session in different directory (/backup/0 .. backup/6).

> root access may be required to run this script.

Documentation
-------------

### Installation

1. Clone this script from github:

	    git clone https://github.com/ET-CS/Centos-Backup-Script.git

	or copy the files manually to your prefered directory.

2. Create setting.cfg from the included settings.cfg.example.

	    cp settings.cfg.example settings.cfg

3. Create `/scripts` folder or change the `workdir` setting (inside settings.cfg) to a valid existing folder:

		workdir=/scripts

	> `workdir` is the folder the script using to save the temporary files & the backups inside.

4. Create `/backup` folder inside your `workdir` folder. 

### Configure backups
Create `/lst` folder inside the `workdir` and put inside two files: `db.lst` & `folders.lst`.

you can set manually the location of those files manully by changing the settings inside settings.cfg:
		
		# list of databases to backup		
		listfile=$workdir/lst/db.lst
		# list of folders/files to backup
		backuplistfile=$workdir/lst/folders.lst

The script read `listfile` for MySQL databases to backup and `backuplistfile` for directories/files to backup.

#### Example

1. **db.lst** - Fill one MySQL database name at a row:

		mydatabase1
		mydatabase2
		mydatabase3

2. **folders.lst** - Input list of all folders to backup in one row:

		/var/log/ /var/www/ /usr/files/ /tftpd/

### How backup files are saved
all backups are saved by default i0nside your `workdir`/backup folder. each backup inside seperate subdirectory.

* by default, the script saves 6 older backups. this can be changed using the `BACKUP_COPIES` settings (inside settings.cfg).
* first backup will be saved at /$workdir/backup/0
* at second backup, 0 folder will renamed 1 and the new backup will be saved at /$workdir/backup/0 again.
* when all 7 folders (6 older and the current - /backup/0) are full - folder /backup/6 will be deleted; 5 will be renamed to 6; 4 to 5.. etc.. 0 again will be the newest backup.

> backup/0 is the newer backup. backup/6 is the oldest backup  

you can set the backup destination to another folder by manually editing the `backupdir` setting. 

> Currently, 	The /backup folder existence check not made. you have to create this folder manually inside the `workdir` (as explained in Installation / Step 4):

### Enable script
By default, the script is disabled **and** set in testmode (no actual HD writes). 

1. To enable the script you need to change in your settings.cfg file:

		DISABLED=false

2. Configure the settings; Test the script in your environment in testmode and  verify using the console output that everything is ok. disable testmode by change the setting inside your settings.cfg:
 
		WRITE_CHANGES=true

### Setup cron
Setup cron to run your script daily (or at any timing you want).

### Known Issues


[RaveMaker]: http://ravemaker.net
[ET]: http://etcs.me
