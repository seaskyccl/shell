#/bin/bash
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
