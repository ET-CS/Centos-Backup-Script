Centos-Backup-Script
====================
by [RaveMaker][RaveMaker] & [ET][ET].

    MOTE: This script is still in early development, use it carefully. not recommended for beginners.

    NOTE: By default, script is disabled and in testmode. enable it.. (DISABLED=false),
          test your environment, and then you can set WRITE_CHANGES=true


How to use
----------

### Using Git
Clone this script from github:
    git clone https://github.com/ET-CS/Centos-Backup-Script.git

### Manual
or copy [`backup.sh`][backup.sh] to any directory.

### Known Issues
as for now, folder existence checks not made, you have to create folders in the workfolder (script folder):

1. /log/
2. /backup/
3. /lst/

NOT IMPLEMENTED: you can use `setcron.sh` for example how to set up cron.



[backup.sh]: https://github.com/ET-CS/Centos-Backup-Script/blob/master/backup.sh
[RaveMaker]: http://ravemaker.net
[ET]: http://etcs.me