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

#---------------
#disable_selinux
#---------------
#fix selinux status to "permissive"
function DISABLE_SELINUX()
{
    local _SESTATUS=$(sestatus|grep "^Current mode"|awk '{print $3}')
    if [[ ${_SESTATUS} != "permissive" ]];then
	    sed -i s/SELINUX=.*/SELINUX=permissive/g /etc/selinux/config
	    setenforce 0 &>/dev/null
	fi
    unset local _SESTATUS
#funciton end
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

#----------------
#check_ntp_client
#----------------
#check ntpd service status
#code "0"=ntp service is OK.
#code "1"=Package 'ntp' has been not installed.
#code "2"=ntp server address has not set.
function CHECK_NTP_CLIENT()
{
    if [[ $(which ntpq) = "" ]];then
        echo "1"
    elif [[ $(grep "ntp.gfstack.geo" /etc/ntp.conf) = "" ]];then
        echo "2"
    else
        echo "0" && chkconfig ntpd on &>/dev/null
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
    if [[ $(rpm -qa|grep "jdk") = "" ]];then
        echo "1"
    elif [[ $(rpm -qa|grep "jdk"|grep "1.6.0_45") = "" ]];then
        echo "2"
    elif [ ! -z "$JAVA_HOME" ];then
        echo "3"
    else
        echo "0"
    fi
#function end
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


#=============
#role_function
#=============
#
#---------------------
#role_function_name_01
#---------------------
#note
function ROLE_FUNCTION_NAME_01()
{

#function end
}

#---------------------
#role_function_name_02
#---------------------
#note
function ROLE_FUNCTION_NAME_02()
{

#function end
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