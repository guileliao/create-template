#!/bin/sh

function GET_DISK_TYPE(){
        local _DISK_TYPE="NULL"
        for _DISK_TYPE in "v" "s" "h" "xv"
        do
                if [ -e /dev/${_DISK_TYPE}da ];then
                        echo "${_DISK_TYPE}"
                        break
                fi
        done
        unset local _DISK_TYPE
}
#GET_DISK_TYPE

function GET_DISK_NAME(){
        local _PV_LIST=($(pvs|grep -v "PV"|awk '{print $1}'))
        local _DISK_LIST=($(find /dev -type b|grep "$(GET_DISK_TYPE)d[a-z]"|sort -bf))
        if [ "${_PV_LIST[$[${#_PV_LIST[@]}-1]]}" == "${_DISK_LIST[$[${#_DISK_LIST[@]}-1]]}" ];then
                echo "1"
        else
                echo  "${_DISK_LIST[$[${#_DISK_LIST[@]}-1]]}"
        fi
        unset local _PV_LIST
        unset local _DISK_LIST
}
#GET_DISK_NAME

function DISKEXT(){
        local _VGNAME=$(df -h $(grep "^datadir=" /etc/my.cnf|awk -F '=' '{print $2}')|grep -vi "filesystem"|grep "^/dev/"|awk '{print $1}'|awk -F '/' '{print $4}'|awk -F '-' '{print $1}')
        local _LVNAME=$(df -h $(grep "^datadir=" /etc/my.cnf|awk -F '=' '{print $2}')|grep -vi "filesystem"|grep "^/dev/"|awk '{print $1}'|awk -F '/' '{print $4}'|awk -F '-' '{print $2}')
        local _DISKNAME=$(GET_DISK_NAME)
        if [ "${_DISKNAME}" == "1" ];then
                echo -e "\e[31mNew disk was not found.\e[0m" && exit
        else
                pvcreate ${_DISKNAME} && \
                sleep 5 && \
                echo -e "\e[32mPV create success.\e[0m"
        fi
        if [ "$?" == "0" ];then
                vgextend ${_VGNAME} ${_DISKNAME} && \
                sleep 5 && \
                echo -e "\e[32mVG extension success.\e[0m"
        else
                echo -e "\e[31mPV create failure.\e[0m" && \
                exit
        fi
        if [ "$?" == "0" ];then
                lvextend -l +100%FREE /dev/${_VGNAME}/${_LVNAME} && \
                sleep 5 && \
                echo -e "\e[32mVG resize success.\e[0m"
        else
                echo -e "\e[31mVG extension failure.\e[0m" && \
                exit
        fi
        if [ "$?" == "0" ];then
                if [ -z "$(resize2fs /dev/${_VGNAME}/${_LVNAME}|grep "Nothing to do")" ];then
                        echo -e "\e[32mLV extension success.\e[0m"
                else
                        echo -e "\e[31mVG resize failure.\e[0m"
                fi
        else
                echo -e "\e[31mLV extension failure.\e[0m"
        fi
        unset local _VGNAME
        unset local _LVNAME
        unset local _DISKNAME
}
DISKEXT
