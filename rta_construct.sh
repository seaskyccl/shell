#!/bin/bash
## 必填：不能为空，要与上面的项目名一致
AppName=rta

# 必填：不能为空，填程序的部署路径，如：/u06/ecpm/service/cmds
DeployDir=/data/javaApp/$AppName

# 默认为 false。true 则开启
Link=true

# 默认为 false，只打主程序工程包，
# true 则全量包，就是连依赖包都打包，如dependencies目录
FullBuild=true

#if [ -z ${AppName} ] || [ -z ${DeployDir} ] || [ -z ${Link} ] || [ -z ${FullBuild} ] ;then
#	echo "ERROR: Args must be not null!Please input something ......"
#	exit 1
#fi
Date=`date '+%Y%m%d'`

AppDeployDir=${DeployDir}/${Date}
project_dir="/jpom/server-2.4.6-release/data/build/10d15dc8bc5345e2af0a9880314bff31/source/"
target_dir="/jpom/server-2.4.6-release/data/build/10d15dc8bc5345e2af0a9880314bff31/source/target/"
mvn_dir="/opt/maven/apache-maven-3.6.3/bin/mvn"
dest_dir="/opt/jp/workspace/source/"

mvnBuild(){
	echo "*************ready build ${AppName} project*************"

	${mvn_dir} -version
	if ${mvn_dir} -f ${project_dir}"pom.xml" clean package;
	then
	        mkdir -p /jpom/server-2.4.6-release/data/build/10d15dc8bc5345e2af0a9880314bff31/source/target
                cd ${target_dir}
                Other_Dir=`ls | grep  -v *.jar`
                rm -rf ${Other_Dir}
	        echo "*************build package complete**************"
	else
    	echo "*************build package fail**************"
    	exit 1
	fi
}

mvnDependencies(){
	if ${mvn_dir} -f ${project_dir}"pom.xml" dependency:copy-dependencies;
	then
    	echo "*************build dependencies complete**************"
	else
    	echo "*************build dependencies fail**************"
   		exit 1
	fi
	FullBuild
}

FullBuild(){
	cp -r ${target_dir}dependency ${dest_dir}
}

case ${FullBuild} in
	false | FALSE) 
	mvnBuild
	;;
	true | TRUE)
	mvnBuild
        cd ${target_dir}
        Other_Dir=`ls | grep  -v *.jar`
        rm -rf ${Other_Dir}
	mvnDependencies
	;;
	*)
   	echo $"Usage: FullBuild's args is false or true."
    exit 1
esac	
		
echo "-------------------------------  script run sucess!!!  -------------------------------------"

