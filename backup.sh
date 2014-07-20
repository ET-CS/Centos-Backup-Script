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

function checkLists {
    #if ! [ -f $listfile ] ; then
    #    echo "Missing DB Listfile. create $listfile"
    #    exit
    #fi;
    if ! [ -f $backuplistfile ] ; then
        echo "Missing backup Listfile. create $backuplistfile"
        exit
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
        echo "Backup is running."
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
    printf "Regenerating DB list file.. ";
    if $WRITE_CHANGES ; then
        mysql -u $SQL_USER -p$SQL_PASSWD -Bse 'show databases' > $listfile
        printf "Dumping SQL Databases.. ";
        cat $listfile | while read line
        do
            dbname=$line
            if [ $line != "information_schema" ] ;
            then
                mysqldump --events --ignore-table=mysql.events -u $SQL_USER -p$SQL_PASSWD $dbname > $tempdir/$dbname.sql
            fi
        done
        printf "Ok\n"
    else printf "Skipping\n"
    fi;
}

function createBackup {
    if $WRITE_CHANGES ; then
        cat $backuplistfile | while read line
        do
            echo "Creating TGZ Backup file";
            tar zcfP $tempdir/$filename $tempdir/*.sql $line > $workdir/log/$filename
            break
        done
    fi;
}

function moveBackup {
    printf "Move from temp to Backup Number 0.. ";
    if $WRITE_CHANGES ; then
        mkdir $backupdir/0/
        mv $tempdir/$filename $backupdir/0/ ;
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
        createTemporaryFolder
        # step 1: delete oldest backup
        deleteOldestBackup $BACKUP_COPIES
        # step 2: shift the middle snapshots(s) back by one, if they exist
        shiftBackups
        # step 3: dump sql dbs
        dumpSQL
        # step 4: create new backup
        createBackup
        # step 5: move to location 0
        moveBackup
        # step 6: clear temp for the next run
        cleanBackup
    fi;
}

# Intro
echo "Copyright(c) 2013 Backup script. - by Ravemaker & ET"
# Load settings
SCRIPTDIRECTORY=$(cd `dirname $0` && pwd)
cd $SCRIPTDIRECTORY
if [ -f settings.cfg ] ; then
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
    df -h /dev/sda
fi;
echo "All done"
