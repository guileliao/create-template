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


#===============
#public_function
#===============
#
#------------
#check_os_ver
#------------
#judge system version
function CHECK_OS_VER()
{
    if [[ $(cat /etc/system-release-cpe |awk -F ':' '{print $4$5}') = "linux6" ]];then
        echo "centos6"
    elif [[ $(cat /etc/system-release-cpe |awk -F ':' '{print $4$5}') = "centos7" ]];then
        echo "centos7"
    elif [[ $(cat /etc/system-release-cpe |awk -F ':' '{print $4}') = "fedora" ]];then
        echo "$(cat /etc/system-release-cpe |awk -F ':' '{print $4$5}')"	
    else
        echo "error"
    fi
#function end
}

#--------------
#check_nic_name
#--------------
#get nic name
function CHECK_NIC_NAME()
{
    if [[ $(CHECK_OS_VER) = "centos6" ]];then
        echo "eth0"
    elif [[ $(CHECK_OS_VER) = "centos7" ]];then
        echo "$(ip addr|grep "^2"|awk -F ": " '{print $2}')"
    else
        echo "error" 
    fi
#funciton end
}

#-------------
#check_tomcat6
#-------------
#clean tomcat6 cache,log file
function CHECK_TOMCAT6()
{
    if [[ $(rpm -qa|grep "tomcat6") != "" ]];then
        rm -rf /var/log/tomcat6/*
        rm -rf /usr/share/tomcat6/temp/*
        rm -rf /usr/share/tomcat6/work/*
        chkconfig --level 345 tomcat6 on
    fi
#function end
}

#-----------
#check_mysql
#-----------
#clean mysql log file
function CHECK_MYSQL()
{
    if [[ $(rpm -qa|grep "mysql-server") != "" ]];then
        :>/var/log/mysqld.log
        :>/var/lib/mysql/auto.cnf
        chkconfig --level 345 mysqld on
    fi
#function end
}

#--------------
#check_geoagent
#--------------
#clean geoagent log file,add startup
function CHECK_GEOAGENT()
{
    if [ -d /opt/geoagent ];then
        rm -rf /opt/geoagent/log
    fi
    if [[ $(grep "geoagent" /etc/rc.local) = "" ]];then
        echo '/opt/geoagent/bin/geoagent' >> /etc/rc.local
    fi
#function end
}

#---------------
#disable_selinux
#---------------
#fix selinux status to "permissive"
function DISABLE_SELINUX()
{
    local _SESTATUS=$(sestatus|grep "^Current mode"|awk '{print $3}')
    if [[ ${_SESTATUS} != "permissive" ]];then
	    sed -i s/SELINUX=.*/SELINUX=permissive/g /etc/selinux/config
	    setenforce 0
	fi
    unset local _SESTATUS
#funciton end
}


#=============
#role_function
#=============
#
#---------------------
#redefine_nic_hostname
#---------------------
#redefine nic name,hostname
function REDEFINE_NIC_HOSTNAME()
{
    if [[ $(CHECK_NIC_NAME) = "error" ]];then
        echo -e "\e[31m Please check network card and OS.\e[0m" && exit
    elif [[ $(CHECK_NIC_NAME) = "eth0" ]];then
        echo "DEVICE=eth0" > /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "TYPE=Ethernet" >> /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "BOOTPROTO=dhcp" >> /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth0
        sed -i s/"^HOSTNAME="//g /etc/sysconfig/network
    else
        mv /etc/sysconfig/network-scripts/ifcfg-$(CHECK_NIC_NAME) /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "DEVICE=eth0" > /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "TYPE=Ethernet" >> /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "BOOTPROTO=dhcp" >> /etc/sysconfig/network-scripts/ifcfg-eth0
        echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth0
        sed -i s/'rhgb quiet"$'/'net.ifnames=0 biosdevname=0 rhgb quiet"'/g /etc/default/grub
        grub2-mkconfig -o /boot/grub2/grub.cfg
        sed -i s/"^HOSTNAME="//g /etc/sysconfig/network
	fi
#funciton end
}

#------------
#init_centos6
#------------
#clean system
function INIT_CENTOS6()
{
#disable selinux
    DISABLE_SELINUX
#disable iptables
    chkconfig --level 2345 iptables off
    chkconfig --level 2345 ip6tables off
#redefine nic hostname
    REDEFINE_NIC_HOSTNAME
#clean repo file
    if [[ $(ls /etc/yum.repos.d/*.repo) != "" ]];then
        mkdir -p /etc/yum.repos.d/bak
        mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak/
    fi
#remove system software package
    yum remove -y *kernel* selinux* system-config-* *-firmware man*
#initialize log policy
    logrotate -f /etc/logrotate.conf 2>/dev/null
#empty file
    cat /dev/null > /var/log/audit/audit.log 2>/dev/null
    cat /dev/null > /var/log/wtmp 2>/dev/null
#delete folder and file
    rm -rf /usr/share/man
    rm -rf /usr/share/doc
    rm -rf /usr/share/info
    rm -rf /tmp/*
    rm -rf /var/tmp/*
    rm -rf /var/cache/*
    rm -f /sbin/sln
    rm -f /etc/rpm/macros.imgcreate
    rm -f /etc/udev/rules.d/70*
    rm -f /var/lib/dhclient/*
    rm -f /etc/ssh/*key*
    rm -f /var/log/*-* /var/log/*.gz 2>/dev/null
#clean tomcat6
    CHECK_TOMCAT6
#clean mysql
    CHECK_MYSQL
#clean geoagent
    CHECK_GEOAGENT
#clean yum cache
    yum clean all
#create Buildtime
    date +%Y%m%d%H%M > /BUILDTIME
#empty bash history
    :>~/.bash_history
    history -c
#poweroff
    poweroff
#funciton end
}

#------------
#init_centos7
#------------
#clean system
function INIT_CENTOS7()
{
#disable selinux
    DISABLE_SELINUX
#disable firewall
    systemctl disable firewalld
#redefine nic hostname
    REDEFINE_NIC_HOSTNAME
#clean repo file
    if [[ $(ls /etc/yum.repos.d/*.repo) != "" ]];then
        mkdir -p /etc/yum.repos.d/bak
        mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak/
    fi
#remove system software package
    yum remove -y *kernel* selinux* system-config-* *-firmware man*
#initialize log policy
    logrotate -f /etc/logrotate.conf 2>/dev/null
#empty file
    cat /dev/null > /var/log/audit/audit.log 2>/dev/null
    cat /dev/null > /var/log/wtmp 2>/dev/null
#delete folder and file
    rm -rf /usr/share/man
    rm -rf /usr/share/doc
    rm -rf /usr/share/info
    rm -rf /tmp/*
    rm -rf /var/tmp/*
    rm -rf /var/cache/*
    rm -f /etc/rpm/macros.imgcreate
    rm -f /var/lib/dhclient/*
    rm -f /etc/ssh/*key*
    rm -f /var/log/*-* /var/log/*.gz 2>/dev/null
#clean mysql
    CHECK_MYSQL
#clean geoagent
    CHECK_GEOAGENT
#clean yum cache
    yum clean all
#create Buildtime
    date +%Y%m%d%H%M > /BUILDTIME
#empty bash history
    :>~/.bash_history
    history -c
#poweroff
    poweroff
#funciton end
}


#=============
#call_function
#=============
#call function
echo -e "\e[33m The operating system initialization is about to begin.\n Press 'Enter' key start.\e[0m"
read
if [[ $(CHECK_OS_VER) = "centos6" ]];then
    INIT_CENTOS6
elif [[ $(CHECK_OS_VER) = "centos7" ]];then
    INIT_CENTOS7
else
    echo -e "\e[31m What operating system you are using?\e[0m" && exit
fi


##########
#File end#
##########
