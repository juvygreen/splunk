#!/bin/bash

RPM_SPLUNK="splunk-7.3.2-c60db69f8e32-linux-2.6-x86_64.rpm"
PACKAGE_SPLUNK="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.3.2&product=splunk&filename=splunk-7.3.2-c60db69f8e32-linux-2.6-x86_64.rpm&wget=true"

RPM_FORWARDER="splunkforwarder-7.3.2-c60db69f8e32-linux-2.6-x86_64.rpm"
PACKAGE_FORWARDER="https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.3.2&product=universalforwarder&filename=splunkforwarder-7.3.2-c60db69f8e32-linux-2.6-x86_64.rpm&wget=true"



install_tools(){
        sudo yum install wget -y
}

get_package(){
        wget -O $1 $2
}


unpack_package(){
        sudo rpm -ivh $1
}

start_splunk(){
       
	if [ "$1" = "SE" ]; then
		sudo -H -u splunk /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd adminxyz
	else
        sudo -H -u splunk /opt/splunkforwarder/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd adminxyz
    fi
}

restart_splunk(){
       
	if [ "$1" = "SE" ]; then
		sudo -H -u splunk /opt/splunk/bin/splunk restart
    else
        sudo -H -u splunk /opt/splunkforwarder/bin/splunk restart
    fi
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
	sudo su - splunk
}

set_server_label(){
	
	SERVER_LABEL=$2
	echo
	echo
	if [ "$1" = "SE" ]; then
		sudo -H -u splunk /opt/splunk/bin/splunk set servername $SERVER_LABEL
		sudo -H -u splunk /opt/splunk/bin/splunk set default-hostname $SERVER_LABEL
	else
		sudo -H -u splunk /opt/splunkforwarder/bin/splunk set servername $SERVER_LABEL
		sudo -H -u splunk /opt/splunkforwarder/bin/splunk set default-hostname $SERVER_LABEL
	fi
		
	echo
	echo
	echo "Restarting server..."
	restart_splunk $1
}


add_forwarder(){
	
	echo "Adding Forwarder"
	echo
	INS_TYPE="FORWARDER"
    read -p "Enter INDEXER IP address: " IP_INDEXER
	read -p "Enter Port: " SP_PORT
	sudo -H -u splunk /opt/splunkforwarder/bin/splunk add forward-server $IP_INDEXER:$SP_PORT
	restart_splunk $INS_TYPE
}

do_forwarder(){
		echo
		echo "Enter Server label ie indexer1, search-head1, forwarder1, etc..: "
		read SERVER_LABEL
        INS_TYPE="FORWARDER"
        install_tools
        get_package $RPM_FORWARDER $PACKAGE_FORWARDER
        unpack_package $RPM_FORWARDER
        start_splunk $INS_TYPE
		set_server_label $INS_TYPE $SERVER_LABEL
        #add_forwarder
}



# Body
body(){
    echo "Installing Forwarder now....."
    echo "========================================="
    do_forwarder
}

# Main
body

