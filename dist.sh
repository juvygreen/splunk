#!/bin/bash

start_time="$(date -u +%s)"

LMIP=""
# install sshpass if not installed - yum install sshpass
sudo yum install sshpass
#&> /dev/null

#keygen
ssh-keygen -t rsa -P ""
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

chmod +x enterprise.sh
chmod 777 *.tgz

LIST=$(cat list.txt | grep -v "#" | tr " " "|")


for line in $LIST
do
    component=$(echo $line | cut -d'|' -f1)
    ip=$(echo $line | cut -d'|' -f2)

    if [ "$component" != "LM" ]; then
        scp -r ~/.ssh ${ip}:~/
        scp enterprise.sh splunker@${ip}:/home/splunker
        scp *.tgz splunker@${ip}:/tmp
        scp *.tar.gz splunker@${ip}:/tmp
    fi

done


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
            sh enterprise.sh $component $ip $lmip $misc $port $label $cmrf $cmsf $cmsecret
        else
            sshpass -p "splk" ssh splunker@${ip} ./enterprise.sh $component $ip $lmip $misc $port $label $cmrf $cmsf $cmsecret
        fi
done


#echo
#echo
#echo "========================================="
#for line in $LIST
#do
#        component=$(echo $line | cut -d'|' -f1)
#        ip=$(echo $line | cut -d'|' -f2)
#        lmip=$(echo $line | cut -d'|' -f3)
#        misc=$(echo $line | cut -d'|' -f4)
#        port=$(echo $line | cut -d'|' -f5)
#        label=$(echo $line | cut -d'|' -f6)
#
#        if [ "$component" = "LM" ]; then
#            LMIP=$ip
#        fi
#        
#        echo "Server:  $label, IP: $ip, Splunkd Port: $port, Url: http://$ip:8000"
#done

#echo
#echo
#echo "========================================="
#echo "List All Slave Licenses"
#sshpass -p "splk" ssh splunker@${LMIP} ./enterprise.sh "LISTLIC"
#echo "========================================="


#install *nix app/ add-on
# SH - Install the add-on to all search heads where Unix or Linux knowledge management is required. As a best practice,
#      turn add-on visibility off on your search heads to prevent data duplication errors that can result from running inputs on your search heads instead of or in addition to your data collection node.
# IDX - install the add-on. Not required if you use heavy forwarders to collect data. Required if you use universal or light forwarders to collect data.
# UF / HF - This add-on supports forwarders of any type for data collection. The host must run a supported version of *nix.
echo
echo
echo "========================================="
echo "Installing App"
for line in $LIST
do
    component=$(echo $line | cut -d'|' -f1)
    ip=$(echo $line | cut -d'|' -f2)
    label=$(echo $line | cut -d'|' -f6)
    INSTYPE="SE"
    if [ "$component" = "UF" ]; then
        INSTYPE="UF"
        sshpass -p "splk" ssh splunker@${ip} ./enterprise.sh "INSTALLAPP" "UF" "splunk-add-on-for-unix-and-linux_820.tgz" $label
    fi

    if [ "$component" = "IDX" ]; then
        sshpass -p "splk" ssh splunker@${ip} ./enterprise.sh "INSTALLAPP" "SE" "splunk-add-on-for-unix-and-linux_820.tgz" $label
        sshpass -p "splk" ssh splunker@${ip} ./enterprise.sh "INSTALLAPP" "SE" "splunk-app-for-unix-and-linux_600.tgz" $label
    fi
    
    if [ "$component" = "SH" ]; then
        sshpass -p "splk" ssh splunker@${ip} ./enterprise.sh "INSTALLAPP" "SE" "splunk-app-for-unix-and-linux_600.tgz" $label
        sshpass -p "splk" ssh splunker@${ip} ./enterprise.sh "INSTALLAPP" "SE" "splunk-add-on-for-unix-and-linux_820.tgz" $label
    fi

done
echo "========================================="


echo
echo
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
        label=$(sshpass -p "splk" ssh splunker@${ip} ./enterprise.sh "LISTSERVERLABEL" $INSTYPE)
        echo "$label, IP: $ip"
    fi
#    if [ "$component" = "LM" ]; then
#        sh enterprise.sh "LISTSERVERLABEL" $INSTYPE
#    else
#        sshpass -p "splk" ssh splunker@${ip} ./enterprise.sh "LISTSERVERLABEL" $INSTYPE
#    fi

done
echo "========================================="


echo
echo
end_time="$(date -u +%s)"
elapsed="$(($end_time-$start_time))"
echo "Installation done. Total of $elapsed seconds"
echo
echo
