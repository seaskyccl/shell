# !/bin/bash
# author : hobby
# Zabbix-agent  one-click installation script

# Turn off the firewalld
systemctl stop firewalld

# Turn off the firewalld and start automatically
systemctl disable firewalld

# Temporarily turn off selinux
setenforce 0

# Set selinux off permanently
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# Install zabbix source, aliyun YUM source, zabbix source
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
rpm -Uvh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
 

# Install zabbix and related services
yum install zabbix-agent -y
sed -i 's#Server=127.0.0.1#Server=192.168.1.21#' /etc/zabbix/zabbix_agentd.conf
systemctl start  zabbix-agent
# Write boot start.
chmod +x /etc/rc.d/rc.local
cat >>/etc/rc.d/rc.local<<EOF
systemctl start  zabbix-agent
EOF
