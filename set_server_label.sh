#!/bin/bash

chmod +x enterprise.sh

LIST=$(cat list.txt | grep -v "#" | tr " " "|")


echo
echo
echo "========================================="
echo "Set Server Label"
for line in $LIST
do
    component=$(echo $line | cut -d'|' -f1)
    label=$(echo $line | cut -d'|' -f6)
    INSTYPE="SE"
    if [ "$component" = "UF" ]; then
        INSTYPE="UF"
    fi
    sshpass -p "splk" ssh splunker@${LMIP} ./enterprise.sh "SETSERVERLABEL" $INSTYPE $label
done
echo "========================================="

