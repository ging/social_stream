#!/bin/bash
#Script header edition
#@author Aldo

#Constants
installer_file_path=$(readlink -f $0)
installer_folder_path=`dirname "$installer_file_path"`


#Functions


msg () {
	echo "#################################"
	echo $1
}


#Main Program

msg "Starting set scripts header"

echo "Installer path:" $installer_file_path


#Look for params

msg "Detecting ruby enviroment"

if [ $1 ]
  then {
	echo "Ruby enviromet specified by param"
	ruby_env=$1
  } else {
	ruby_env=`which ruby`
  }
fi

echo "Ruby enviroment:" $ruby_env


msg "Writing scripts header"
echo ""
for file in `ls $installer_folder_path/` ; do


	if [ ! -f $installer_folder_path/$file ];
	then
		continue
	fi

	if [[ $file =~ .sh$ ]]
	then
		continue
	fi

	if [ $installer_folder_path/$file == $installer_file_path ];
	then
		continue
	fi


	printf $file"\n"

	#Create temporal file
	temporal_path=$installer_folder_path/$file"_temp"

	if [ -f $temporal_path ];
	then
		echo "File $temporal_path exists."
		rm $temporal_path
	fi

	touch $temporal_path

	#Read file
	file_path=$installer_folder_path/$file

	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")

	while read line
	do
		#Look for Pattern !/usr/bin/env ruby
		if [[ $line =~ ^#!/usr/bin/env ]]
		then
			scriptheader="#!/usr/bin/env"
			line="${scriptheader} ${ruby_env}"
		fi
		echo $line >> $temporal_path
	done < $file_path

	IFS=$SAVEIFS

	#Replace original file
	cp $temporal_path $file_path

	#Remove temporal file
	rm $temporal_path

done


msg "Complete"
exit 0







