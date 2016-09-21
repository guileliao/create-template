#!/bin/bash
#
# Filename: {FILENAME.SH}
# Features: {FEATURES}
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


#===============
#public_function
#===============
#
#---------------
#disable_selinux
#---------------
#fix selinux status to "permissive"
function DISABLE_SELINUX()
{
    local _SESTATUS=$(sestatus|grep "^Current mode"|awk '{print $3}')
    if [[ ${_SESTATUS} != "permissive" ]];then
	    sed -i s/"SELINUX=.*"/"SELINUX=permissive"/g /etc/selinux/config
	    setenforce 0 &>/dev/null
	fi
    unset local _SESTATUS
#funciton end
}

#--------------
#check_iptables
#--------------
#check firewall status
function CHECK_IPTABLES()
{
    if [[ "$(CHECK_OS_VER)" = "centos6" ]];then
        service iptables stop &>/dev/null && chkconfig --level 2345 iptables off &>/dev/null
        service ip6tables stop &>/dev/null && chkconfig --level 2345 ip6tables off &>/dev/null
    elif [[ "$(CHECK_OS_VER)" = "centos7" ]];then
        systemctl stop firewalld &>/dev/null && systemctl disable firewalld &>/dev/null 
    fi
    echo -e "\e[32m Firewall has been stopped.\e[0m"
#funciton end
}

#----------------
#check_ntp_client
#----------------
#check ntpd service status
#code "0"=ntp service is OK.
#code "1"=Package 'ntp' has been not installed.
#code "2"=ntp server address has not set.
function CHECK_NTP_CLIENT()
{
    if [ -z "$(which ntpq)" ];then
        echo "1"
    elif [ -z "$(grep '^server ntp.gfstack.geo iburst' /etc/ntp.conf)" ];then
        echo "2"
    else
        echo "0" && chkconfig --level 345 ntpd on &>/dev/null
    fi
#funciton end
}

#------------
#check_vsftpd
#------------
#check httpd service status
#code "0"=Vsftpd service is OK.
#code "1"=Package 'vsftpd' has been not installed.
function CHECK_VSFTPD()
{
    if [ -z "$(which vsftpd)" ];then
        echo "1"
    else
        echo "0" && chkconfig --level 345 vsftpd on &>/dev/null
        sed -i s/"^root"/"#root"/g /etc/vsftpd/user_list
        sed -i s/"^root"/"#root"/g /etc/vsftpd/ftpusers
        service vsftpd restart &>/dev/null
    fi
#funciton end
}

#----------------
#check_oracle_jdk
#----------------
#check oracle jdk packages,$JAVA_HOME
#code "0"=Oracle JDK is OK.
#code "1"=Oracle JDK has been not installed.
#code "2"=Oracle JDK version error.
#code "3"='$JAVA_HOME' has not set.
function CHECK_ORACLE_JDK()
{
    if [ -z "$(rpm -qa|grep "jdk")" ];then
        echo "1"
    elif [ -z "$(rpm -qa|grep "jdk"|grep "1.6.0_45")" ];then
        echo "2"
    elif [ -z "$(echo ${JAVA_HOME})" ];then
        echo "3"
    else
        echo "0"
    fi
#function end
}

#-------------
#check_tomcat6
#-------------
#Only supports the use of "yum install" way on centos6 installation
#clean tomcat6 cache,log file
#code "0"=Tomcat6 is OK.
#code "1"=Tomcat6 has been not installed.
#code "2"=Oracle JDK version error.
#code "3"='$JAVA_HOME' has not set.
function CHECK_TOMCAT6()
{
    if [ -z "$(rpm -ql tomcat6-admin-webapps)" ];then
        echo "0" && chkconfig --level 345 tomcat6 on &>/dev/null
        rm /var/log/tomcat6/* -rf
        rm /usr/share/tomcat6/temp/* -rf
        rm /usr/share/tomcat6/work/* -rf
    else
        echo "1"
    fi
#function end
}

#--------------
#check_geoagent
#--------------
#clean geoagent log file,add startup
#code "0"=Geoagent is OK.
#code "1"=Dependent error.
#code "2"=Geoagent has been not installed.
function CHECK_GEOAGENT()
{
    if [ -z "$(rpm -qa|grep "activemq-cpp")" ];then
        echo "1"
    elif [ -d /opt/geoagent ];then
        echo "0"
        rm /opt/geoagent/log -rf
    elif [ -z "$(grep "geoagent" /etc/rc.local)" ];then
        echo '/opt/geoagent/bin/geoagent' >> /etc/rc.local
    elif [ -z "$(grep "/opt/geoagent/bin" /etc/ld.so.conf)" ];then
        echo "/opt/geoagent/bin" >> /etc/ld.so.conf && lddconfig
    else
        echo "2"
    fi
#function end
}

#------------------
#check_zabbix_agent
#------------------
#check zabbix-agent
#code "0"=zabbix_agent is OK.
#code "127"=zabbix_agent has been not installed.
#other code need decimal convert to binary;0=right,1=error.

function CHECK_ZABBIX_AGENT()
{
    local _ARRAY_OPTION=(
        'Server=monsrv.gfstack.geo'
        'ListenPort=10050'
        'ListenIP=0.0.0.0'
        'ServerActive=monsrv.gfstack.geo'
        'Hostname=Zabbix server'
    )
    local _ARRAY_COUNTER=(0 0 0 0 0)
    for ((i=0;i<${#_ARRAY_OPTION[@]};i++));
        do
            if [ -n "$(grep "${_ARRAY_OPTION[${i}]}" /etc/zabbix/zabbix_agentd.conf)" ];then
                local _ARRAY_COUNTER[${i}]=0
            else
                local _ARRAY_COUNTER[${i}]=1
            fi
        done
    if [ -z "$(which zabbix_agent)" ];then
        echo "127"
    elif [ $(echo $((2#$(echo ${_ARRAY_COUNTER[@]}|sed s/" "//g)))) != "0" ];then
        echo $((2#$(echo ${_ARRAY_COUNTER[@]}|sed s/" "//g)))
    else
        echo "0" && chkconfig --level 345 zabbix-agent on
    fi
    unset local _ARRAY_OPTION
    unset local _ARRAY_COUNTER
#function end
}

#----------------------
#check_geoglobe_runtime
#----------------------
#check geoglobe runtime install and setup
#code "0"=geoglobe runtime is OK.
#code "1"=geoglobe runtime has been not installed.
function CHECK_GEOGLOBE_RUNTIME()
{
    if [ -n "$(rpm -ql geostack-operationproxy)" ];then
        echo "0"
    else
        echo "1"
    fi
#function end
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
    CHECK_IPTABLES
#redefine nic hostname
    REDEFINE_NIC_HOSTNAME
#clean repo file
    if [ -n "$(ls /etc/yum.repos.d/*.repo)" ];then
        mkdir -p /etc/yum.repos.d/bak
        mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak/
    fi
#remove system software package
    yum remove -y *kernel* selinux* system-config-* *-firmware man*
#initialize log policy
    logrotate -f /etc/logrotate.conf &>/dev/null
#empty file
    cat /dev/null > /var/log/audit/audit.log &>/dev/null
    cat /dev/null > /var/log/wtmp &>/dev/null
#delete folder and file
    rm /usr/share/man -rf &>/dev/null
    rm /usr/share/doc -rf &>/dev/null
    rm /usr/share/info -rf &>/dev/null
    rm /tmp/* -rf &>/dev/null
    rm /var/tmp/* -rf &>/dev/null
    rm /var/cache/* -rf &>/dev/null
    rm /sbin/sln -rf &>/dev/null
    rm /etc/rpm/macros.imgcreate -rf &>/dev/null
    rm /etc/udev/rules.d/70* -rf &>/dev/null
    rm /var/lib/dhclient/* -rf &>/dev/null
    rm /etc/ssh/*key* -rf &>/dev/null
    rm /var/log/*-* -rf &>/dev/null
    rm /var/log/*.gz -rf &>/dev/null
    if [[ $(CHECK_GEOGLOBE_RUNTIME) = "1" ]];then
        echo -e "\e[31m geoglobe runtime has been not installed,run me again.\e[0m"
        exit
    fi
    if [[ $(CHECK_GEOAGENT) = "2" ]];then
        echo -e "\e[31m Geoagent has been not installed,run me again.\e[0m"
        exit
    elif [[ $(CHECK_GEOAGENT) = "1" ]];then
        echo -e "\e[31m Geoagent dependent error,run me again.\e[0m"
        exit
    fi
    if [[ $(CHECK_ZABBIX_AGENT) = "127" ]];then
        echo -e "\e[31m Zabbix_agent has been not installed,run me again.\e[0m"
        exit
    elif [ $(CHECK_ZABBIX_AGENT) != "127" -a $(CHECK_ZABBIX_AGENT) != "0" ];then
        echo -e "\e[31m Please check 'zabbix_agent.conf',run me again.\e[0m"
        exit
    fi
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


#====
#menu
#====
#call funciton
function MENU()
{
    local _INPUT=""
    while true;
        do
            echo -e "\e[33m##############################\e[0m"
            echo -e "\e[33m System check begining......\e[0m"

            echo -e "\e[33m System check finished.\e[0m"
            echo -e "\e[33m##############################\e[0m"
            echo -e "\e[34m==============================\e[0m"
            echo -e "\e[34;1m 0.change_00\e[0m"
            echo -e "\e[34;1m 1.change_01\e[0m"
            echo -e "\e[34;1m 2.change_02\e[0m"
            echo -e "\e[34;1m x.Exit\e[0m"
            echo -e "\e[34m==============================\e[0m"
            read -p "Your choice is:" _INPUT
            case ${_IPNUT} in
                0)
                    clear
                    echo -e "\e[31;1m Press 'Enter' key exit.\e[0m"
                    read -t 5
                    ;;
                1)
                    clear
                    echo -e "\e[31;1m Press 'Enter' key exit.\e[0m"
                    read -t 5
                    ;;
                x)
                    clear
                    echo -e "\e[31m Press 'Enter' key exit.\e[0m"
                    read -t 5
                    clear
                    break
                    ;;
                *)
                    clear
                    echo -e "\e[31m What are you doing?\n Press 'Enter' key continue.\e[0m"
                    read -t 5
                    ;;
            esac
        done
#funciton end
}


##########
#file end#
##########