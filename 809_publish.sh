#/bin/bash
Date=$(date +%Y-%m-%d)
Project_dir=/data/javaApp
App_Name=809
Target_dir=/opt/software/target

cp -r  ${Project_dir}/${App_Name}/current  ${Project_dir}/${App_Name}/bak_$Date
cd  ${Project_dir}/${App_Name}/current
echo "***************procedure stop begin*********************"
./stop.sh 
echo "***************procedure stop OK*********************"
rm -rf  *.jar && cp -r ${Target_dir}/*  ${Project_dir}/${App_Name}/current
rm -rf ${Target_dir}/* 
chown -R producer:producer  ${Project_dir}

echo "***************procedure start begin*********************"
su - producer -c "${Project_dir}/${App_Name}/current/start.sh"
echo "***************procedure start OK*********************"
