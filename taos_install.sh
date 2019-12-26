#/bin/bash
echo "***************taos install start**********************"
cd /usr/local/src
sudo sed -i ‘s/Defaults requiretty/#Defaults requiretty/g’ /etc/sudoers
wget http://01n16.com:1195/download/taos/ver-1.6.4.0.tar.gz
tar -zxvf ver-1.6.4.0.tar.gz
rm -rf ver-1.6.4.0.tar.gz
cd TDengine-ver-1.6.4.0
mkdir build
cd build
cmake .. && cmake --build .
make install
echo "***************taos install end**********************"
systemctl enable taosd.service
systemctl start taosd.service
echo "***************creat database/table start************"
taos -s "
CREATE DATABASE IF NOT EXISTS rawdata KEEP 1024;
use rawdata;
CREATE TABLE IF NOT EXISTS raws (ts timestamp, up bool, msg0 binary(500),msg1 binary(500),msg2 binary(500),msg3 binary(500),msg4 binary(500),msg5 binary(500),msg6 binary(500),msg7 binary(500)) TAGS(comm binary(16));"
echo "***************creat database/table end************"
mkdir -p  /data/taos/data
mkdir -p /data/taos/logs

echo "*******************alter taos.cfg start***************************"
echo "dataDir               /data/taos/data"   >>  /etc/taos/taos.cfg
echo "logDir                /data/taos/logs"   >>  /etc/taos/taos.cfg
echo "tables                4096           "   >>  /etc/taos/taos.cfg

systemctl restart taosd.service
echo "****************systemctl restart taosd.service end***********************"
