#!/bin/bash

set -e
set -u

_targetDBName_="operationcenter"
_targetTableName_="monitor_log"
_dbUser_="root"
_dbPasswd_="123456"
#_dbHost_=""

#============
#check mysqld
#============
#return=0 mysqld running
#return=1 mysqld stopped
#
function CHECKMYSQLD(){
	if [ -n "$(ps aux|grep "mysqld"|grep -v "grep")" ];then
		echo "0"
	else
		echo "1"
	fi
}
#function end
#CHECKMYSQLD

#===============
#check target DB
#===============
#return=0 Target DB already exists
#return=1 Target DB does not exist
#
function CHECKDBNAME(){
	if [ "$(CHECKMYSQLD)" == "0" ];then
		if [ -n "$(mysql -u${_dbUser_} -p${_dbPasswd_} -e"show databases;" 2>/dev/null|grep "${_targetDBName_}")" ];then
			echo "0"
		else
			echo "1"
		fi
	fi
}
#function end
#CHECKDBNAME

#==================
#check target table
#==================
#return=0 Target table already exists
#return=1 Target table does not exist
#
function CHECKTABLENAME(){
        if [ "$(CHECKDBNAME)" == "0" ];then
		if [ -n "$(mysql -u${_dbUser_} -p${_dbPasswd_} -D"${_targetDBName_}" -e"show tables;" 2>/dev/null|grep "${_targetTableName_}")" ];then
                	echo "0"
        	else
                	echo "1"
        	fi
	fi
}
#function end
#CHECKTABLENAME

#=============
#count records
#=============
#
function CONNTRECORDS(){
	if [ "$(CHECKTABLENAME)" == "0" ];then
		echo "$(mysql -u${_dbUser_} -p${_dbPasswd_} -D"${_targetDBName_}" -e"select count(*) from ${_targetTableName_};" 2>/dev/null|grep -v "-"|grep -v "count")"
	fi
}
#function end
#CONNTRECORDS

#===========
#clear table
#===========
#
function CLEARTABLE(){
	while true
		do
			if [ ! -n "$(CONNTRECORDS)" ];then
				continue
			elif  [ "$(CONNTRECORDS)" -gt "10" ];then
				mysql -u${_dbUser_} -p${_dbPasswd_} -D"${_targetDBName_}" -e"delete from monitor_log limit $[$(CONNTRECORDS)-1000];" 2>/dev/null
			fi
			sleep 3600
		done
}
#function end
CLEARTABLE
