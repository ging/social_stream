#!/bin/bash

#Social Stream Presence Ejabberd files installer
#@author Aldo

#Call example:
#./installer.sh ejabberd_module_path="/ejabberd_module_path/" scripts_path="/scripts_path/" [key1=value1,key2=value2]

#Constants
config_files_path="/etc/ejabberd/"
logs_path="/var/log/ejabberd/"
installer_file_path=$(readlink -f $0)
installer_folder_path=`dirname "$installer_file_path"`



#Functions

help () {
      echo "Syntax error: ./installer [onlyconf=true] ejabberd_module_path=mpath scripts_path=spath [key1=value1,key2=value2,...]"  
}


msg () {
      echo "#################################"
      echo $1
}


applyOption () {
      if [ ! $1 ] || [ ! $2 ]
        then
          return 1
      fi
      #key $1
      #value $2
      #string ssconfig $3
      echo "Enable option " $1"="$2

      SEPARATOR=$(echo -en "\n\b")
      match=$1"="
	
     if [[ $ssconfig == *$match* ]]
	then {
		#Modify existing options
 	        repl=$1"="$2"="

		if [ $2 == "remove" ]
		 then 
		  repl="removedVar=true="
		fi

      		ssconfig=${ssconfig/$match/$repl}
	} else {
		#Add new options
		if [ ! $2 == "remove" ]
		 then 
		  ssconfig="${ssconfig}${SEPARATOR}${1}=${2}="
		fi
 	}
     fi

      return 0
}


restoreFile () {
      IFS=$(echo -en "\n\b")
      cat /dev/null > $conffile
      for word in $ssconfigrestore; do
	echo $word >> $conffile
      done
      return 0
}


updateSSConfig () {

if [ $1 ] && [ ${#1} -gt 2 ]
  then {

        if [ ${1:0:1} != "[" ] || [ ${1:${#1}-1:${#1}} != "]" ]
	  then
          echo "Malformed options"
          help
	  exit 1
        fi

        msg "Processing options"
        options=${1:1:${#1}-2}
        options=(${options//","/ })


	#Read config file
	ssconfig=""
	conffile=$config_files_path/ssconfig.cfg

	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")

	while read line
	do
	  ssconfig="${ssconfig}${line}${IFS}"
	done < $conffile

	IFS=$SAVEIFS

	ssconfigrestore=$ssconfig;

	#Modify ssconfig to apply options
	for option in ${options[@]}; do
		option=(${option//"="/ })
		key=${option[0]}
        	value=${option[1]}
		applyOption $key $value
	done


	#Write (ssconfig) to file
	cat /dev/null > $conffile
	IFS=$(echo -en "\n\b")
	for word in $ssconfig; do

	  if [[ $word =~ [#] ]] || [ -z $word ]
	    then {
            	echo $word >> $conffile
 	    } else {
                IFS=$SAVEIFS
		arr=(${word//"="/ })
		if [ ${#arr[@]} -lt 2 ]
			then
			echo "ssconfig.cfg error in line:" $word
			restoreFile
			exit 1
		fi
                word="${arr[0]}=${arr[1]}"
		if [ ! $word == "removedVar=true" ]
		 then
 			echo $word >> $conffile
	        fi
	    }
          fi
	done
  }
fi

}


#Main Program


#Look for only configuration mode
arr=(${1//"="/ })
if [ ${#arr} -ge 2 ] && [ ${arr[0]} == "onlyconf" ] && [ ${arr[1]} == "true" ]
  then {
    msg "Updating ssconfig"
    updateSSConfig $2
    exit 0
  }
fi



#Installer mode
msg "Start installer"

if [ $# -lt 2 ]
  then
    help
    exit 1
fi


msg "Reading parameters..."

arr=(${1//"="/ })

if [ ${arr[0]} == "ejabberd_module_path" ]
  then {
    ejabberd_module_path=${arr[1]}
  } else {
    help
    exit 1
  }
fi

arr=(${2//"="/ })

if [ ${arr[0]} == "scripts_path" ]
  then {
    scripts_path=${arr[1]}
  } else {
    help
    exit 1
  }
fi


echo "Installer path:" $installer_file_path
echo "Ejabberd module path:" $ejabberd_module_path 
echo "scripts_path:" $scripts_path
echo "config_files_path:" $config_files_path
echo "logs_path:" $logs_path


paths=($ejabberd_module_path $scripts_path $config_files_path $logs_path )

msg "Creating directories"

for path in ${paths[@]}; do
        mkdir -p $path
done


msg "Copying Ejabberd modules"
cp $installer_folder_path/mod_admin_extra/mod_admin_extra.beam $ejabberd_module_path
cp $installer_folder_path/mod_sspresence/mod_sspresence.beam $ejabberd_module_path

msg "Copying scripts"
cp -r $installer_folder_path/ejabberd_scripts/* $scripts_path


msg "Checking and copying configuration files"

if [ -e $config_files_path/ssconfig.cfg ]
  then {
       echo "Find ssconfig.cfg: updating ssconfig_example.cfg"
       cp $installer_folder_path/conf/ssconfig_example.cfg $config_files_path/ssconfig_example.cfg
    } else {
       echo "ssconfig not exists"
       cp $installer_folder_path/conf/ssconfig_example.cfg $config_files_path/ssconfig.cfg
  }
fi

cp $installer_folder_path/conf/ejabberd_example.cfg $config_files_path/ejabberd_example.cfg
echo "Updating ejabberd_example.cfg"

msg "Check and copying log files"
if [ ! -e $logs_path/scripts.log ]
  then {
       echo "Creating scripts.log"
       touch $logs_path/scripts.log
  }
fi

if [ ! -e $logs_path/auth.log ]
  then {
       echo "Creating auth.log"
       touch $logs_path/auth.log
  }
fi


#Processing options
updateSSConfig $3


msg "Complete"
exit 0







