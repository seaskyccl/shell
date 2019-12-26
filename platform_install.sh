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

echo "*************mkdir ${pkg_dir} start**************"
pkg_dir=/data/pkg
if [ -d "${pkg_dir}" ];then
    echo "the dir is exit" 
    else
   mkdir -p ${pkg_dir}
fi
echo "****************mkdir ${pkg_dir} end******************"

echo "*************jdk install start*************"
cd /data/pkg/
wget http://01n16.com:1195/download/jdk/jdk-8u51-linux-x64.tar.gz
cp jdk-8u51-linux-x64.tar.gz /usr/local/
cd /usr/local/
tar -xzvf jdk-8u51-linux-x64.tar.gz
rm -rf jdk-8u51-linux-x64.tar.gz
sed -i '$a export JAVA_HOME=/usr/local/jdk1.8.0_51'  /etc/profile
sed -i '$a export JRE_HOME=${JAVA_HOME}/jre' /etc/profile
sed -i '$a export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib'  /etc/profile
sed -i '$a export PATH=${JAVA_HOME}/bin:$PATH' /etc/profile
sudo update-alternatives --install /usr/bin/java java /usr/local/jdk1.8.0_51/bin/java 300
sudo update-alternatives --install /usr/bin/javac javac /usr/local/jdk1.8.0_51/bin/javac 300
source /etc/profile
echo "**************jdk install end***************"

echo "**************agent install begin***********"
cd /usr/local/
wget http://01n16.com:1195/download/devops/agent-2.4.6-release.tar.gz
tar zxvf agent-2.4.6-release.tar.gz
rm -rf agent-2.4.6-release.tar.gz
cd agent-2.4.6-release
chmod +x *.sh
su - root -c "nohup sh /usr/local/agent-2.4.6-release/Agent.sh 2>&1 &"
echo "**************agent install end***********"

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

echo "**************mysql install start***********"
#卸载系统自带的Mysql
/bin/rpm -e $(/bin/rpm -qa | grep mysql|xargs) --nodeps
/bin/rm -f /etc/my.cnf
#安装编译代码需要的包
/usr/bin/yum -y install gcc gcc-c++ gcc-g77 make cmake bison ncurses-devel autoconf automake zlib* fiex* libxml*  libmcrypt* libtool-ltdl-devel* libaio libaio-devel bzr libtool ncurses5-devel imake libxml2-devel expat-devel ncurses-devel perl openssl-devel  python-devel bzip2-devel
#安装依赖包
cd /usr/local/src
wget http://01n16.com:1195/download/mysql/boost_1_59_0.tar.gz
/bin/tar -zxvf boost_1_59_0.tar.gz
cd boost_1_59_0 && ./bootstrap.sh && ./b2 && ./b2 install
rm -rf boost_1_59_0.tar.gz
cd /usr/local/src
wget  http://01n16.com:1195/download/mysql/cmake-3.8.1.tar.gz
/bin/tar -zxvf cmake-3.8.1.tar.gz
cd cmake-3.8.0 && ./bootstrap && gmake -j 4 && gmake install
rm -rf cmake-3.8.1.tar.gz
#编译安装mysql5.7
/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql -M -s /sbin/nologin
mkdir -p /data/mysql/data
chown -R mysql:mysql /data/mysql
cd /usr/local/src
wget -c http://ftp.ntu.edu.tw/MySQL/Downloads/MySQL-5.7/mysql-5.7.25.tar.gz
/bin/tar -zxvf mysql-5.7.25.tar.gz
rm -rf mysql-5.7.25.tar.gz
cd   mysql-5.7.25

cmake -DCMAKE_INSTALL_PREFIX=/data/mysql \
-DMYSQL_DATADIR=/data/mysql/data \
-DSYSCONFDIR=/etc \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DMYSQL_UNIX_ADDR=/data/mysql/mysql.sock \
-DMYSQL_TCP_PORT=3306 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci  \
-DWITH_BOOST=/usr/local/src/boost_1_59_0 \
-DWITH_SSL=yes 
make && make install

#修改/data/mysql权限
/bin/chown -R mysql:mysql /data/mysql
#执行初始化配置脚本，创建系统自带的数据库和表
cd /data/mysql
bin/mysqld --initialize-insecure --user=mysql --explicit_defaults_for_timestamp --datadir=/data/mysql/data --basedir=/data/mysql --socket=/mysql/mysql/mysql.sock
#配置my.cnf
cat > /data/mysql/my.cnf << EOF
[client]
port = 3306
socket = /data/mysql/mysql.sock

[mysqld]
port = 3306
socket = /data/mysql/mysql.sock

basedir = /data/mysql/
datadir = /data/mysql/data
pid-file = /data/mysql/data/mysql.pid
user = mysql
bind-address = 0.0.0.0
server-id = 1
sync_binlog=1
log_bin = mysql-bin

skip-name-resolve
#skip-networking
back_log = 600

max_connections = 3000
max_connect_errors = 3000
##open_files_limit = 65535
table_open_cache = 512
max_allowed_packet = 16M
binlog_cache_size = 16M
max_heap_table_size = 16M
tmp_table_size = 256M

read_buffer_size = 1024M
read_rnd_buffer_size = 1024M
sort_buffer_size = 1024M
join_buffer_size = 1024M
key_buffer_size = 8192M

thread_cache_size = 8

query_cache_size = 512M
query_cache_limit = 1024M

ft_min_word_len = 4

binlog_format = mixed
expire_logs_days = 30

log_error = /data/mysql/data/mysql-error.log
slow_query_log = 1
long_query_time = 1
slow_query_log_file = /data/mysql/data/mysql-slow.log

performance_schema = 0
explicit_defaults_for_timestamp

lower_case_table_names = 1

skip-external-locking
default_storage_engine = InnoDB
##default-storage-engine = MyISAM
innodb_file_per_table = 1
innodb_open_files = 500
innodb_buffer_pool_size = 4096M
innodb_write_io_threads = 1000
innodb_read_io_threads = 1000
innodb_thread_concurrency = 8
innodb_purge_threads = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 4M
innodb_log_file_size = 32M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120

bulk_insert_buffer_size = 8M
myisam_sort_buffer_size = 8M
myisam_max_sort_file_size = 2G
myisam_repair_threads = 1

interactive_timeout = 28800
wait_timeout = 28800

[mysqldump]
quick
max_allowed_packet = 16M

[myisamchk]
key_buffer_size = 8M
sort_buffer_size = 8M
read_buffer = 4M
write_buffer = 4M

sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
port = 3306
EOF

rm -rf /etc/my.cnf
cp -r /data/mysql/my.cnf /etc/my.cnf
cd /data/mysql
cp -a support-files/mysql.server /etc/init.d/mysql
/sbin/chkconfig mysql on

echo "****************service mysql start*******************"
#启动mysql服务
service mysql start
echo "****************service mysql start end*******************"
#wait for mysqld
while :
do
    /data/mysql/support-files/mysql.server status | grep SUCCESS && break
    sleep 1
done

#设置环境变量
#echo "export PATH=$PATH:/data/mysql/bin" >> /etc/profile
sed -i '$a export PATH=$PATH:/data/mysql/bin'  /etc/profile
source /etc/profile
# 配置远程访问权限,置mysql登陆密码,初始密码为Root@123456
cat > init_root.sql << EOF
delete from mysql.user where host='localhost' and user='root';
grant all on *.* to 'root'@'%' identified by 'Root@123456' WITH GRANT OPTION;
CREATE USER 'hta'@'%' IDENTIFIED BY 'Hta@123456';
CREATE USER 'rta'@'%' IDENTIFIED BY 'Rta@123456';
CREATE USER 'web'@'%' IDENTIFIED BY 'Web@123456';
CREATE USER 'iot'@'%' IDENTIFIED BY 'Stydm@123456';
CREATE USER 'app'@'%' IDENTIFIED BY 'App@123456';
CREATE USER 'saver'@'%' IDENTIFIED BY 'Saver@123456';
CREATE USER 'transfer'@'%' IDENTIFIED BY 'Transfer@123456';
CREATE USER 'dev'@'%' IDENTIFIED BY 'Dev@lingyi';

GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'Root@123456' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'dev'@'%' IDENTIFIED BY 'Dev@lingyi' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'hta'@'%' IDENTIFIED BY 'Hta@123456' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'rta'@'%' IDENTIFIED BY 'Rta@123456' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'web'@'%' IDENTIFIED BY 'Web@123456' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'iot'@'%' IDENTIFIED BY 'Stydm@123456' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'app'@'%' IDENTIFIED BY 'App@123456' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'saver'@'%' IDENTIFIED BY 'Saver@123456' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'transfer'@'%' IDENTIFIED BY 'Transfer@123456' WITH GRANT OPTION;
flush privileges;
EOF
bin/mysql -u root --skip-password < init_root.sql
rm init_root.sql

cat /etc/passwd |grep mysql |awk -F ':' '{print $7}'|xargs  sed -i 's\/sbin/nologin\/bin/bash\g' /etc/passwd
echo "****************mysql creat databases start*******************"
#创建通用基础数据库
mysql -pRoot@123456 -e "
create database if not exists lingyi
default character set gbk
default collate gbk_chinese_ci;
"
echo "****************mysql  creat databases lingyi end*******************"
echo "****************mysql creat databases start*******************"
#创建报警数据库
mysql -pRoot@123456 -e "
create database if not exists alarm
default character set gbk
default collate gbk_chinese_ci;
"
echo "****************mysql  creat databases alarm end*******************"
echo "****************mysql creat databases start*******************"
#创建司机数据库
mysql -pRoot@123456 -e "
create database if not exists driver
default character set gbk
default collate gbk_chinese_ci;
"
echo "****************mysql  creat databases driver end*******************"
echo "****************mysql creat databases start*******************"
#创建视频数据库
mysql -pRoot@123456 -e "
create database if not exists media
default character set gbk
default collate gbk_chinese_ci;
"
echo "****************mysql  creat databases media end*******************"
echo "****************mysql creat databases start*******************"
#创建报表数据库
mysql -pRoot@123456 -e "
create database if not exists report
default character set gbk
default collate gbk_chinese_ci;
"
echo "****************mysql  creat databases report end*******************"
echo "****************mysql creat databases start*******************"
#创建轨迹数据库
mysql -pRoot@123456 -e "
create database if not exists track
default character set gbk
default collate gbk_chinese_ci;
"
echo "****************mysql  creat databases track end*******************"
echo "****************mysql creat databases start*******************"
#创建hta分析数据库
mysql -pRoot@123456 -e "
create database if not exists xxl_job
default character set gbk
default collate gbk_chinese_ci;
"
echo "****************mysql  creat databases xxl_job end*******************"
yum -y install zip gzip
cd /usr/local
wget http://01n16.com:1195/download/01-software/databases/produce/lingyi.sql.gz
gzip -dv lingyi.sql.gz
mysql -uroot -pRoot@123456 < /usr/local/lingyi.sql
echo "****************mysql install end*************************"

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

echo "******************nginx install satrt**************************"
yum install -y wget nslookup gcc gcc-c++ zlib-devel gtk2-devel zip libart_lgpl-devel libXtst-devel bzip2-devel python-devel zlib openssl openssl-devel pcre pcre-devel mysql-devel
/usr/sbin/groupadd producer
/usr/sbin/useradd -g producer producer -M -s /bin/bash
mkdir -p /home/producer
chown -R producer.producer /home/producer
echo "********************package download start******************************"
cd /data/pkg
wget -c -r -nd -np -k c,h http://01n16.com:1195/download/nginx/flash/
for tar in *.tar.gz;  do tar xvf $tar; done
rm -rf *.tar.gz
unzip hiredispool-master.zip
rm -rf hiredispool-master.zip

echo "********************package download end******************************"
cd /data/pkg/hiredispool-master
make && make install

cd /data/pkg/yasm-1.3.0
./configure
make && make install
 
cd /data/pkg/lame-3.100
./configure
make && make install 

cd /data/pkg/x264
./configure --enable-shared --disable-asm
make && make install

cd /data/pkg/ffmpeg-3.4.2
./configure --enable-shared --enable-libmp3lame --enable-libx264  --enable-gpl
make && make install 
cat <<EOF>> /etc/ld.so.conf
/usr/local/lib
/usr/local/lib64
EOF
ldconfig

echo "-----------------------------------downloading nginx-------------------------------"
mkdir -p /data/nginx
mkdir -p /data/upload
cd /data/pkg
wget http://01n16.com:1195/download/nginx/nginx-1.16.1.tar.gz
wget http://01n16.com:1195/download/nginx/nginx-rtmp-module-1.2.1.tar.gz
tar -xvf nginx-1.16.1.tar.gz && tar -zxvf nginx-rtmp-module-1.2.1.tar.gz
rm -rf nginx-1.16.1.tar.gz && rm -rf nginx-rtmp-module-1.2.1.tar.gz
cd nginx-1.16.1
echo "------------------------------------configuring nginx,plz wait----------------------"
./configure --add-module=../nginx-rtmp-module-1.2.1  --prefix=/data/nginx

if [ $? -ne 0 ];then
echo "configure failed ,please check it out!"
else
echo "make nginx, please wait for 20 minutes"
make
fi

if [ $? -ne 0 ];then
echo "make failed ,please check it out!"
else
echo "install nginx, please wait for a minutes"
make install
fi
echo "******************nginx install end**************************"

cd /data/nginx/conf
mv nginx.conf nginx.conf_bak
wget http://01n16.com:1195/download/nginx/nginx.conf
sed -i '$d' /data/nginx/conf/nginx.conf
cat <<EOF>>  nginx.conf

    server {
        listen       18005;

        location / {
            root  /data/project/html/dist;
            index  index.html index.htm;
            try_files $uri $uri/ /index.html;
            add_header 'Access-Control-Allow-Origin' '*';
                  add_header 'Access-Control-Allow-Credentials' 'true';
                  add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
                  add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
              }
        location ^~/api/ {
            proxy_pass  http://outip:18004/;
        }
        location ^~/pic/ {
            proxy_pass  http://outip:18002/;
        }
    }
}
EOF

ip_dir=/data/pkg/ip.txt
conf_dir=/data/nginx/conf/nginx.conf
curl icanhazip.com >> /data/pkg/ip.txt
ip=`cat ${ip_dir}`
conf=`cat ${conf_dir} |grep outip|awk -F '//' '{print $2}'|awk -F':' '{print $1}'|uniq`
sed -i "s/$conf/$ip/g" ${conf_dir}
rm -rf ${ip_dir}
#for i in $(find . -name nginx.conf); do sed -i 's/user  nobody;/#user  nobody;/g' $i; done
chown -R producer.producer /data/nginx
#echo "*******************nginx service start***********************"
#/data/nginx/sbin/nginx
#echo "*******************nginx  start succeed***********************"

echo "****************redis install start*****************"
cd /data/
wget http://01n16.com:1195/download/redis/redis.tar.gz
tar -zxvf redis.tar.gz
rm -rf redis.tar.gz
#cd /data/redis/
#nohup sh /data/redis/run-18003.sh 2>&1 &
#wait
echo "****************redis install  end******************"

echo "****************variable dir define start*****************"
software_dir=/data
javaApp_dir=/data/javaApp
echo "****************variable dir define end*****************"

echo "*************mkdir ${javaApp_dir} start**************"

if [ -d "${javaApp_dir}" ];then
    echo "the dir is exit"
    else
   mkdir -p ${javaApp_dir}
fi

echo "****************mkdir ${javaApp_dir} end******************"
mkdir -p  /data/hub-data
mkdir -p /data/updata
cd /data
wget -c -r -nd -np -k c,h http://01n16.com:1195/download/01-software/project/produce/
tar zxvf *.tar.gz
rm -rf *.tar.gz

wget  -c -r -nd -np -k c,h http://01n16.com:1195/download/01-software/fastdfs/produce/go-fastdfs.tar.gz
tar zxvf go-fastdfs.tar.gz
rm -rf go-fastdfs.tar.gz

cd ${javaApp_dir}
wget -c -r -nd -np -k c,h http://01n16.com:1195/download/01-software/javaApp/produce/
for tar in *.tar.gz;  do tar xvf $tar; done
rm -rf *.tar.gz
cd ../

echo "****************alter deploy  start******************"
#intranet_ip=`cat ${javaApp_dir}/hosts.txt`
#ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:" >>${javaApp_dir}/hosts.txt
for i in $(find . -name *.yml); do sed -i "s/192.168.1.8/127.0.0.1/g" $i; done
for i in $(find . -name *.yml); do sed -i "s/183.6.43.132/127.0.0.1/g" $i; done
for i in $(find . -name *.yml); do sed -i "s/192.168.1.3/127.0.0.1/g" $i; done
for i in $(find . -name *.yml); do sed -i "s/18001/18003/g" $i; done
for i in $(find . -name *.properties); do sed -i "s/192.168.1.8/127.0.0.1/g" $i; done
for i in $(find . -name *.properties); do sed -i "s/183.6.43.132/127.0.0.1/g" $i; done
for i in $(find . -name *.properties); do sed -i "s/192.168.1.3/127.0.0.1/g" $i; done
for i in $(find . -name *.properties); do sed -i "s/18001/18003/g" $i; done
for i in $(find . -name cfg.json); do sed -i "s/":18029"/":18002"/g" $i; done
for i in $(find . -name *.yml); do sed -i "s/18028/18000/g" $i; done
for i in $(find . -name *.yml); do sed -i "s/6667/18010/g" $i; done
echo "****************alter deploy  end******************"

echo "****************alter deploy permission start******************"
chown -R producer:producer /data/javaApp
chown -R producer:producer /data/project
chown -R producer:producer /data/redis
chown -R producer:producer /data/nginx
chown -R producer:producer /data/updata
chown -R producer:producer /data/pkg
chown -R producer:producer /data/hub-data
echo "****************alter deploy permission end******************"

echo "**************** service start begin******************"

echo "*******************nginx service start***********************"
su - producer -c "/data/nginx/sbin/nginx"
echo "*******************nginx  start succeed***********************"

echo "*******************redis service start***********************"
su - producer -c "nohup sh /data/redis/run-18003.sh 2>&1 &"
wait
echo "*******************redis  start end***********************"
su - producer -c "/data/go-fastdfs/stop.sh"
su - producer -c "/data/javaApp/809/stop.sh"
su - producer -c "/data/javaApp/app/stop.sh"
su - producer -c "/data/javaApp/hta//admin/stop.sh"
su - producer -c "/data/javaApp/hta/ana/stop.sh"
su - producer -c "/data/javaApp/iot-hub/stop.sh"
su - producer -c "/data/javaApp/rta/stop.sh"
su - producer -c "/data/javaApp/web/stop.sh"

su - producer -c "/data/go-fastdfs/start.sh"
su - producer -c "/data/javaApp/809/start.sh"
su - producer -c "/data/javaApp/app/start.sh"
su - producer -c "/data/javaApp/hta//admin/start.sh"
su - producer -c "/data/javaApp/hta/ana/start.sh"
su - producer -c "/data/javaApp/iot-hub/start.sh"
su - producer -c "/data/javaApp/rta/start.sh"
su - producer -c "/data/javaApp/web/start.sh"

echo "**************** service  start end ******************"

echo "*****************publish files begin***********************"
Target_dir=/opt/software/target
Script_dir=/opt/software/script
mkdir -p /opt/software/{target,script}
cd ${Script_dir}
wget -c -r -nd -np -k c,h http://01n16.com:1195/download/shell/java_publish/publish_script/
chmod +x *.sh
gzexe *.sh && rm -rf *.sh~
echo "*****************publish files end***********************"
