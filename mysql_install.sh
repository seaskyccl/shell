#/bin/bash

echo "**************mysql install start***********"
#卸载系统自带的Mysql
/bin/rpm -e $(/bin/rpm -qa | grep mysql|xargs) --nodeps
/bin/rm -f /etc/my.cnf
#安装编译代码需要的包
/usr/bin/yum -y install gcc gcc-c++ gcc-g77 make cmake bison ncurses-devel autoconf automake zlib* fiex* libxml*  libmcrypt* libtool-ltdl-devel* libaio libaio-devel bzr libtool ncurses5-devel imake libxml2-devel expat-devel ncurses-dev
el perl openssl-devel  python-devel bzip2-devel
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

basedir = /data/mysql
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
