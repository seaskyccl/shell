#/bin/bash
echo "*************go install start*************"
cd /data/pkg/
wget http://01n16.com:1195/download/go/go1.13.3.linux-amd64.tar.gz
cp go1.13.3.linux-amd64.tar.gz /usr/local/
cd /usr/local/
tar -zxvf go1.13.3.linux-amd64.tar.gz
rm -rf go1.13.3.linux-amd64.tar.gz

sed -i '$a export PATH=$PATH:/usr/local/go/bin' /etc/profile

source /etc/profile
echo "*************go install end*************"
