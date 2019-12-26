#/bin/bash
javaApp_dir=/data/javaApp

cd ${java_App}
echo "*******************java_App stop begin********************"
iot-hub/stop.sh 
809/stop.sh
app/stop.sh
hta/stop.sh
rta/stop.sh
web/stop.sh

echo "*******************java_App stop finish********************"
