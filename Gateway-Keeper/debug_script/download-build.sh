#!/bin/bash

BUILD=$1
workDir=$(pwd)
echo "starting..."
if [[ $BUILD ]];then
	rm -rf ../build/*
	sudo wget -O $workDir/../build/$BUILD-field-factoryupdate.tar.gz https://code.wigwag.com/ugs/builds/development/cubietruck/$BUILD-field-factoryupdate.tar.gz --no-check-certificate
	echo "$workDir"
fi
