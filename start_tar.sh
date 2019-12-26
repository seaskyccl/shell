#!/bin/bash
yum -y install zip gzip

Project1_name=iot-hub
Project2_name=809
Project3_name=web
Project4_name=rta
Project5_name=app
Project6_name=hta
Project7_name=go-fastdfs
Project8_name=project

Tar_dir=/opt/tar
JavaApp_Tar_dir=/opt/tar/javaApp/produce
Fastdfs_Tar_dir=/opt/tar/fastdfs/produce
Project_Tar_dir=/opt/tar/project/produce
Project_dir=/data
Date=$(date +%Y-%m-%d) # 创建变量

echo "*************mkdir ${Tar_dir} start**************"

if [ -d "${Tar_dir}/{javaApp,fastdfs,project}/produce" ];then
    echo "the dir is exit" 
    else
   mkdir -p ${Tar_dir}/{javaApp,fastdfs,project}/produce
fi

echo "****************mkdir ${Tar_dir} end******************"

echo "***************tar  start*****************"

cd ${Project_dir}/javaApp/

tar --exclude=${Project1_name}/logs --exclude=${Project1_name}/bak --exclude=${Project1_name}/*.hprof --exclude=${Project1_name}/data --exclude=${Project1_name}/*.tar.gz --exclude=${Project1_name}/nohup.out --exclude=${Project1_name}/pid -cvzf ${Project1_name}_$Date.tar.gz ${Project1_name}
mv ${Project1_name}_$Date.tar.gz  ${JavaApp_Tar_dir}

tar --exclude=${Project2_name}/logs --exclude=${Project2_name}/bak --exclude=${Project2_name}/files --exclude=${Project2_name}/data --exclude=${Project2_name}/*.tar.gz --exclude=${Project2_name}/nohup.out --exclude=${Project2_name}/pid -cvzf ${Project2_name}_$Date.tar.gz ${Project2_name}
mv ${Project2_name}_$Date.tar.gz  ${JavaApp_Tar_dir}

tar --exclude=${Project3_name}/logs --exclude=${Project3_name}/bak --exclude=${Project3_name}/files --exclude=${Project3_name}/data --exclude=${Project3_name}/*.tar.gz --exclude=${Project3_name}/nohup.out --exclude=${Project3_name}/pid -cvzf ${Project3_name}_$Date.tar.gz ${Project3_name}
mv ${Project3_name}_$Date.tar.gz  ${JavaApp_Tar_dir}

tar --exclude=${Project4_name}/logs --exclude=${Project4_name}/bak --exclude=${Project4_name}/files --exclude=${Project4_name}/data --exclude=${Project4_name}/*.tar.gz --exclude=${Project4_name}/nohup.out --exclude=${Project4_name}/pid -cvzf ${Project4_name}_$Date.tar.gz ${Project4_name}
mv ${Project4_name}_$Date.tar.gz  ${JavaApp_Tar_dir}

tar --exclude=${Project5_name}/logs --exclude=${Project5_name}/bak --exclude=${Project5_name}/files --exclude=${Project5_name}/data --exclude=${Project5_name}/*.tar.gz --exclude=${Project5_name}/nohup.out --exclude=${Project5_name}/pid -cvzf ${Project5_name}_$Date.tar.gz ${Project5_name}
mv ${Project5_name}_$Date.tar.gz  ${JavaApp_Tar_dir}

tar --exclude=${Project6_name}/admin/logs --exclude=${Project6_name}/ana/logs  --exclude=${Project6_name}/ana/nohup.out --exclude=${Project6_name}/admin/nohup.out --exclude=${Project6_name}/admin/pid --exclude=${Project6_name}/ana/pid -cvzf ${Project6_name}_$Date.tar.gz  ${Project6_name}
mv ${Project6_name}_$Date.tar.gz  ${JavaApp_Tar_dir}

cd ${Project_dir}/
tar --exclude=${Project7_name}/logs --exclude=${Project7_name}/bak --exclude=${Project7_name}/files --exclude=${Project7_name}/data --exclude=${Project7_name}/*.tar.gz --exclude=${Project7_name}/nohup.out --exclude=${Project7_name}/pid -cvzf ${Project7_name}.tar.gz ${Project7_name}
mv ${Project7_name}.tar.gz  ${Fastdfs_Tar_dir}

tar --exclude=${Project8_name}/logs --exclude=${Project8_name}/bak --exclude=${Project8_name}/files --exclude=${Project8_name}/data --exclude=${Project8_name}/*.tar.gz --exclude=${Project8_name}/nohup.out --exclude=${Project8_name}/pid -cvzf ${Project8_name}_$Date.tar.gz ${Project8_name}
mv ${Project8_name}_$Date.tar.gz  ${Project_Tar_dir}

mysqldump -uroot -pRoot@123456 -B lingyi | gzip > /opt/tar/databases/produce/lingyi.sql.gz

echo "***************tar  end*****************"

echo "**************scp to console begin****************"
scp -r  ${Tar_dir}/* 192.168.1.21:/data/tomcat-ftp/webapps/download/01-software
echo "**************scp to console end****************"
