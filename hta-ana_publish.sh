#/bin/bash
Date=$(date +%Y-%m-%d)
Project_dir=/data/javaApp
App_Name=hta
Target_dir=/opt/software/target

mkdir -p /opt/software/{target,script}

cp -r  ${Project_dir}/${App_Name}/ana/current  ${Project_dir}/${App_Name}/ana/bak_$Date
cd  ${Project_dir}/${App_Name}/ana/current
echo "***************procedure stop begin*********************"
./stop.sh 
echo "***************procedure stop OK*********************"
rm -rf  *.jar && rm -rf lib
cp -r ${Target_dir}/*  ${Project_dir}/${App_Name}/ana/current && mv dependency lib
rm -rf ${Target_dir}/* 
chown -R producer:producer  ${Project_dir}

echo "***************procedure start begin*********************"
su - producer -c "${Project_dir}/${App_Name}/ana/current/start.sh"
echo "***************procedure start OK*********************"
