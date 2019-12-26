#!/bin/bash
yum -y install vim bind-utils whois iftop iptraf-ng nethogs net-tools ntp tcpdump unzip bzip2 zip expect telnet lrzsz lsof bridge-utils lvm2
systemctl stop firewalld.service
systemctl disable firewalld.service
systemctl disable NetworkManager firewalld
\cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#curl -s https://download.docker.com/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
#yum -y install docker-ce docker-compose podman buildah skopeo
#systemctl enable docker

if [ $(free |awk '$1=="Swap:"{print $2}') -eq 0 ]; then
    swap=`echo "$(free -m |awk '$1=="Mem:"{print $2}')/485" |bc`
    dd if=/dev/zero of=/swapfile bs="$swap"M count=1024
    uuid=$(mkswap /swapfile |awk 'END{print $3}')
    chmod 0600 /swapfile
    swapon /swapfile
    echo "$uuid    swap    defaults        0 0" >>/etc/fstab
fi
if [ `ulimit -n` -eq 1024 ]; then
    echo -e "*          soft    nproc     512000\nroot       soft    nproc     unlimited" >/etc/security/limits.d/20-nproc.conf
    echo -e "*      -   nofile   1048576\n*      -   nproc    524288" >>/etc/security/limits.conf
    echo "kernel.pid_max=512000" >> /etc/sysctl.conf
    echo "fs.file-max=512000" >>/etc/sysctl.conf
    ulimit -n 1048576
    sysctl -p
fi

sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
selinux：setenforce 0
ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:" >>/root/hosts.txt
awk  '{print $1}' /root/hosts.txt >> /etc/hosts

sed -i 's/$/ producer/' /etc/hosts
hostname producer
echo -e "\n-----> *************init_sys end****************"
