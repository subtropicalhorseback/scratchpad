#!/bin/bash

#####
#define options for menu
# 1- mope
# 2- sad
# 3- cheddir
# 4- logcopy
# 5- calus

mope(){ 

############################################################################################
################################# MOdify PErmissions (MOPE) ################################
############################################################################################

##########################

# prompt for user input directory path
# prompt for user input permissions for chmod
# navigate to target directory and change all files inside to have the input permissions
# prints the directory contents and new permissions
# creates log of actions
# print each change to screen

##########################

# Declaration of variables

permissionlog=~/Documents/ops301/permlog.txt

# Declaration of functions

makespace(){
echo ""
echo "$(date +%H:%M:%S) #################################################"
echo ""
}

#####

targDir(){
    
    #get target
    read -p "Input the target directory: (follow cd format)  " targetDir
    echo ""
    echo -e "ok, $targetDir \n"
    sleep 0.5 

    #logging 
    echo "$(date +%H:%M:%S) received target directory $targetDir from user" >> $permissionlog

}

#####

getPerm(){
    
    #get permissions
    read -p "Input the desired file/directory permissions in ### format: " newPerm
    echo ""
    echo -e "ok, new permissions will be $newPerm for all files contained in $targetDir \n"
    sleep 1

    #logging
    echo "$(date +%H:%M:%S) received new permission assignments for all files" >> $permissionlog

}

#####

changePerm(){
    
    #make list of files
    filearray=("${targetDir}"/*)
   
    #change permissions of all files
    for file in "${filearray[@]}"; 
        do
            # Check if the file exists

            ## I had help writing this loop - https://chat.openai.com/share/85024c22-8960-40c4-81d9-395d79d7c72b

            if [ -e "$file" ]; 
                then
                    # Change the file permissions and echo the result
                    if chmod "$newPerm" "$file"; then
                        
                        #cli output
                        echo -e "$(date +%H:%M:%S) - Changed permissions for $file to $newPerm \n"
                        sleep 1
                        
                        #log
                        echo "$(date +%H:%M:%S) - Changed permissions for $file to $newPerm" >> $permissionlog
                    
                    else

                        #cli output
                        echo -e "$(date +%H:%M:%S) - Failed to change permissions for $file \n"
                        sleep 1
                        
                        #log
                        echo "$(date +%H:%M:%S) - Failed to change permissions for $file" >> $permissionlog
                    fi  
                else
                    echo -e "$file does not exist. \n"
                    sleep 1

                fi
    done

    #show your work
    ls -al $targetDir

    # logging
    ls -al $targetDir >> $permissionlog

    echo -e "\n\n Changes completed and logged as of $(date)"

}

targDir
makespace >> $permissionlog
getPerm
makespace >> $permissionlog
changePerm

}



sad(){

############################################################################################
################################# SEARCH AND DESTROY (SaD) #################################
############################################################################################

# Displays running processes
# Asks the user for a PID
# Kills the process with that PID
# Starts over at step 1 and continues until the user exits with Ctrl + C

#Use a loop so that the script will continuously start over
#ask the user if they would like to kill again, if yes causes the script to finish.

#####################
# Declaration of variables

iter=1

#####################
# Declaration of functions

turnedOn(){
    
    ## initial prompt to begin killing spree
    read -p "Would you like to kill a process? y/n " inp

    ## keeps func running until broken
    while true;
    do

        ## clean break of function
        if [[ $inp == 'no' || $inp == 'n' ]];
        then
            
            ## exit greeting
            echo Thanks for killing! Have a nice day.
            break

        fi
        
        ## display running processes
        ps aux

        ## input to select a identify a target
        read -p "Enter the number of the process you want to end: " ProN

        ## issue a kill order, report success, and if successful show current iteration
        kill -9 ${ProN} && echo "Killed the process with PID #${ProN} (iteration number $iter)"        
        
        ##count up // modify iterations
        iter=$((iter+1))

        ## prompt to stop or continue
        read -p "Would you like to kill again? y/n " inp


    done
}

#####################
# Main

turnedOn

}

cheddir(){

############################################################################################
################################ Check Directory (Cheddar) #################################
############################################################################################


# detects if a file or directory exists
# creates it if it does not exist.

#####################
# Declaration of variables

cheddirray=()                                       ## declares ARRAY

#####################
# Declaration of functions

#####################
# Main

read -p "What directory do you want? " dir          ## initial prompt to check for a directory
sleep 0.5
while true;                                         ## opens infinite while (LOOP)
do
    echo "$dir - great. I'll look... you relax."    ## takes input
    echo " "
    cheddirray+=($dir)                              ## adds input to ARRAY
    sleep 0.5
    if [ -d "$dir" ];                               ## checks for directory (CONDITIONAL)
    then
        echo "I found your, uh, whatever"           ## output if true
        sleep 0.5
        echo " "
    else
        echo "I don't see it anywhere...Sigh... I'll make it for you. No - don't help or anything"  ## output if false
        sleep 0.5
        echo " "
        mkdir -p $dir                                            ## makes the directory

        if [ $? -eq 0 ];                                        ## checks for directory
        then 
            echo "Alright, I made $dir successfully."           ## output if successful
            sleep 0.5
            echo " "
        else
            sleep 0.5
            echo "That didn't feel too good..."                 ## output if failed to create
        fi
    fi
    read -p "Do we have to Cheddir (Ch.Dir.) again? (y/n) " again               ## prompt to continue or break
    if [ "$again" = "y" ];                                                      ## CONDITIONAL for input to continue
    then
        sleep 0.5
        echo "I mean, we've only checked '${cheddirray[@]}' so far, so surrreee - let's keep looking..." ## prints array contents
        sleep 0.5
        echo " "
        read -p "What are we looking for this time? " dir                       ## takes new input
    else
        sleep 0.5
        echo "Thank god that's all I had to do today..."                        ## prints array contents
        sleep 0.5
        echo " "
        echo "~**~ Signing off ~**~"                                            ## breaks LOOP
        break
    fi
done

}

logcopy(){

   # Copies /var/log/syslog to the current working directory
   # Appends the current date and time to the filename
   # Include in your bash script some timestamped echo statements telling the user what is happening at each stage of the script.

##########################
##########################

# Declaration of variables

targetfile=/var/log/syslog

newlogname="Syslog_$(date +'%Y%m%d-%H%M%S')"

#get target
read -p "Input the target directory: (follow cd format)  " targetDir
sleep 0.5
echo ""
echo -e "ok, $targetDir \n"
sleep 1

# Declaration of functions


# Main

echo "Copying $targetfile to $targetDir as of $(date +'%H:%M')"

sleep 0.5

cp $targetfile "$targetDir/$newlogname.txt" && echo "Successfully copied"

echo ""

}


calus(){

############################################################################################
######################### Configure A Linux Ubuntu Server (CALUS) ##########################
############################################################################################

getname(){
    read -p "Enter the username to enable for Samba sharing on this server: " username
    echo $username
    echo ""
    sleep 5
    echo "Okay, setting you up with $username"
    echo ""
    echo ""
}

updater(){
    sudo apt update && sudo apt upgrade -y && echo "###### Upgraded system"
    echo ""
    sleep 2
}

app-fetcher(){
    echo ""
    echo ""
    sudo apt install cifs-utils -y && echo "###### Installed CIFS"
    echo ""
    sleep 2

    echo ""
    echo ""
    sudo apt-get install nano -y && echo "###### Installed nano"
    echo ""
    sleep 2

    echo ""
    echo ""
    sudo apt install samba -y && echo "###### Installed samba"
    echo ""
    sleep 2

    echo ""
    echo ""
    sudo apt-get install ufw -y && echo "###### Installed ufw"
    echo ""
    sleep 2
}

firewall(){
    echo ""
    echo ""
    sudo ufw allow 22 && echo "###### Allowed SSH"
    echo ""
    sleep 2

    echo ""
    echo ""
    sudo ufw allow 139/tcp && sudo ufw allow 445/tcp && echo "###### Allowed TCP fileshare 139/445"
    echo ""
    sleep 2
}

new_acct(){
    echo ""
    echo ""
    sudo adduser $username && echo "###### Created user on Ubuntu with username $username"
    echo ""
    sleep 2

    echo ""
    echo ""
    sudo smbpasswd -a $username && echo "###### Added $username to Samba"
    echo ""
    sleep 2

    echo ""
    echo ""
    sudo smbpasswd -e $username && echo "###### Enabled $username on Samba"
    echo ""
    sleep 2
}

update_smbconf(){
    lines=("[shared]" "path = /home/$username" "writable = yes" "guest ok = no" "read only = no" "create mask = 0777" "directory mask = 0777"
        "server signing = mandatory" "client signing = mandatory" "passdb backend = smbpasswd")

    smb_conf="/etc/samba/smb.conf"

    for line in "${lines[@]}"; do
        echo "$line" | sudo tee -a "$smb_conf" > /dev/null
    done

    echo ""
    echo ""
    echo "###### Modified smb_conf"
    sleep 3
    echo ""

    sudo touch /.autorelabel
}

status-checker(){
    echo ""
    echo ""
    sudo ufw status && sleep 3
    echo ""
    echo ""
    sudo systemctl restart ssh && echo "###### restarted ssh" && sleep 1
    echo ""
    echo ""
    sudo service smbd status && sleep 3
    echo ""
    echo ""
    sudo systemctl restart smbd && echo "###### restarted Samba" && sleep 1
    echo ""
    echo ""
    sudo service ssh status && sleep 3
    echo ""
    echo ""
    echo "###### Reboot your server for changes to take effect."
    echo ""
    echo ""
}


CALUS(){
    getname
    updater
    app-fetcher
    firewall
    new_acct
    update_smbconf
    status-checker
}


CALUS

}


####################################################################################################################
# begin menu

# 1- mope
# 2- sad
# 3- cheddir
# 4- logcopy
# 5- calus

takeprompts(){

clear

while true; do

    echo -e "Would you like to run a shell script? Enter a number 1-5. "
    echo "Here are the options: "
    echo "   1. MOdify PErmissions (MOPE) - uses chmod to change files in a target directory. "
    echo "   2. Search And Destroy (SAD) - lists running processes and gives options to kill them "
    echo "   3. CHEck DIRectory (CHEDDIR) - checks for the existence of a directory and makes it if it doesn't exist "
    echo "   4. Log Copy - copies the system log from /var/ to your target directory "
    echo "   5. Configure A Linux Ubuntu Server (CALUS) - sets up UFW 22, 139, 445 and sends prompts to make a user account and sambe account on the server."
    echo "   'no' to quit"
    read choice

    if [[ $choice == 1 ]]; then
        figlet MOPE -f Modular.flf
        echo ""
        echo ""
        sleep 0.5
        mope 
        sleep 0.5
        read -p "Press Enter to continue"

    elif [[ $choice == 2 ]]; then
        figlet sad -f Modular.flf
        echo ""
        echo ""
        sleep 0.5
        sad
        sleep 0.5
        read -p "Press Enter to continue"

    elif [[ $choice == 3 ]]; then
        figlet Cheddir -f Modular.flf
        echo ""
        echo ""
        sleep 0.5
        cheddir
        sleep 0.5
        read -p "Press Enter to continue"

    elif [[ $choice == 4 ]]; then
        figlet LogCopy -f Modular.flf
        echo ""
        echo ""
        sleep 0.5
        logcopy
        sleep 0.5
        read -p "Press Enter to continue"

    elif [[ $choice == 4 ]]; then
        figlet CALUS -f Modular.flf
        echo ""
        echo ""
        sleep 0.5
        calus
        sleep 0.5
        read -p "Press Enter to continue"

    elif [[ $choice == "no" ]]; then
        sleep 0.5
        figlet "adios motha clucka" -f Modular.flf
        echo ""
        echo "~~"
        echo ""
        break

    else
        sleep 0.5
        figlet "wrong answer sucker" -f Modular.flf
        sleep 0.5
        read -p "Press Enter to continue"
    fi
done
}

takeprompts | lolcat