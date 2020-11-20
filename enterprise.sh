#!/bin/bash

RPM_SPLUNK="splunk-8.1.0-f57c09e87251-linux-2.6-x86_64.rpm"
PACKAGE_SPLUNK="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.1.0&product=splunk&filename=splunk-8.1.0-f57c09e87251-linux-2.6-x86_64.rpm&wget=true"
TAR_SPLUNK="splunk-8.1.0-f57c09e87251-Linux-x86_64.tgz"
TAR_PACKAGE_SPLUNK="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.1.0&product=splunk&filename=splunk-8.1.0-f57c09e87251-Linux-x86_64.tgz&wget=true"

RPM_FORWARDER="splunkforwarder-8.1.0-f57c09e87251-linux-2.6-x86_64.rpm"
PACKAGE_FORWARDER="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.1.0&product=universalforwarder&filename=splunkforwarder-8.1.0-f57c09e87251-linux-2.6-x86_64.rpm&wget=true"
TAR_FORWARDER="splunkforwarder-8.1.0-f57c09e87251-Linux-x86_64.tgz"
TAR_PACKAGE_FORWARDER="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.1.0&product=universalforwarder&filename=splunkforwarder-8.1.0-f57c09e87251-Linux-x86_64.tgz&wget=true"


#RPM_SPLUNK="splunk-8.0.1-6db836e2fb9e-linux-2.6-x86_64.rpm"
#PACKAGE_SPLUNK="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.1&product=splunk&filename=splunk-8.0.1-6db836e2fb9e-linux-2.6-x86_64.rpm&wget=true"
#TAR_SPLUNK="splunk-8.0.1-6db836e2fb9e-Linux-x86_64.tgz"
#TAR_PACKAGE_SPLUNK="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.1&product=splunk&filename=splunk-8.0.1-6db836e2fb9e-Linux-x86_64.tgz&wget=true"

#RPM_FORWARDER="splunkforwarder-8.0.1-6db836e2fb9e-linux-2.6-x86_64.rpm"
#PACKAGE_FORWARDER="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.1&product=universalforwarder&filename=splunkforwarder-8.0.1-6db836e2fb9e-linux-2.6-x86_64.rpm&wget=true"
#TAR_FORWARDER="splunkforwarder-8.0.1-6db836e2fb9e-Linux-x86_64.tgz"
#TAR_PACKAGE_FORWARDER="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.1&product=universalforwarder&filename=splunkforwarder-8.0.1-6db836e2fb9e-Linux-x86_64.tgz&wget=true"



TRIAL="yes"
USETAR="no"

USER="splunk"

create_user(){
	sudo -H adduser $USER
}

create_group(){
	sudo -H groupadd $USER
}

change_owner(){
	if [ "$1" = "SE" ]; then
		sudo -H chown -R $USER:$USER /opt/splunk
	else
		sudo -H chown -R $USER:$USER /opt/splunkforwarder
	fi
}

do_login(){
	if [ "$1" = "SE" ]; then
		sudo -H -u $USER /opt/splunk/bin/splunk search 'index=_internal | fields _time | head 1 ' -auth 'admin:adminxyz'
	#else
		#sudo -H -u $USER /opt/splunkforwarder/bin/splunk search 'index=_internal | fields _time | head 1 ' -auth 'admin:adminxyz'
	fi
}

install_tools(){
        sudo yum install wget -y &> /dev/null
		sudo yum -y install sysstat &> /dev/null
}

get_package(){
	if [ "$1" = "SE" ]; then
		if [ "$USETAR" = "yes" ]; then
			wget -O $TAR_SPLUNK $TAR_PACKAGE_SPLUNK &> /dev/null
		else
			wget -O $RPM_SPLUNK $PACKAGE_SPLUNK &> /dev/null
		fi
	else
		if [ "$USETAR" = "yes" ]; then
			wget -O $TAR_FORWARDER $TAR_PACKAGE_FORWARDER &> /dev/null
		else
			wget -O $RPM_FORWARDER $PACKAGE_FORWARDER &> /dev/null
		fi
	fi
}


unpack_package(){
	
	if [ "$1" = "SE" ]; then
		if [ "$USETAR" = "yes" ]; then
			create_user
			create_group
			sudo tar xvzf $TAR_SPLUNK -C /opt &> /dev/null
			change_owner $1
		else
			sudo rpm -ivh $RPM_SPLUNK &> /dev/null
		fi
	else
		if [ "$USETAR" = "yes" ]; then
			create_user
			create_group
			sudo tar xvzf $TAR_FORWARDER -C /opt &> /dev/null
			change_owner $1
		else
			sudo rpm -ivh $RPM_FORWARDER &> /dev/null
		fi
	fi
}

start_splunk(){
       
	if [ "$1" = "SE" ]; then
		sudo -H -u $USER /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd adminxyz &> /dev/null
	else
        sudo -H -u $USER /opt/splunkforwarder/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt --seed-passwd adminxyz &> /dev/null
    fi
}

restart_splunk(){
       
	if [ "$1" = "SE" ]; then
		sudo -H -u $USER /opt/splunk/bin/splunk restart &> /dev/null
    else
        sudo -H -u $USER /opt/splunkforwarder/bin/splunk restart &> /dev/null
    fi
}

do_set_license(){
	
	# $1 = mode (master/slave)
	# $2 = licensepath
	# $3 = licenseIP
	# $4 = licenseport
	
	if [ "$TRIAL" = "no" ]; then
		do_login "SE"
		
		if [ "$1" = "master" ]; then
			echo "Setting up as License Master..."
			cp /home/splunker/license.lic /opt
			sudo -H -u $USER /opt/splunk/bin/splunk add licenses $2
		else
			echo "Setting up as License Slave..."
			sudo -H -u $USER /opt/splunk/bin/splunk edit licenser-localslave -master_uri https://$3:$4
		fi
	fi
	
}

do_list_license(){
	if [ "$TRIAL" = "no" ]; then
		do_login "SE"
		sudo -H -u $USER /opt/splunk/bin/splunk list licenser-slaves
	else
		echo "License in Trial..all instances are stand alone license master"
	fi
}

do_configure_cluster(){
	# $1 = mode (master/slave/searchhead)
	# $2 = CMIP
	# $3 = RF
	# $4 = SF
	# $5 = secret
	
	do_login "SE"
	
	if [ "$1" = "master" ]; then
		echo "Configure Master Mode"
		sudo -H -u $USER /opt/splunk/bin/splunk edit cluster-config -mode master -replication_factor $3 -search_factor $4 -secret $5
	fi
	
	if [ "$1" = "slave" ]; then
		echo "Configure Slave Mode"
		#mode (master/slave) IDXIP CMIP CMPORT REPLICATIONPORT Secret
		sudo -H -u $USER /opt/splunk/bin/splunk edit cluster-config -mode slave -master_uri https://${3}:${4} -secret $6 -replication_port $5
	fi
	
	if [ "$1" = "search" ]; then
		echo "Configure Search Head Mode"
		#mode (master/slave/search) IDXIP CMIP CMPORT Secret
		sudo -H -u $USER /opt/splunk/bin/splunk edit cluster-config -master_uri https://${3}:${4} -mode searchhead -secret $5
	fi
}

enable_listen(){
	echo "Enable Listening Port $1"
	#do_login "SE"
	sudo -H -u $USER /opt/splunk/bin/splunk enable listen $1 -auth 'admin:adminxyz'
}

disable_webserver(){
	echo "Disable Webserver"
	sudo -H -u $USER /opt/splunk/bin/splunk disable webserver
}

show_ip(){
        echo
        echo
		echo "Web URL:"
        ifconfig | grep broadcast | awk '{ print "http://"$2":8000" }'
		echo
		echo
}

set_su_splunk(){
	sudo su - $USER
}


set_server_label(){
	
	SERVER_LABEL=$2
	
	#do_login $1
	
	if [ "$1" = "SE" ]; then
		sudo -H -u $USER /opt/splunk/bin/splunk set servername $SERVER_LABEL -auth 'admin:adminxyz'
		sudo -H -u $USER /opt/splunk/bin/splunk set default-hostname $SERVER_LABEL -auth 'admin:adminxyz'
	else
		sudo -H -u $USER /opt/splunkforwarder/bin/splunk set servername $SERVER_LABEL -auth 'admin:adminxyz'
		sudo -H -u $USER /opt/splunkforwarder/bin/splunk set default-hostname $SERVER_LABEL -auth 'admin:adminxyz'
	fi
	
	echo "Restarting server..."
	restart_splunk $1
	
}

do_list_server_label(){
	
	#do_login $1
	
	if [ "$1" = "SE" ]; then
		sudo -H -u $USER /opt/splunk/bin/splunk show servername -auth 'admin:adminxyz'
	else
		sudo -H -u $USER /opt/splunkforwarder/bin/splunk show servername -auth 'admin:adminxyz'
	fi
}

do_label_cluster(){
	do_login "SE"
	
	sudo -H -u $USER /opt/splunk/bin/splunk edit cluster-config -cluster_label $1
}

do_add_search_peer(){
	echo "Adding peer to Search Head"
	sudo -H -u $USER /opt/splunk/bin/splunk add search-server https://${1}:${2} -auth 'admin:adminxyz' -remoteUsername admin -remotePassword adminxyz
}

do_enterprise(){
		INS_TYPE="SE"
		SERVER_PORT=$1
		SERVER_LABEL=$2
		echo "Installing dependencies..."
        install_tools
		echo "Downloading package..."
        get_package $INS_TYPE
		echo "Unpacking package..."
        unpack_package $INS_TYPE
		echo "Starting Splunk..."
        start_splunk $INS_TYPE
		echo "Setting Server Label..."
		set_server_label $INS_TYPE $SERVER_LABEL
        #show_ip
		#set_su_splunk
}


add_forwarder(){
	
	echo "Add Forward-Server to indexer..."
	echo
	INS_TYPE="FORWARDER"
	IP_INDEXER=$1
	SP_PORT=$2
    #read -p "Enter INDEXER IP address: " IP_INDEXER
	#read -p "Enter Port: " SP_PORT
	sudo -H -u $USER /opt/splunkforwarder/bin/splunk add forward-server $IP_INDEXER:$SP_PORT -auth 'admin:adminxyz'
	restart_splunk $INS_TYPE
}

do_forwarder(){
	echo
	INS_TYPE="FORWARDER"
	SERVER_LABEL=$3
	echo "Installing dependencies..."
	install_tools
	echo "Downloading package..."
	get_package $INS_TYPE
	echo "Unpacking package..."
	unpack_package $INS_TYPE
	echo "Starting Splunk..."
	start_splunk $INS_TYPE
	echo "Setting Server Label..."
	set_server_label $INS_TYPE $SERVER_LABEL
	add_forwarder $1 $2
}

do_install_app(){
	
	#notes for *nix apps/ add-ons
	
	#* sysstat is not installed by default in some OS. The reason no data for cpu. 
	
	# 1. login to indexers. cp indexes.conf to app/local
	# configure app in indexers only
	# configure app: cp indexers.conf to local -  this creates indexes in indexers: os, unix_summary, firedalerts
	# configure app: cp default/macros.conf and savedsearches.conf to local. change index=os in macros.conf || changes to index=os in savedsearches.conf in fired_alerts stanza
	
	#### for ALERTS dashboard - - should be configured in IDX and UF. Enable all alerts
	
	# sudo su - splunk
	# cd /opt/splunk/etc/apps/splunk_app_for_nix/
	# mkdir local
	# cd /opt/splunk/etc/apps/Splunk_TA_nix/
	# mkdir local
	# 
	# cd /tmp
	# tar -xzvf splunk_app_nix.tar.gz
	# tar -xzvf splunk_ta_nix.tar.gz
	# cd /tmp/splunk_app_nix/local/
	# cp indexes.conf /opt/splunk/etc/apps/splunk_app_for_nix/local
	#**** cp macros.conf and savedsearches.conf if necessary
	
	
	#2. enable inputs in UF, IDX
	# configure TA in indexers and UF only. Install in SH but invisible=0, no need to configure
	# configure add-on: cp default/inputs.conf to local. add disabled=0 || add index=os to each input stanza in TA_nix/local/inputs.conf || invisible=no in SH (app.conf) -
	#  [ui]
	#  is_visible = 0

	# cd /tmp/splunk_ta_nix/local/
	# cp inputs.conf /opt/splunk/etc/apps/Splunk_TA_nix/local/
	
	# /opt/splunk/bin/splunk restart
	
	#3. login to indexers via web - enable / verify inputs by going to TA and save. verify if indexers were created. do spl search index=os
	
	#4. login to UF
	# cd /opt/splunkforwarder/etc/apps/Splunk_TA_nix/
	# mkdir local
	# cd /tmp
	# tar -xzvf splunk_ta_nix.tar.gz
	# cd /tmp/splunk_ta_nix/local/
	# cp inputs.conf /opt/splunkforwarder/etc/apps/Splunk_TA_nix/local
	# /opt/splunkforwarder/bin/splunk restart
	
	#5. login to SH via web
	# verify peer is added
	# set TA to visible = off - manage apps > edit properties
	# setup APP
	
	echo
	echo "Installing $2 at $3:"
	
	INS_TYPE=$1
	
	if [ "$1" = "SE" ]; then
		sudo -H -u $USER /opt/splunk/bin/splunk install app /tmp/${2} -auth 'admin:adminxyz'
	else
		sudo -H -u $USER /opt/splunkforwarder/bin/splunk install app /tmp/${2} -auth 'admin:adminxyz'
	fi
	
	echo "Restarting server..."
	restart_splunk $1
	echo "---------------------"
}




# Menu
info_display(){

        echo
       
		# $1 = component
		# $2 = server IP
		# $3 = license master IP
		# $4 = misc - license path
		# $5 = server port 
		# $6 = server label
		# $7 = CM Replication Factor
		# $8 = CM Search Factor
		# $9 = CM Secret
		
		case $1 in
                "LM")
						echo "========================================="
						echo "Installation starts for: "
                        echo "License Master"
						echo "IP Address: " $2
						echo "Label: " $6
						do_enterprise $5 $6
						#mode (master/slave) licensepath licenseIP licenseport
						do_set_license "master" $4 $3 $5
						echo "Restarting server..."
						restart_splunk "SE"
						echo "Installation ends for License Master "
                        echo "========================================="
                        ;;
                "CM")
						echo "========================================="
						echo "Installation starts for: "
                        echo "Cluster Master"
						echo "IP Address: " $2
						echo "Label: " $6
						do_enterprise $5 $6
						#mode (master/slave) licensepath licenseIP licenseport
						do_set_license "slave" $4 $3 $5
						#mode (master/slave) CMIP RF SF Secret
						if [ "$9" != "N/A" ]; then
							do_configure_cluster "master" $2 $7 $8 $9
						fi
						echo "Restarting server..."
						restart_splunk "SE"
						echo "Installation ends for Cluster Master "
                        echo "========================================="
						;;
                "IDX")
						echo "========================================="
						echo "Installation starts for: "
                        echo "Indexer"
						echo "IP Address: " $2
						echo "Label: " $6
						do_enterprise $5 $6
						#mode (master/slave) licensepath licenseIP licenseport
						do_set_license "slave" $4 $3 $5
						#enable listener
						enable_listen $7
						#disable webserver
						#disable_webserver
						#mode (master/slave) IDXIP CMIP CMPORT LISTENPORT REPLICATIONPORT Secret
						if [ "$9" != "N/A" ]; then
							do_configure_cluster "slave" $2 $4 $5 $8 $9
						fi
						echo "Restarting server..."
						restart_splunk "SE"
						echo "Installation ends for Indexer "
                        echo "========================================="
                        ;;
				"SH")
						echo "========================================="
						echo "Installation starts for: "
                        echo "Search Head"
						echo "IP Address: " $2
						echo "Label: " $6
						do_enterprise $5 $6
						#mode (master/slave) licensepath licenseIP licenseport
						do_set_license "slave" $4 $3 $5
						#mode (search) SHIP CMIP CMPORT Secret
						if [ "$9" != "N/A" ]; then
							do_configure_cluster "search" $2 $4 $5 $9
						fi
						do_add_search_peer $7 $8
						echo "Restarting server..."
						restart_splunk "SE"
						echo "Installation ends for Search Head "
                        echo "========================================="
                        ;;
						
				"UF")
						echo "========================================="
						echo "Installation starts for: "
                        echo "Universal Forwarder"
						echo "IP Address: " $2
						echo "Label: " $6
						do_forwarder $4 $5 $6
						echo "Installation ends for Universal Forwarder "
                        echo "========================================="
                        ;;
						
				"SETSERVERLABEL")
                        set_server_label $2 $3
                        ;;
						
				"LISTLIC")
                        do_list_license
                        ;;
						
				"LISTSERVERLABEL")
                        do_list_server_label $2
                        ;;
				
				"LABELCLUSTER")
                        do_label_cluster $2
                        ;;
				
				"INSTALLAPP")
                        do_install_app $2 $3 $4
                        ;;

                *)
                        echo "Dracarys!"
                        ;;
        esac
		
		
        
        echo


}



# Body
main(){
    info_display $1 $2 $3 $4 $5 $6 $7 $8 $9
}

# Main

if [ $# -gt 0 ]; then
	main $@
fi

