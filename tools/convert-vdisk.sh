#!/bin/bash
#
# Filename: convert-vdisk.sh
# Features: convert virtualization disk format,support: vmdk->qcow2 qcow2->vmdk qcow2->raw raw->qcow2
# Version: 0.1
# Buildtime: 20160913
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
# The global variable: _VARIABLE_NAME_
# The local variable: _VARIABLE_NAME
# The function: FUNCITON_NAME()
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
#--------
#os_check
#--------
#check system
function OS_CHECK()
{
    local _HNAME=$(uname -n)
    local _OSVERSION=$(cat /etc/redhat-release)
    local _USERID=$(id -u)
    local _SESTATUS=$(sestatus|grep "^Current mode"|awk '{print $3}')
    local _QEMU=$(which qemu-img)
    if [[ ${_SESTATUS} != "permissive" ]];then
        sed -i s/SELINUX=.*/SELINUX=permissive/g /etc/selinux/config
        setenforce 0
    fi
    echo -e "\e[32m ${_OSVERSION}\e[0m\e[32m]. \e[0m"
    if [[ ${_USERID} != "0" ]];then
        echo -e "\e[31m Please use [\e[31;1mroot\e[0m\e[31m] login.\e[0m" && exit
    fi
    echo -e "\e[32m My hostname is [\e[0m\e[36;4m${_HNAME}\e[0m\b\e[32m].\e[0m"
    if [[ ${_QEMU} = "" ]];then
        echo -e "\e[31m Please install [\e[31;1mqemu-img\e[0m\e[31m],run me again.\e[0m" && exit
    fi
    unset local _HNAME
    unset local _OSVERSION
    unset local _USERID
    unset local _SESTATUS
    unset local _QEMU
#function end
}


#=============
#role_function
#=============
#
#-------------
#convert_vdisk
#-------------
#convert vdisk format
function CONVERT_VDISK()
{
    echo -e "\e[33m Please upload vdisk file to convert folder.\n Press 'Enter' key continue.\e[0m"
    read -t 5
    mkdir -p {convert,$1}
    local _VDISK_NAME=$(ls -t convert|head -1)
    if [[ ${_VDISK_NAME} = "" ]];then
        echo -e "\e[31m Please upload vdisk file to convert folder.\e[0m" && exit
    else
        qemu-img info convert/${_VDISK_NAME}
    fi
    if [[ $(qemu-img info convert/${_VDISK_NAME}|grep "^file"|awk '{print $3}') = "$1" ]];then
        mv convert/${_VDISK_NAME} $1/
    else
        qemu-img convert -f $(qemu-img info convert/${_VDISK_NAME}|grep "^file"|awk '{print $3}') -O $1 convert/${_VDISK_NAME} $1/${_VDISK_NAME}.$1
        rm -rf convert/*
        echo -e "\e[32m Vdisk file in folder [\e[32;1m$1\e[0m\e[32m].\e[0m"
    fi
    unset local _VDISK_NAME
#function end
}


#====
#menu
#====
#menu
function MENU()
{
    local _INPUT="NULL"
    while true;
        do
            clear
            echo -e "\e[33m##############################\e[0m"
            echo -e "\e[33m System check begining......\e[0m"
            OS_CHECK
            echo -e "\e[33m System check finished.\e[0m"
            echo -e "\e[33m##############################\e[0m"
            echo -e "\e[34m==============================\e[0m"
            echo -e "\e[34;1m 0.Convert vdisk to qcow2\e[0m"
            echo -e "\e[34;1m 1.Convert vdisk to vmdk\e[0m"
            echo -e "\e[34;1m 2.Convert vdisk to raw\e[0m"
            echo -e "\e[34;1m x.Exit\e[0m"
            echo -e "\e[34m==============================\e[0m"
            read -p "Your choice is:" _INPUT
            case ${_INPUT} in
                0)
                    clear
                    echo "---------------------">>convert.log
                    echo "$(date +%Y%m%d%H%M%S)">>convert.log
                    echo "---------------------">>convert.log
                    CONVERT_VDISK qcow2|tee -a convert.log
                    echo -e "\e[31m Press 'Enter' key exit.\e[0m"
                    read
                    ;;
                1)
                    clear
					echo "---------------------">>convert.log
                    echo "$(date +%Y%m%d%H%M%S)">>convert.log
                    echo "---------------------">>convert.log
                    CONVERT_VDISK vmdk|tee -a convert.log
                    echo -e "\e[31m Press 'Enter' key exit.\e[0m"
                    read
                    ;;
                2)
                    clear
					echo "---------------------">>convert.log
                    echo "$(date +%Y%m%d%H%M%S)">>convert.log
                    echo "---------------------">>convert.log
                    CONVERT_VDISK raw|tee -a convert.log
                    echo -e "\e[31m Press 'Enter' key exit.\e[0m"
                    read
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
		unset local _INPUT
#funciton end
}
MENU

##########
#File end#
##########