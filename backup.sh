#!/bin/bash
# --------------------------------------------------------
# Centos-Server-Backup-Script.
#
#
# by RaveMaker & ET
# http://ravemaker.net
# http://etcs.me
#
# this script backup important files from your system:
# system files, db files, user files, services, etc.,
# and create .tgz in a backup folder for each backup session.
# root access required.
# --------------------------------------------------------
function remoteBackup {
    if $BACKUP_REMOTELY ; then
        printf "Remote backup host configured...  "
        mountRemote
    else
        echo "Skipping remote backup."
    fi;
}
function mountRemote {
    if ! [[ $(mount -v | grep -i -e 'type smb' -e 'type cifs') ]] ; then
        printf "Mounting remote backup host..."
        mount -t cifs //$REMOTE_HOST/$REMOTE_SHARE $backupdir -o username=$REMOTE_USER,password=$REMOTE_PASS,nounix
        RESULT=$?
        if [ $RESULT == 0 ] ; then
            printf "Ok.\n"
        else
            printf "Failed!\n"
            exit $RESULT;
        fi;
    fi;
  }

function checkLists {
    if $BACKUP_MYSQL ; then
        if ! [ -f $dblistfile ] ; then
            echo "Missing MySQL backup Listfile. create $dblistfile"
            exit 1;
        fi;
    fi;
    if $BACKUP_USERFILES ; then
        if ! [ -f $backuplistfile ] ; then
            echo "Missing backup Listfile. create $backuplistfile"
            exit 1;
        fi;
    fi;
}

function checkBackupStatus {
    if $BACKUP_DAILY_ONLY_ONCE ; then
        if [ -f $backupdir/0/$filename ] ; then
            echo "Backup already exist - try again tomorrow."
            exit;
        fi;
    fi;
    if [ -d $tempdir ] ; then
        echo ""
        echo "Backup is already running. remove temp folder to reset."
        exit;
    fi;
}

function createTemporaryFolder {
    printf "Creating temporary directory.. "
    if $WRITE_CHANGES ; then
        mkdir $tempdir
        printf "Ok\n"
    else printf "Skipping\n"
    fi;
}

function deleteOldestBackup {
    if $WRITE_CHANGES ; then
        if [ -d $backupdir/$1/ ] ;
        then
            echo "Deleteing Number $1";
            rm -r -f $backupdir/$1/ ;
        fi;
    fi;
}

function deleteOldBackups {
    count=$(ls -1 $backupdir | wc -l)
    for (( c=$count; c>=$1; c-- ))
    do
        deleteOldestBackup $c
    done
}

function shiftBackup {
    if [ -d $backupdir/$1/ ] ; then
        printf "Moving Number $1 to Number $2.. ";
        if $WRITE_CHANGES ; then
            mv $backupdir/$1 $backupdir/$2/ ;
            printf "Ok\n"
        else printf "Skipping\n"
        fi;
    fi;
}

function shiftBackups {
    for (( c=$BACKUP_COPIES; c>0; c-- ))
    do
        b=$c
        let "b -= 1"
        shiftBackup $b $c
    done
}

function dumpSQL {
    if $WRITE_CHANGES && $BACKUP_MYSQL ; then
        if $SQL_BACKUP_ALL ; then
            printf "Regenerating DB list file.. ";
            mysql -u $SQL_USER -p$SQL_PASSWD -Bse 'show databases' > $dblistfile
        fi;
        echo "Dumping SQL Databases.. ";
        cat $dblistfile | while read line
        do
            dbname=$line
            echo $dbname
            if [ $line != "information_schema" ] ;
            then
                mysqldump --events --ignore-table=mysql.events -u $SQL_USER -p$SQL_PASSWD $dbname > $tempdir/$dbname.sql
            fi
        done
    fi;
}

function createBackup {
    echo "Creating TGZ Backup file for..";
    echo "directories:"
    cat $backuplistfile | while read line
    do
        for d in $line; do
    	    echo $d
    	    # take target directory to backup and replace / with _ for backup filename
    	    target_backup_file=$tempdir/${d//[\/]/_}$filename
    	    if $WRITE_CHANGES && $BACKUP_USERFILES ; then
                tar zcfP $target_backup_file $d > $logdir/$filename.log
    	    fi;
            done
            break
        done
    echo "databases"
    if $WRITE_CHANGES && $BACKUP_MYSQL ; then
        tar zcfP $tempdir/db.$filename $tempdir/*.sql > $logdir/db.$filename.log
    fi;
}

function moveBackup {
    printf "Move from temp to Backup Number 0.. ";
    if $WRITE_CHANGES ; then
        mkdir $backupdir/0/
        #mv $tempdir/$filename $backupdir/0/ ;
        mv $tempdir/*$filename $backupdir/0/ ;
        printf "Ok\n"
    else printf "Skipping\n"
    fi;
}

function cleanBackup {
    printf "Cleaning.. ";
    if $WRITE_CHANGES ; then
        rm -r -f $tempdir/
        printf "Ok\n"
    else printf "Skipping\n"
    fi;
}
function remoteUnmount {
    if $BACKUP_REMOTELY ; then
        if $unmountremote ; then
            printf "Unmounting remote host"
            umount $backupdir
            RESULT=$?
            if [ $RESULT == 0 ] ; then
                printf "Ok.\n"
            else
                printf "Failed!\n"
                exit $RESULT;
            fi;
        fi;
    fi;
}

function startBackup {
    if $DISABLED ; then
        echo "Skipping backup - script disabled"
        exit
    else
        checkLists
        checkBackupStatus
        if $WRITE_CHANGES ; then
            echo "Starting Backup..."
        else
            echo "Running in test mode..."
        fi;
        # step 1: check if and then mount remote backup host or skip
        remoteBackup
        createTemporaryFolder
        # step 1: delete old backups
        deleteOldBackups $BACKUP_COPIES
        # step 2: shift the middle snapshots(s) back by one, if they exist
        shiftBackups
        # step 4: dump sql dbs
        dumpSQL
        # step 5: create new backup
        createBackup
        # step 6: move to location 0
        moveBackup
        # step 7: clear temp for the next run
        cleanBackup
        # step 8: if unmountremote then unmount backupdir
        remoteUnmount
    fi;
}

# Intro
echo "Copyright(c) 2013 Backup script. - by Ravemaker & ET"
# Load settings
SCRIPTDIRECTORY=$(cd `dirname $0` && pwd)
cd $SCRIPTDIRECTORY
if [ -f /etc/backup.cfg ] ; then
    echo "Loading settings..."
    source /etc/backup.cfg
elif [ -f settings.cfg ] ; then
    echo "Loading settings..."
    source settings.cfg
else
    echo "ERROR: Create settings.cfg (from settings.cfg.example)"
    exit
fi;
# Start backup
startBackup
# Final
echo
if $showfsz ; then
    df -h
fi;
echo "All done"
