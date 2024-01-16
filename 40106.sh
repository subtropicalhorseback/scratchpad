#!/bin/bash

getname(){
    read -p "Enter the username to enable for SFTP access on this server: " username
    sleep 1
    echo -e "Okay, setting you up with $username\n"
}

makesftp(){
    read -p "Do you need to make the sftp usergroup? y/n " usergroup
    if [ "$usergroup" = "y" ]; then
        sudo groupadd sftp_users
    elif [ "$usergroup" = "n" ]; then
        echo "ok! skipping"
    else
        echo "invalid input"
    fi
}

addusertogrp(){
    echo "adding $username to sftp_users"
    sudo useradd -g sftp_users -m $username

    echo "setting password for $username"
    sudo passwd $username

    echo "making /data/$username/upload"
    sudo mkdir -p /data/$username/upload

    echo "setting permissions for /data/$username and /data/$username/upload"
    sudo chown -R root:root /data/$username
    sudo chown -R $username:sftp_users /data/$username/upload

    sudo chown -R $username:$username /home/$username
    echo -e "Match Group sftp_users \nChrootDirectory /data/%u \nForceCommand internal-sftp" >> /etc/ssh/sshd_config

    echo "restarting ssh"
    sudo systemctl restart sshd
}


getname
makesftp
addusertogrp
