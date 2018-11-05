#!/bin/bash

cd /data/sso/ && git pull
chown -R sysop:www-data /data/sso/
chmod -R o-rwx /data/sso/
