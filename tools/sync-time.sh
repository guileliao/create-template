#!/bin/sh

CHECK_NTP(){
	if [ ! -n "$(rpm -qa|grep "ntp")" ];then
		echo -e "\e[31mNTP has not installed.\e[0m" && exit 1
	fi
}

CHECK_NET(){
	if [ "$(ping -w 3 ntp.gfstack.geo|grep "received"|awk -F ',' '{print $2}'|awk '{print $1}')" -gt "0" ];then
		echo "ntp.gfstack.geo"
	elif [ "$(ping -w 3 ntp.devcenter.geo|grep "received"|awk -F ',' '{print $2}'|awk '{print $1}')" -gt "0" ];then
		echo "ntp.devcenter.geo"
	else
		echo "1"
	fi
}

SYNC_TIME(){
	if [ "$(CHECK_NET)" == "1" ];then
		echo -e "\e[31mNetwork error.\e[0m" && exit 1
	else
		service ntpd stop && \
		ntpdate $(CHECK_NET) && \
		chkconfig ntpd on && \
		service ntpd start && \
		echo -e "System Time:\t\e[32m$(date)\e[0m"
	fi
}

CHECK_NTP
SYNC_TIME
