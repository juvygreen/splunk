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
       
	if [ "$1" = "INDEXER" ]; then
		sudo -H -u splunk /opt/splunk/bin/splunk start --accept-license
	else
        sudo -H -u splunk /opt/splunkforwarder/bin/splunk start --accept-license
    fi
}

restart_splunk(){
       
	if [ "$1" = "INDEXER" ]; then
		sudo -H -u splunk /opt/splunk/bin/splunk restart
    else
        sudo -H -u splunk /opt/splunkforwarder/bin/splunk restart
    fi
}

show_ip(){
        echo
        echo
        ifconfig | grep broadcast | awk '{ print "http://"$2":8000" }'
		echo
		echo
}

do_indexer(){
        INS_TYPE="INDEXER"
        install_tools
        get_package $RPM_SPLUNK $PACKAGE_SPLUNK
        unpack_package $RPM_SPLUNK
        start_splunk $INS_TYPE
        show_ip
}

do_search_head(){
        do_indexer
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
        INS_TYPE="FORWARDER"
        install_tools
        get_package $RPM_FORWARDER $PACKAGE_FORWARDER
        unpack_package $RPM_FORWARDER
        start_splunk $INS_TYPE
        add_forwarder
}




# Menu
menu_display(){

        echo
        echo "================MENU====================="
        echo "========================================="
        echo "Enter the corresponding number of the installation/process type: "
        printf 'Indexer: \t\t 1 \n'
        printf 'Search Head: \t\t 2 \n'
        printf 'Forwarder: \t\t 3 \n'
        printf 'Add A Forwarder: \t 4 \n'


        printf 'Exit: \t\t\t 5 \n'
        echo


}



# Body
body(){
        menu_display

        read -p "Enter Option: " INPUT

        case $INPUT in
                1)
                        echo "Installing Indexer now....."
                        echo "========================================="
                        do_indexer
                        ;;
                2)
                        echo "Installing Search Head now....."
                        echo "========================================="
                        do_search_head
                        ;;
                3)
                        echo "Installing Forwarder now....."
                        echo "========================================="
                        do_forwarder
                        ;;
	       4)
                        echo "Adding Forwarder now....."
                        echo "========================================="
                        add_forwarder
                        ;;

                5)
                        echo "Dracarys!"
                        ;;
                *)
                        echo "Dracarys!"
                        ;;
        esac

}

# Main

body

