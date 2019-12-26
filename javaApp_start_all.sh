#/bin/bash
javaApp_dir=/data/javaApp

cd ${java_App}
echo "*******************java_App startup begin********************"
iot-hub/start.sh
809/start.sh
app/start.sh
hta/start.sh
rta/start.sh
web/start.sh

echo "*******************java_App startup finish********************"

