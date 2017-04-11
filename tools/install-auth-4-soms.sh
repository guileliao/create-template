#!/bin/sh

CHECK_NET(){
	if [ "$(ping -w 3 ntp.gfstack.geo|grep "received"|awk -F ',' '{print $2}'|awk '{print $1}')" -gt "0" ];then
		echo "0.auth.gfstack.geo"
	elif [ "$(ping -w 3 ntp.devcenter.geo|grep "received"|awk -F ',' '{print $2}'|awk '{print $1}')" -gt "0" ];then
		echo "0.auth.devcenter.geo"
	else
		echo "1"
	fi
}

if [ "$(CHECK_NET)" == "1" ];then
	echo -e "\e[31mNetwork error.\e[0m" && exit 1
else
	rpm -ivh http://mirrors.gfstack.geo/GeoGlobe_repos/geoglobe_server/CodeMeter64-5.10.1239-502.x86_64.rpm && \
	service codemeter stop && \
	echo '[ServerSearchList\Server1]' >> /etc/wibu/CodeMeter/Server.ini && \
	echo 'Address=$(CHECK_NET)' >> /etc/wibu/CodeMeter/Server.ini && \
	service codemeter start && \
	echo -e "\e[1mWeb Access\e[0m\nUse browser to access the \e[32mhttp://serverIP:22350/\e[0m"
fi
