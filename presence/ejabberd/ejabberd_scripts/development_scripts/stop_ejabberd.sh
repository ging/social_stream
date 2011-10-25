#!/bin/bash

echo "Stopping ejabberd server"
sudo ejabberdctl stop

./kill_authentication_script.sh

echo "Ejabberd server stoped"




