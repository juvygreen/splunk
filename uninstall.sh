#!/bin/bash

chmod +x uninstallrpm.sh

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

        if [ "$component" = "LM" ]; then
            sh uninstallrpm.sh
        else
            scp uninstallrpm.sh splunker@${ip}:/home/splunker
            sshpass -p "splk" ssh splunker@${ip} ./uninstallrpm.sh
        fi
done