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
    sudo groupadd $username
    sudo usermod -a -G $username $username

    echo "setting password for $username and setting default shell to BASH"
    sudo passwd $username
    sudo chsh -s /bin/bash $username

    echo -e "\nmaking /data/$username/upload\n"
    sudo mkdir -p /data/$username/upload

    #echo "setting permissions for /data/$username and /data/$username/upload"
    #sudo chown -R $username:sftp_users /data/$username
    #sudo chown -R $username:sftp_users /data/$username/upload

    # sudo chown -R $username:$username /home/$username
    sudo chown root:root /home/$username
    sudo chmod 755 /home/$username
    # sudo mkdir /home/$username/upload
    # sudo chown $username:$username /home/$username/upload
    # sudo chmod 700 /home/$username/upload

# got help on this section from GPT - available on request
    # Backup the original sshd_config file
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

    # Check if the configuration lines already exist to avoid duplication
    if ! grep -q "Match Group sftp_users" /etc/ssh/sshd_config; then
        # Append the configuration lines to the sshd_config file
        echo "Appending SFTP configuration to /etc/ssh/sshd_config"
        echo -e "Match Group sftp_users\nChrootDirectory /data/%u\nForceCommand internal-sftp" | sudo tee -a /etc/ssh/sshd_config > /dev/null
    else
        echo "SFTP configuration already exists in /etc/ssh/sshd_config"
    fi

    # Test the new SSH configuration for syntax errors
    if sudo sshd -t; then
        echo "SSH configuration is valid. Restarting SSH service."
        sudo systemctl restart sshd
    else
        echo "SSH configuration test failed. Reverting to the backup configuration."
        sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
        echo "SSH service restart aborted. Please check the configuration."
    fi

}

adduserkey(){

read -p "Do you have a public SSH key to provide for the new user, $username? y/n " isKey
if [ "$isKey" = 'y' ]; then 
    read -p "Provide the public SSH key for $username: " publickey

    # Create .ssh directory if it doesn't exist
    if [ ! -d "/home/$username/.ssh" ]; then
        sudo mkdir -p "/home/$username/.ssh"
        sudo chown $username:sftp_users "/home/$username/.ssh"
    fi

    # Correctly write the key to authorized_keys with appropriate permissions
    echo "$publickey" | sudo tee "/home/$username/.ssh/authorized_keys" > /dev/null && echo -e "\nsuccessfully took public key!\n\n"
    sudo chmod 600 "/home/$username/.ssh/authorized_keys"
    sudo chown $username:sftp_users "/home/$username/.ssh/authorized_keys"

else
    echo "Skipping SSH key setup for $username."
fi

}

getname
makesftp
addusertogrp
adduserkey