LIST=$(cat list.txt | grep -v "#" | tr " " "|")

for line in $LIST
do
    component=$(echo $line | cut -d'|' -f1)
    ip=$(echo $line | cut -d'|' -f2)
    INSTYPE="SE"
    if [ "$component" = "UF" ]; then
        INSTYPE="UF"
    fi

    if [ "$component" != "LM" ]; then
        scp enterprise.sh splunker@${ip}:/home/splunker
    fi

done





echo "========================================="
echo "Set server label"
for line in $LIST
do
    component=$(echo $line | cut -d'|' -f1)
    ip=$(echo $line | cut -d'|' -f2)
    olabel=$(echo $line | cut -d'|' -f6)
    INSTYPE="SE"
    if [ "$component" = "UF" ]; then
        INSTYPE="UF"
    fi

    if [ "$component" != "LM" ]; then
        sshpass -p "splk" ssh splunker@${ip} ./enterprise.sh "SETSERVERLABEL" $INSTYPE $olabel
        #echo "$label, IP: $ip"
    fi

done
echo "========================================="


echo "========================================="
echo "Show All Server Info"
for line in $LIST
do
    component=$(echo $line | cut -d'|' -f1)
    ip=$(echo $line | cut -d'|' -f2)
    INSTYPE="SE"
    if [ "$component" = "UF" ]; then
        INSTYPE="UF"
    fi

    if [ "$component" != "LM" ]; then
        #scp enterprise.sh splunker@${ip}:/home/splunker
        label=$(sshpass -p "splk" ssh splunker@${ip} ./enterprise.sh "LISTSERVERLABEL" $INSTYPE)
        echo "$label, IP: $ip"
    fi

done
echo "========================================="

