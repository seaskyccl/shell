#/bin/bash
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
for i in $(find . -name nginx.conf); do sed -i 's/user  nobody;/#user  nobody;/g' $i; done
chown -R producer.producer /data/nginx

echo "*******************nginx service start***********************"
su - producer -c "/data/nginx/sbin/nginx"
echo "*******************nginx  start succeed***********************"
