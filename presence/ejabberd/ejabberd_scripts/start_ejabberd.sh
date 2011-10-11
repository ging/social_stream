#!/bin/bash

echo "Stopping ejabberd server"
sudo ejabberdctl stop

if [ $# -lt 1 ]; then
      command="start"
      echo "Starting ejabberd server"
else
	
	param=$1
	logs=true

	while getopts ":l" opt; do
	  	case $opt in
		    	l)
		      		#-l option
				logs=false
				
				if [ $# -lt 2 ]; then
					param="start"
				else
					param=$2
				fi
		      		;;
		    	\?)
		      		echo "Invalid option: -$OPTARG" >&2
				echo "Use \"$0 help\" to view help"
				exit
		      		;;
	  	esac
	done



	if [ $param == "live" ]; then      
		command="live"
		echo "Starting ejabberd server in Live mode"
        elif [ $param == "start" ]; then  
		command="start"
		echo "Starting ejabberd server"
	else
		#Show HELP
		echo "Use \"$0 start\" to Start ejabberd server in normal mode"
		echo "Use \"$0 live\" to Start ejabberd server in live mode"
		echo "Use -l option to keep log files"
		exit
	fi	
fi


echo ""
./kill_authentication_script.sh
if $logs; then 
./reset_logs.sh 
fi
./compile_module
./reset_connection_script
./show_config.sh

sudo ejabberdctl $command
echo "ejabberd server started"






