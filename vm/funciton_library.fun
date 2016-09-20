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
#
#================
#operating_system
#================
#
#------------
#check_os_ver
#------------
#judge system version
function CHECK_OS_VER()
{
    if [[ "$(cat /etc/system-release-cpe |awk -F ':' '{print $4$5}')" = "linux6" ]];then
        echo "centos6"
    elif [[ "$(cat /etc/system-release-cpe |awk -F ':' '{print $4$5}')" = "centos7" ]];then
        echo "centos7"
    elif [[ "$(cat /etc/system-release-cpe |awk -F ':' '{print $4}')" = "fedora" ]];then
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

#--------------
#check_nic_name
#--------------
#get nic name
function CHECK_NIC_NAME()
{
    if [[ "$(CHECK_OS_VER)" = "centos6" ]];then
        echo "eth0"
    elif [[ "$(CHECK_OS_VER)" = "centos7" ]];then
        echo "$(ip addr|grep "^2"|awk -F ": " '{print $2}')"
    else
        echo "error" 
    fi
#funciton end
}


#===============
#system_software
#===============
#
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

#----------------
#check_ntp_server
#----------------
#check ntpd service status
#code "0"=ntp service is OK.
#code "1"=Package 'ntp' has been not installed.
function CHECK_NTP_SERVER()
{
    if [ -z "$(which ntpq)" ];then
        echo "1"
    else
        echo "0" && chkconfig --level 345 ntpd on &>/dev/null
    fi
#funciton end
}

#-----------------
#check_dns_service
#-----------------
#check ntpd service status
#code "0"=ntp service is OK.
#code "1"=Package 'ntp' has been not installed.
#code "2"=ntp server address has not set.
function CHECK_DNS_SERVICE()
{
    if [ -z "$(which dnsmasq)" ];then
        echo "1"
    else
        echo "0" && chkconfig --level 345 dnsmasq on &>/dev/null
    fi
#funciton end
}

#-----------
#check_httpd
#-----------
#check httpd service status
#code "0"=httpd service is OK.
#code "1"=Package 'httpd' has been not installed.
function CHECK_HTTPD()
{
    if [ -z "$(which httpd)" ];then
        echo "1"
    else
        echo "0" && chkconfig --level 345 httpd on &>/dev/null
        mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.old &>/dev/null
        service httpd restart &>/dev/null
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


#===============
#java_middleware
#===============
#
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
    if [ -z "$(rpm -qa|grep "tomcat6-admin-webapps")" ];then
        echo "1"
        rm /var/log/tomcat6/* -rf
        rm /usr/share/tomcat6/temp/* -rf
        rm /usr/share/tomcat6/work/* -rf
        chkconfig --level 345 tomcat6 on
    fi
#function end
}


#========
#database
#========
#
#-----------
#check_mysql
#-----------
#clean mysql log file
#code "0"=MySQL-Server is OK.
#code "1"=MySQL-Server has been not installed.
function CHECK_MYSQL()
{
    if [ -n "$(which mysql)" ];then
        echo "0" && chkconfig --level 345 mysqld on
        :>/var/log/mysqld.log
        :>/var/lib/mysql/auto.cnf
    else
        echo "1"
    fi
#function end
}


#========
#geostack
#========
#
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
#code "1"=Option [Server] error on '/etc/zabbix/zabbix_agentd.conf'.
#code "2"=Option [ListenPort] error on '/etc/zabbix/zabbix_agentd.conf'.
#code "3"=Option [ListenIP] error on '/etc/zabbix/zabbix_agentd.conf'.
#code "4"=Option [ServerActive] error on '/etc/zabbix/zabbix_agentd.conf'.
#code "5"=Option [Hostname] error on '/etc/zabbix/zabbix_agentd.conf'.
#code "100"=zabbix_agent has been not installed.
function CHECK_ZABBIX_AGENT()
{
    local _ARRAY=(
    'Server=monsrv.gfstack.geo'
    'ListenPort=10050'
    'ListenIP=0.0.0.0'
    'ServerActive=monsrv.gfstack.geo'
    'Hostname=Zabbix server'
    )
    local _NUM=0
    for ((i=0;i<${#_ARRAY[@]};i++));
        do
            if [ -n "$(grep "${_ARRAY[i]}" /etc/zabbix/zabbix_agentd.conf)" ];then
                local _NUM=$((${_NUM}+1))
#                echo "option [$(echo "${_ARRAY[$((${_NUM}-1))]}"|awk -F '=' '{print $1}')] set the correct"
            else
#                echo "option [$(echo "${_ARRAY[${_NUM}]}"|awk -F '=' '{print $1}')] set the error"
                break
            fi
        done
    if [ -z "$(which zabbix_agent)" ];then
        echo "100"
    elif [ ${_NUM} != "5" ];then
        echo "$((${_NUM}+1))"
    else
        echo "0"
    fi
    unset local _ARRAY
    unset local _NUM
#function end
}


#========
#geoglobe
#========
#