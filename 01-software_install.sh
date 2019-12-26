#/bin/bash
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
