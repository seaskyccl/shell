#/bin/bash
Date=$(date +%Y-%m-%d)
Project_dir=/data/javaApp
App_Name=iot-hub
Target_dir=/opt/software/target

mkdir -p /opt/software/{target,script}

cp -r  ${Project_dir}/${App_Name}/current  ${Project_dir}/${App_Name}/bak_$Date
cd  ${Project_dir}/${App_Name}/current
echo "***************procedure stop begin*********************"
./stop.sh 
echo "***************procedure stop OK*********************"
rm -rf  *.jar && rm -rf lib
cp -r ${Target_dir}/*  ${Project_dir}/${App_Name}/current && mv dependency lib
rm -rf ${Target_dir}/* 
chown -R producer:producer  ${Project_dir}

echo "***************procedure start begin*********************"
su - producer -c "${Project_dir}/${App_Name}/current/start.sh"
echo "***************procedure start OK*********************"
