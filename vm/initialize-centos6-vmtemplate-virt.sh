#!/bin/sh
#
# Filename: initialize-centos6-template-virt.sh
# Features: Create CentOS6 vmtemplate for virt.
# Version: {}
# Buildtime: {YYYYMMDDHHMMSS}
# Auteur: guile.liao
# Email: liaolei@geostar.com.cn
# Copyleft: Licensed under the GPLv3
#
#
# The warning message: color=red
# The correct message: color=green
# The information: color=yellow
# The menu: color=blue
# The keyword: color&highlighted 
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


yum remove -y *kernel* selinux* system-config-* *-firmware man*
cat /dev/null > /var/log/audit/audit.log 2>/dev/null
cat /dev/null > /var/log/wtmp 2>/dev/null
logrotate -f /etc/logrotate.conf 2>/dev/null
rm -rf /usr/share/man
rm -rf /usr/share/doc
rm -rf /usr/share/info
rm -rf /tmp/*
rm -rf /var/cache/*
rm -f /sbin/sln
rm -f /etc/rpm/macros.imgcreate
rm -f /etc/udev/rules.d/70*
rm -f /var/lib/dhclient/*
rm -f /etc/ssh/*key*
rm -f /var/log/*-* /var/log/*.gz 2>/dev/null
#rm -rf /opt/geoagent/log
#rm -rf /var/log/tomcat6/*
#rm -rf /usr/share/tomcat6/temp/*
#rm -rf /usr/share/tomcat6/work/*
yum clean all
unset HISTFILE
/bin/date +%Y%m%d%H%M > /BUILDTIME
history -c
poweroff
