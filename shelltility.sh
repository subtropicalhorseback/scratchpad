#!/bin/bash

fontgrab(){
    sudo wget https://raw.githubusercontent.com/titusgroen/figlet-fonts/master/Modular.flf -O /usr/share/figlet/Modular.flf &
    wget_pid=$!
    wait $wget_pid
    clear
    echo "I downloaded a font for figlet to /usr/share/figlet/Modular.flf"
}

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

hellothere(){

    ############################################################################################
    ###################################### HelloWorld ##########################################
    ############################################################################################

    str1="hello there\n"
    str2="General Kenobi!?\n"
    str3="I hate sand.\n"
    str4="Hello World\n"

    array1=("$str1" "$str2" "$str3" "$str4")

    for thing in "${array1[@]}"; do
        sleep 1
        echo -e "$thing"
    done 

}

loghog(){
    ##########################################################
    #  ___      _______  _______  __   __  _______  _______  #
    # |   |    |       ||       ||  | |  ||       ||       | #
    # |   |    |   _   ||    ___||  |_|  ||   _   ||    ___| #
    # |   |    |  | |  ||   | __ |       ||  | |  ||   | __  #
    # |   |___ |  |_|  ||   ||  ||       ||  |_|  ||   ||  | #
    # |       ||       ||   |_| ||   _   ||       ||   |_| | # 
    # |_______||_______||_______||__| |__||_______||_______| #
    ##########################################################
    ##########################################################
    # Declaration of variables

    syslog="/var/log/syslog"
    kernlog="/var/log/kern.log"
    authlog="/var/log/auth.log"
    dpkglog="/var/log/dpkg.log"
    bootlog="/var/log/boot.log"
    ufwlog="/var/log/ufw.log"
    wtmplog="/var/log/wtmp"

    ##########################################################
    # Take destination directory

    read -p "This script will let you backup log files before deletion. Please enter the target directory to save zipped backups (absolute path): " targetdir
    echo ""
    sleep 0.5
    if [ ! -d "$targetdir" ]; then
        mkdir -p "$targetdir"
        echo "Target directory created: $targetdir"
    fi
    echo -e "Backing logs up to $targetdir before deletion\n"
    sleep 1

    ##########################################################
    ##########################################################
    # Declaration of functions

    backup_and_compress_log() {

        local log_file="$1"

        # Check if syslog file exists
        if [ -f "$log_file" ]; then

            # Before compression
            original_size=$(du -h "$log_file" | cut -f1)
            echo "Original size of $log_file: $original_size"
            sleep 1
              
            # make sure i have permissions
            sudo chmod 755 "$log_file"
            sudo chmod 755 "$targetdir"
            echo -e "\nCopying log file from $log_file\n\n"
            sleep 1
        
            # cp and gzip with timestamp - need to use a variable because gzip gets confused
            timestamp=$(date +%Y%m%d-%H:%M:%S)
            cp "$log_file" "$targetdir/log-$timestamp"
            sleep 0.5
            gzip "$targetdir/log-$timestamp"
        
            # check for success
            if [ $? -eq 0 ]; then
                echo -e "Log file copied and zipped successfully.\n"
                # After compression
                compressed_size=$(du -h "$targetdir/log-$timestamp.gz" | cut -f1)
                echo -e "Compressed size of log backup: $compressed_size\n"
                sleep 2

                # Calculate percentage difference
                percent_diff=$(awk "BEGIN {print (($original_size / $compressed_size - 1) * 100)}")
                # Calculate size difference in bytes
                size_diff=$(awk "BEGIN {print ($original_size - $compressed_size)}")

                # Print the result
                echo "The original size of $log_file was $original_size, and the compressed size is $compressed_size."
                echo "The file size reduced by approximately $percent_diff% (${size_diff}B) after compression."
                sleep 2
            
                # rm with wildcard
                sudo rm "$targetdir/log-$timestamp"*
                sudo rm "$log_file"
                echo -e "Removed copied file (unzipped) and removed original log.\n\n"
                sleep 2


            else
                echo -e "Failed to copy and zip the log file. Please check permissions and try again.\n\n"
                sleep 2

            fi
        else
            echo -e "Error: The log file does not exist at $log_file.\n\n"
            sleep 2
        fi
    }

    ##########################################################
    ##########################################################
    # Declaration of logpicker function

    logpicker() {

        echo " Welcome to the"
        echo "##########################################################"
        echo "#  ___      _______  _______  __   __  _______  _______  #"
        echo "# |   |    |       ||       ||  | |  ||       ||       | #"
        echo "# |   |    |   _   ||    ___||  |_|  ||   _   ||    ___| #"
        echo "# |   |    |  | |  ||   | __ |       ||  | |  ||   | __  #"
        echo "# |   |___ |  |_|  ||   ||  ||       ||  |_|  ||   ||  | #"
        echo "# |       ||       ||   |_| ||   _   ||       ||   |_| | #"
        echo "# |_______||_______||_______||__| |__||_______||_______| #"
        echo "##########################################################"
        echo -e "##########################################################\n\n\n"
        sleep 5
        while :; do
            echo -e "1) syslog: This log is located at $syslog. It contains general system messages from various components and applications.\n2) kern.log: This log is located at $kernlog. It logs kernel-related messages, including hardware and device driver messages.\n3) auth.log: This log is located at $authlog. It records authentication-related messages, including user logins and authentication attempts.\n4) dpkg.log: This log is located at $dpkglog. It logs package management activities, including installations, removals, and upgrades.\n5) boot.log: This log is located at $bootlog. It contains information about the boot process, including messages from the kernel and services started during boot.\n6) ufw.log: This log is located at $ufwlog. It logs messages related to the Uncomplicated Firewall (UFW) configuration and activities.\n7) wtmp log: This log is located at $wtmplog. It is a system log file on Unix and Unix-like operating systems that records user login and logout activity.\n8) Choose another specific directory or file to backup to $targetdir.\n\n"

            read -p "Enter the number of the log to backup and clear (1-7), 8 to define a different directory, or 9/no/exit/escape to end session: " choice

            case $choice in
                0) echo "Exiting."; exit ;;
                1) echo -e "Got it, looking for truffles in $syslog\n\n"; log_file=$syslog ;;
                2) echo -e "Got it, looking for truffles in $kernlog\n\n"; log_file=$kernlog ;;
                3) echo -e "Got it, looking for truffles in $authlog\n\n"; log_file=$authlog ;;
                4) echo -e "Got it, looking for truffles in $dpkglog\n\n"; log_file=$dpkglog ;;
                5) echo -e "Got it, looking for truffles in $bootlog\n\n"; log_file=$bootlog ;;
                6) echo -e "Got it, looking for truffles in $ufwlog\n\n"; log_file=$ufwlog ;;
                7) echo -e "Got it, looking for truffles in $wtmplog\n\n"; log_file=$wtmplog ;;
                8) echo -e "Ok, let's talk about it."; read -p "Please enter the log location to search for, backup, and remove (absolute path): " user_log; echo -e "\n Got it, $user_log\n\n"; log_file=$user_log ;;
                9|[Nn]|[Nn][Oo]|[Ee][Xx][Ii][Tt]|[Ee][Ss][Cc][Aa][Pp][Ee]) clear; sleep 1; echo "       Oink Oink.."; echo -e "\n\n\n       ~~"; exit ;;
                *) echo "You Chose..."; sleep 1; echo "poorly. (try again)"; sleep 2 ;;
            esac

            if [ "$choice" -ge 1 ] && [ "$choice" -le 8 ]; then
                backup_and_compress_log "$log_file"
            fi

            echo ""
            read -p "Press Enter to continue"

        done
    }

    ##########################################################
    ##########################################################
    # Main
    logpicker

    # End
}

####################################################################################################################
####################################################################################################################

takeprompts(){

    clear

    while true; do
        echo -e "Would you like to run a shell script? Enter a number 1-9. "
        echo "Here are the options: "
        echo "   1. MOdify PErmissions (MOPE) - uses chmod to change files in a target directory. "
        echo "   2. Search And Destroy (SAD) - lists running processes and gives options to kill them "
        echo "   3. CHEck DIRectory (CHEDDIR) - checks for the existence of a directory and makes it if it doesn't exist "
        echo "   4. Log Copy - copies the system log from /var/ to your target directory "
        echo "   5. Configure A Linux Ubuntu Server (CALUS) - sets up UFW 22, 139, 445 and sends prompts to make a user account and sambe account on the server."
        echo "   6. Hello World - send a useless echo of Hello World to the screen."
        echo "   7. Ping Loopback IP - sends an ICMP ping to this device's loopback address"
        echo "   8. IP Info - prints ip info for this device to the screen."
        echo "   9. LogHog: select system files to backup and delete, particularly system logs in /var/"
        echo "or type 'no' to quit, you quitter"
        read choice

        case $choice in
            1) echo "You Chose MOPE" | figlet -f Modular.flf; sleep 0.5; mope; sleep 0.5; read -p "Press Enter to continue" ;;
            2) echo "You Chose SAD" | figlet -f Modular.flf; sleep 0.5; sad; sleep 0.5; read -p "Press Enter to continue" ;;
            3) echo "You Chose CHEDDIR" | figlet -f Modular.flf; sleep 0.5; cheddir; sleep 0.5; read -p "Press Enter to continue" ;;
            4) echo "You Chose LogCopy" | figlet -f Modular.flf; sleep 0.5; logcopy; sleep 0.5; read -p "Press Enter to continue" ;;
            5) echo "You Chose CALUS" | figlet -f Modular.flf; sleep 0.5; calus; sleep 0.5; read -p "Press Enter to continue" ;;
            6) echo "You Chose Hello World" | figlet -f Modular.flf; sleep 0.5; echo "running"; sleep 0.5; hellothere; sleep 0.5; read -p "Press Enter to continue" ;;
            7) echo "You Chose Self-Ping" | figlet -f Modular.flf; sleep 0.5; echo "Sending 8 pings"; ping -c 8 127.0.0.1; sleep 0.5; read -p "Press Enter to continue" ;;
            8) echo "You Chose IP Info" | figlet -f Modular.flf; sleep 0.5; ip -o -4 addr show | awk '{print $1, $2, $4}'; sleep 0.5; read -p "Press Enter to continue" ;;
            9) echo "You Chose LogHog" | figlet -f Modular.flf; sleep 0.5; loghog; sleep 0.5; read -p "Press Enter to continue" ;;
            [Nn][Oo]|[0]|[Nn]) echo "adios" | figlet -f Modular.flf; echo "motha clucka" | figlet -f Modular.flf; echo ""; echo "~~"; echo ""; break ;;
            *) echo -e "wrong \nanswer \nsucker" | figlet -f Modular.flf; sleep 0.5; read -p "Press Enter to continue" ;;
        esac
    done
}

####################################################################################################################
####################################################################################################################

sudo cd ~/Documents/

fontgrab &
sleep 5
takeprompts | lolcat
