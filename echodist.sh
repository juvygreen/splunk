#!/bin/bash

LMIP=""
# install sshpass if not installed - yum install sshpass
#echo "sudo yum install sshpass"

#keygen
#ssh-keygen -t rsa -P ""
#cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
#chmod 600 ~/.ssh/authorized_keys

#chmod +x enterprise.sh

LIST=$(cat list.txt | grep -v "#" | tr " " "|")

for line in $LIST
do
        component=$(echo $line | cut -d'|' -f1)
        ip=$(echo $line | cut -d'|' -f2)
        lmip=$(echo $line | cut -d'|' -f3)
        misc=$(echo $line | cut -d'|' -f4)
        port=$(echo $line | cut -d'|' -f5)
        label=$(echo $line | cut -d'|' -f6)
        cmrf=$(echo $line | cut -d'|' -f7)
        cmsf=$(echo $line | cut -d'|' -f8)
        cmsecret=$(echo $line | cut -d'|' -f9)

        sh echo.sh $component $ip $lmip $misc $port $label $cmrf $cmsf $cmsecret
done