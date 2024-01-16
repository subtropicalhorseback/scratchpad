#!/bin/bash

getname(){
    read -p "Enter the username to enable for SFTP access on this server: " username
    sleep 1
    echo -e "Okay, setting you up with $username\n"
}

makesftp(){
    if getent group sftp_users > /dev/null; then
        echo "Group 'sftp_users' already exists. Skipping creation."
    else
        echo "Creating group 'sftp_users'."
        sudo groupadd sftp_users
    fi
}


addusertogrp(){
    echo "adding $username to sftp_users"
    sudo useradd -g sftp_users -m $username

    echo "setting password for $username"
    sudo passwd $username

    echo -e "\nmaking /data/$username/upload\n"
    sudo mkdir -p /data/$username/upload

    echo "setting permissions for /data/$username and /data/$username/upload"
    sudo chown -R $username:sftp_users /data/$username
    sudo chown -R $username:sftp_users /data/$username/upload

    sudo chown -R $username:sftp_users /home/$username
    echo -e "Match Group sftp_users \nChrootDirectory /data/%u \nForceCommand internal-sftp" >> /etc/ssh/sshd_config

    echo "restarting ssh"
    sudo systemctl restart sshd
}


getname
makesftp
addusertogrp
