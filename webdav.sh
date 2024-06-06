#!/usr/bin/env sh
#----------------------------------------------------------------------------#
# AUTHOR
#   slackjeff <slackjeff@riseup.net>
#
# DESC:
#   Install and configure webdav on debian with authentication!
#   Required: Apache and modules dav_fs/auth_digest
#
# License
# 	MIT
#----------------------------------------------------------------------------#
set -e

#----------------------------------------------------------------------------#
# CONFIGURE.
#----------------------------------------------------------------------------#

# Username for apache authentication
userWebdavAuth="YorUserNameHere"

# Directory where the content will be saved
webdavDir="/var/www/webdav"

# webdav apache configuration
webdavConf="/etc/apache2/conf-available/webdav.conf"

#----------------------------------------------------------------------------#
# TEST'S.
#----------------------------------------------------------------------------#

# Root?
[ $(whoami) != 'root' ] && { echo "Need root."; exit 1 ;}

(
	. /etc/os-release
	if [ $ID != 'debian' ] && [ $ID != ubuntu ] && [ $ID != zorin ]; then
	    printf "Tested on debian/ubuntu/zorin only."
	    exit 1
	fi
)

# If user did not provide the username, let us make request.
if [ "$userWebdavAuth" = "YorUserNameHere" ] || [ -z "$userWebdavAuth" ]; then
	printf "Give your Username for apache authentication: "
	read userWebdavAuth
fi

# Create Structure
printf '%b' "----------> Creating structure...\n"
if [ ! -d "$webdavDir" ]; then
    mkdir -v $webdavDir
    chgrp -v www-data $webdavDir
    chmod -v g+w $webdavDir
fi

#----------------------------------------------------------------------------#
# Main.
#----------------------------------------------------------------------------#

# Send configuration to /etc/apache2/conf-available/webdav.conf
printf '%b' "----------> Create configuration file in $webdavDir\n"
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

# Enable modules
printf '%b' "----------> Enable Modules (dav_fs/auth_digest) apache if needed.\n"
if ! apachectl -t -D DUMP_MODULES 2>/dev/null | grep -q 'dav_fs_module'; then
    a2enmod dav_fs
elif ! apachectl -t -D DUMP_MODULES 2>/dev/null | grep -q 'auth_digest_module'; then
    a2enmod auth_digest
fi

# Create authentication
printf "Password for user: ($userWebdavAuth) "
htdigest -c /etc/apache2/webdav.passwd webdav $userWebdavAuth

# Restart apache
printf '%b' "----------> Restart apache...\n"
if systemctl restart apache2; then
    printf "OK, now test: http://localhost/webdav"
fi
