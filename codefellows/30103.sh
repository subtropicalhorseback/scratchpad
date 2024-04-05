#!/bin/bash

# Script Name: 30103 Ops Challenge: Change file permissions
# Author: Ian
# Date of Latest Revision: 29 Nov 23

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
    sleep 1

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


# Main

targDir
makespace >> $permissionlog
getPerm
makespace >> $permissionlog
changePerm

# End
