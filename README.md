# webdav.sh

Install and configure webdav on debian with authentication!

**Required:**
Apache and modules: dav_fs/auth_digest
Install default.

## Configure:

Put your username here, used for apache authentication!:
Or execute and program will ask for u.

```
userWebdavAuth="YorUserNameHere"
```

## Install

```
curl https://raw.githubusercontent.com/slackjeff/webdav.sh/main/webdav.sh | sudo bash
```

#### or

```
curl https://raw.githubusercontent.com/slackjeff/webdav.sh/main/webdav.sh
chmod u+x webdav.sh
sh webdav.sh
```
