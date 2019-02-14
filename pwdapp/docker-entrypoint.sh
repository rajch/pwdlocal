#!/bin/sh
if [ ! -f /etc/ssh/ssh_host_rsa_key ]
then
    echo "Generating ssh key at /etc/ssh/ssh_host_rsa_key "
    ssh-keygen -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key >/dev/null
fi

echo "Command line: $0 $@"

if [ "$1" = "pwd" ]
then
    echo "Starting pwd"
    exec /pwdapp/api -save /pwd/sessions -name l2
elif [ "$1" = "l2" ]
then
    echo "Starting l2"
    exec /pwdapp/l2 -ssh_key_path /etc/ssh/ssh_host_rsa_key -name l2 -save /pwd/networks
else
    echo "Invalid parameter. Use 'pwd' or 'l2'"
fi
