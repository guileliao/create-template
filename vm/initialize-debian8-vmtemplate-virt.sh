#!/bin/sh
#
# Filename: initialize-debian8-template-virt.sh
# Features: Create Debian8 vmtemplate for virt.
# Version: {}
# Buildtime: {YYYYMMDDHHMMSS}
# Auteur: guile.liao
# Email: liaolei@geostar.com.cn
# Copyleft: Licensed under the GPLv3
#
#
# The warning message: color=red[31m]
# The correct message: color=green[32m]
# The information: color=yellow[33m]
# The menu: color=blue[34;1m]
# The keyword: color&highlighted[1m]
# The global variable name: _VARIABLE_NAME_
# The local variable name: _VARIABLE_NAME
# Usage variable: ${VARIABLE_NAME}
# The function name: FUNCITON_NAME()
#
#==========
#set myself
#==========
#
set -u
#set -e
#


#apt-get remove -y *kernel* selinux* system-config-* *-firmware man*
cat /dev/null > /var/log/wtmp 2>/dev/null
logrotate -f /etc/logrotate.conf 2>/dev/null
rm -rf /tmp/*
rm -f /etc/udev/rules.d/70*
rm -f /var/lib/dhcp/*
rm -f /var/log/*-* /var/log/*.gz 2>/dev/null
apt-get clean all
rm -rf /var/cache/*
unset HISTFILE
/bin/date +%Y%m%d%H%M > /BUILDTIME
history -c
poweroff
