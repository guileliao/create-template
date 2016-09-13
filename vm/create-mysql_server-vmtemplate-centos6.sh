#!/bin/sh

chkconfig --level 2345 iptables off
chkconfig --level 2345 ip6tables off
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config

rpm -Uvh http://mirrors.aliyun.com/epel/epel-release-latest-6.noarch.rpm
yum update -y
yum install mysql-server autofs wget vsftpd -y
chkconfig --level 345 vsftpd on
chkconfig --level 345 autofs on
chkconfig --level 345 mysqld on
sed -i s/root/#root/g /etc/vsftpd/ftpusers
sed -i s/root/#root/g /etc/vsftpd/user_list
sed -i s/+auto.master/#+auto.master/g /etc/auto.master
echo "vdb1            -fstype=ext4,rw         :/dev/vdb1      --timeout=0" >> /etc/auto.misc
echo "vdc1            -fstype=ext4,rw         :/dev/vdc1      --timeout=0" >> /etc/auto.misc
echo "vdd1            -fstype=ext4,rw         :/dev/vdd1      --timeout=0" >> /etc/auto.misc
echo "vde1            -fstype=ext4,rw         :/dev/vde1      --timeout=0" >> /etc/auto.misc

mysqladmin -uroot password "123456"
mysql -uroot -p123456 -e "grant all privileges on *.* to 'root'@'%' identified by '123456' with grant option;"

curl http://192.168.230.40/vmtemplate/cloud-set-guest-password.in -o /etc/rc.d/init.d/cloud-set-guest-password
chmod +x /etc/rc.d/init.d/cloud-set-guest-password
chkconfig --level 345 cloud-set-guest-password on
passwd --expire root

echo "DEVICE=eth0" > /etc/sysconfig/network-scripts/ifcfg-eth0
echo "TYPE=Ethernet" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "BOOTPROTO=dhcp" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth0
hostname localhost
echo "localhost" > /etc/hostname

rm -f /etc/udev/rules.d/70*
rm -f /var/lib/dhclient/*
rm -f /etc/ssh/*key*
cat /dev/null > /var/log/audit/audit.log 2>/dev/null
cat /dev/null > /var/log/wtmp 2>/dev/null
logrotate -f /etc/logrotate.conf 2>/dev/null
rm -f /var/log/*-* /var/log/*.gz 2>/dev/null
yum clean all
unset HISTFILE
history -c
poweroff


