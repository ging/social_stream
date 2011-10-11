#!/bin/bash

echo "Kill All Authentication Scripts"

for pid in `ps -aef | grep './authentication_script' | grep -v grep | awk '{print $2}'`
do
	echo $pid  		
	kill -9 $pid
done




