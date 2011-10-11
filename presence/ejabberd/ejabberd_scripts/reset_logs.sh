#!/bin/bash

echo "Starting Reset logs"

rm /var/log/ejabberd/auth.log
rm /var/log/ejabberd/auth_error.log
rm /var/log/ejabberd/ejabberd.log
rm /var/log/ejabberd/erlang.log
rm /var/log/ejabberd/scripts.log
rm /var/log/ejabberd/erl_crash_*

touch /var/log/ejabberd/auth.log
touch /var/log/ejabberd/auth_error.log
touch /var/log/ejabberd/ejabberd.log
touch /var/log/ejabberd/erlang.log
touch /var/log/ejabberd/scripts.log
touch /var/log/ejabberd/erl_crash_dummy.log

echo "Reset logs OK"




