#!/usr/bin/env sh
#----------------------------------------------------------------------------#
# AUTHOR
#   slackjeff <slackjeff@riseup.net>
# DESC:
#   Install and configure webdav on debian with authentication!
#   Required: Apache and modules dav_fs/auth_digest
# TEST
#   Debian 12 [ok]
#----------------------------------------------------------------------------#
set -e

#----------------------------------------------------------------------------#
# CONFIGURE.
#----------------------------------------------------------------------------#
# Directory where the content will be saved
webdavDir="/var/www/webdav"
# webdav apache configuration
webdavConf="/etc/apache2/conf-available/webdav.conf"
# Username for apache authentication
userWebdavAuth="YorUserNameHere"

#----------------------------------------------------------------------------#
# TEST'S.
#----------------------------------------------------------------------------#
# Root?
[ $UID -ne 0 ] && { echo "Need root."; exit 1 ;}

system=$(lsb_release -i | awk -F '[:\t]+' '/Distributor ID/ {print $2}') #debian?
system=$(echo $system | tr 'A-Z' 'a-z') # lower
if [ $system != 'debian' ]; then
    printf "Tested on debian only."
    exit 1
fi
# Create Structure
printf "Creating structure...\n"
if [ ! -d "$webdavDir" ]; then
    mkdir -v $webdavDir
    chgrp -v www-data $webdavDir
    chmod -v g+w $webdavDir
fi

#----------------------------------------------------------------------------#
# Main.
#----------------------------------------------------------------------------#
# Send configuration
printf "Create configuration file in $webdavDir\n"
cat << SEND > $webdavConf
Alias /webdav   /var/www/webdav
<Location /webdav>
        DAV On
        AuthType Digest
        AuthName "webdav"
        AuthUserFile /etc/apache2/webdav.passwd
        Require valid-user
</Location>
SEND
printf "Enable Modules (dav_fs/auth_digest) apache if needed.\n"
# Enable modules
if ! apachectl -t -D DUMP_MODULES 2>/dev/null | grep -q 'dav_fs_module'; then
    a2enmod dav_fs
elif ! apachectl -t -D DUMP_MODULES 2>/dev/null | grep -q 'auth_digest_module'; then
    a2enmod auth_digest
fi
# Create authentication
printf "Password for user: ($userWebdavAuth)"
htdigest -c /etc/apache2/webdav.passwd webdav $userWebdavAuth
# Restart apache
printf "Restart apache...\n"
if systemctl restart apache2; then
    printf "OK, now test: http://127.0.0.1/webdav"
fi
