#!/bin/bash

RPM_SPLUNK="splunk-8.0.1-6db836e2fb9e-linux-2.6-x86_64.rpm"
PACKAGE_SPLUNK="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.1&product=splunk&filename=splunk-8.0.1-6db836e2fb9e-linux-2.6-x86_64.rpm&wget=true"
TAR_SPLUNK="splunk-8.0.1-6db836e2fb9e-Linux-x86_64.tgz"
TAR_PACKAGE_SPLUNK="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.1&product=splunk&filename=splunk-8.0.1-6db836e2fb9e-Linux-x86_64.tgz&wget=true"

RPM_FORWARDER="splunkforwarder-8.0.1-6db836e2fb9e-linux-2.6-x86_64.rpm"
PACKAGE_FORWARDER="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.1&product=universalforwarder&filename=splunkforwarder-8.0.1-6db836e2fb9e-linux-2.6-x86_64.rpm&wget=true"
TAR_FORWARDER="splunkforwarder-8.0.1-6db836e2fb9e-Linux-x86_64.tgz"
TAR_PACKAGE_FORWARDER="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.1&product=universalforwarder&filename=splunkforwarder-8.0.1-6db836e2fb9e-Linux-x86_64.tgz&wget=true"

TRIAL="yes"
USETAR="yes"

USER="archStudent"

create_user(){
	echo "sudo -H adduser $USER"
}

create_group(){
	echo "sudo -H groupadd $USER"
}

change_owner(){
	if [ "$1" = "SE" ]; then
		echo "sudo -H chown -R $USER:$USER /opt/splunk"
	else
		echo "sudo -H chown -R $USER:$USER /opt/splunkforwarder"
	fi
}

do_login(){
	if [ "$1" = "SE" ]; then
		echo "sudo -H -u $USER /opt/splunk/bin/splunk search 'index=_internal | fields _time | head 1 ' -auth 'admin:adminxyz'"
	#else
		#sudo -H -u $USER /opt/splunkforwarder/bin/splunk search 'index=_internal | fields _time | head 1 ' -auth 'admin:adminxyz'
	fi
}

install_tools(){
        echo "sudo yum install wget -y"
}

get_package(){
	if [ "$1" = "SE" ]; then
		if [ "$USETAR" = "yes" ]; then
			echo "wget -O $TAR_SPLUNK $TAR_PACKAGE_SPLUNK"
		else
			echo "wget -O $RPM_SPLUNK $PACKAGE_SPLUNK"
		fi
	else
		if [ "$USETAR" = "yes" ]; then
			echo "wget -O $TAR_FORWARDER $TAR_PACKAGE_FORWARDER"
		else
			echo "wget -O $RPM_FORWARDER $PACKAGE_FORWARDER"
		fi
	fi
}


unpack_package(){
	
	if [ "$1" = "SE" ]; then
		if [ "$USETAR" = "yes" ]; then
			#create_user
			#create_group
			echo "sudo tar xvzf $TAR_SPLUNK -C /opt"
			change_owner $1
		else
			echo "sudo rpm -ivh $RPM_SPLUNK"
		fi
	else
		if [ "$USETAR" = "yes" ]; then
			#create_user
			#create_group
			echo "sudo tar xvzf $TAR_FORWARDER -C /opt"
			change_owner $1
		else
			echo "sudo rpm -ivh $RPM_FORWARDER"
		fi
	fi
}

start_splunk(){
       
	if [ "$1" = "SE" ]; then
		echo "sudo -H -u $USER /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd adminxyz"
	else
        echo "sudo -H -u $USER /opt/splunkforwarder/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt --seed-passwd adminxyz"
    fi
}

restart_splunk(){
       
	if [ "$1" = "SE" ]; then
		echo "sudo -H -u $USER /opt/splunk/bin/splunk restart"
    else
        echo "sudo -H -u $USER /opt/splunkforwarder/bin/splunk restart"
    fi
}

do_set_license(){
	
	# $1 = mode (master/slave)
	# $2 = licensepath
	# $3 = licenseIP
	# $4 = licenseport
	
	if [ "$TRIAL" = "no" ]; then
		#do_login "SE"
		
		if [ "$1" = "master" ]; then
			echo "Setting up as License Master..."
			echo "--------------"
			echo
			echo "cp /home/splunker/license.lic /opt"
			echo "sudo -H -u $USER /opt/splunk/bin/splunk add licenses $2"
		else
			echo "Setting up as License Slave..."
			echo "--------------"
			echo
			echo "sudo -H -u $USER /opt/splunk/bin/splunk edit licenser-localslave -master_uri https://$3:$4"
		fi
	fi
	
}

do_list_license(){
	if [ "$TRIAL" = "no" ]; then
		#do_login "SE"
		echo "sudo -H -u $USER /opt/splunk/bin/splunk list licenser-slaves"
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
	
	#do_login "SE"
	
	if [ "$1" = "master" ]; then
		echo "Configure Master Mode"
		echo "--------------"
		echo
		echo "sudo -H -u $USER /opt/splunk/bin/splunk edit cluster-config -mode master -replication_factor $3 -search_factor $4 -secret $5"
	fi
	
	if [ "$1" = "slave" ]; then
		echo "Configure Slave Mode"
		echo "--------------"
		echo
		#mode (master/slave) IDXIP CMIP CMPORT REPLICATIONPORT Secret
		echo "sudo -H -u $USER /opt/splunk/bin/splunk edit cluster-config -mode slave -master_uri https://${3}:${4} -secret $6 -replication_port $5"
	fi
	
	if [ "$1" = "search" ]; then
		echo "Configure Search Head Mode"
		echo "--------------"
		echo
		#mode (master/slave/search) IDXIP CMIP CMPORT Secret
		echo "sudo -H -u $USER /opt/splunk/bin/splunk edit cluster-config -master_uri https://${3}:${4} -mode searchhead -secret $5"
	fi
}

enable_listen(){
	echo "Enable Listening Port $1"
	echo "--------------"
	echo
	echo "sudo -H -u $USER /opt/splunk/bin/splunk enable listen $1"
}

disable_webserver(){
	echo "Disable Webserver"
	echo "--------------"
	echo
	echo "sudo -H -u $USER /opt/splunk/bin/splunk disable webserver"
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
	echo "sudo su - $USER"
}


set_server_label(){
	
	SERVER_LABEL=$2
	
	#do_login $1
	
	if [ "$1" = "SE" ]; then
		echo "sudo -H -u $USER /opt/splunk/bin/splunk set servername $SERVER_LABEL"
		echo "sudo -H -u $USER /opt/splunk/bin/splunk set default-hostname $SERVER_LABEL"
	else
		echo "sudo -H -u $USER /opt/splunkforwarder/bin/splunk set servername $SERVER_LABEL"
		echo "sudo -H -u $USER /opt/splunkforwarder/bin/splunk set default-hostname $SERVER_LABEL"
	fi
	
	echo
	echo "--------------"
	echo "Restarting server..."
	echo "--------------"
	echo
	restart_splunk $1
	
}

do_list_server_label(){
	
	#do_login $1
	
	if [ "$1" = "SE" ]; then
		echo "sudo -H -u $USER /opt/splunk/bin/splunk show servername"
	else
		echo "sudo -H -u $USER /opt/splunkforwarder/bin/splunk show servername"
	fi
}

do_label_cluster(){
	#do_login "SE"
	
	echo "sudo -H -u $USER /opt/splunk/bin/splunk edit cluster-config -cluster_label $1"
}

do_enterprise(){
		INS_TYPE="SE"
		SERVER_PORT=$1
		SERVER_LABEL=$2
		echo "Installing dependencies..."
		echo "--------------"
		echo
        install_tools
		echo
		echo "--------------"
		echo "Downloading package..."
		echo "--------------"
		echo
        get_package $INS_TYPE
		echo
		echo "--------------"
		echo "Unpacking package..."
		echo "--------------"
		echo
        unpack_package $INS_TYPE
		echo
		echo "--------------"
		echo "Starting Splunk..."
		echo "--------------"
		echo
        start_splunk $INS_TYPE
		echo
		echo "--------------"
		echo "Setting Server Label..."
		echo "--------------"
		echo
		set_server_label $INS_TYPE $SERVER_LABEL
		echo
        #show_ip
		#set_su_splunk
}


add_forwarder(){
	
	echo "Adding Forwarder"
	echo
	INS_TYPE="FORWARDER"
    read -p "Enter INDEXER IP address: " IP_INDEXER
	read -p "Enter Port: " SP_PORT
	sudo -H -u $USER /opt/splunkforwarder/bin/splunk add forward-server $IP_INDEXER:$SP_PORT
	restart_splunk $INS_TYPE
}

do_forwarder(){
		echo
		INS_TYPE="FORWARDER"
		SERVER_PORT=$1
		SERVER_LABEL=$2
		echo "Installing dependencies..."
		echo "--------------"
		echo
        install_tools
		echo
		echo "--------------"
		echo "Downloading package..."
		echo "--------------"
		echo
        get_package $INS_TYPE
		echo
		echo "--------------"
		echo "Unpacking package..."
		echo "--------------"
		echo
        unpack_package $INS_TYPE
		echo
		echo "--------------"
		echo "Starting Splunk..."
		echo "--------------"
		echo
        start_splunk $INS_TYPE
		echo
		echo "--------------"
		echo "Setting Server Label..."
		echo "--------------"
		echo
		set_server_label $INS_TYPE $SERVER_LABEL
		echo
		echo "--------------"
        #add_forwarder
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
						echo "--------------"
						echo
						do_enterprise $5 $6
						echo
						echo "--------------"
						#mode (master/slave) licensepath licenseIP licenseport
						do_set_license "master" $4 $3 $5
						echo
						echo "--------------"
						echo "Restarting server..."
						echo "--------------"
						echo
						restart_splunk "SE"
						echo
						echo "--------------"
						echo "Installation ends for License Master "
                        echo "========================================="
                        ;;
                "CM")
						echo "========================================="
						echo "Installation starts for: "
                        echo "Cluster Master"
						echo "IP Address: " $2
						echo "Label: " $6
						echo "--------------"
						echo
						do_enterprise $5 $6
						echo
						echo "--------------"
						#mode (master/slave) licensepath licenseIP licenseport
						do_set_license "slave" $4 $3 $5
						echo
						echo "--------------"
						#mode (master/slave) CMIP RF SF Secret
						do_configure_cluster "master" $2 $7 $8 $9
						echo
						echo "--------------"
						echo "Restarting server..."
						echo "--------------"
						echo
						restart_splunk "SE"
						echo
						echo "--------------"
						echo "Installation ends for Cluster Master "
                        echo "========================================="
						;;
                "IDX")
						echo "========================================="
						echo "Installation starts for: "
                        echo "Indexer"
						echo "IP Address: " $2
						echo "Label: " $6
						echo "--------------"
						echo
						do_enterprise $5 $6
						#mode (master/slave) licensepath licenseIP licenseport
						do_set_license "slave" $4 $3 $5
						#enable listener
						enable_listen $7
						echo
						echo "--------------"
						#disable webserver
						disable_webserver
						#mode (master/slave) IDXIP CMIP CMPORT LISTENPORT REPLICATIONPORT Secret
						echo
						echo "--------------"
						do_configure_cluster "slave" $2 $4 $5 $8 $9
						echo "Restarting server..."
						echo "--------------"
						echo
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
						echo "--------------"
						echo
						do_enterprise $5 $6
						#mode (master/slave) licensepath licenseIP licenseport
						do_set_license "slave" $4 $3 $5
						#mode (search) SHIP CMIP CMPORT Secret
						do_configure_cluster "search" $2 $4 $5 $9
						echo
						echo "--------------"
						echo "Restarting server..."
						echo "--------------"
						echo
						restart_splunk "SE"
						echo
						echo "--------------"
						echo "Installation ends for Search Head "
                        echo "========================================="
                        ;;
						
				"UF")
						echo "========================================="
						echo "Installation starts for: "
                        echo "Universal Forwarder"
						echo "IP Address: " $2
						echo "Label: " $6
						echo "--------------"
						echo
						do_forwarder $5 $6
						echo
						echo "--------------"
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

