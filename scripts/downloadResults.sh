#!/bin/bash
domain=informatik.tu-cottbus.de
user=dwc
ssh_id=~/.ssh/id_rsa

local_image_dir=./target
local_settings_dir=./settings
local_code_dir=./

if [ ! -z $1 ] && test -e $1; then
   echo 'Using' $1
   source $1
else
    echo 'Using MachineSettings.txt'
    source MachineSettings.txt
fi


# derived settings
code_dir=`basename $local_code_dir`
image_dir=`basename $local_image_dir`
result_dir=`basename $local_result_dir`

SSH_FLAGS="-o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no -i $ssh_id"
RSYNC_FLAGS="-az --exclude=\".*\" --timeout=5"
MATLAB_FLAGS="-nodisplay -nosplash -nodesktop"

is_online() { # is_online HOST
    if [ "$domain" == "" ]; then
       ping -c 1 -t 3 -q $1 2>/dev/null 1>/dev/null
    else
       ping -c 1 -t 3 -q $1.$domain 2>/dev/null 1>/dev/null
    fi	   
    #ping -c 1 -t 3 -q $1.$domain 2>/dev/null 1>/dev/null
    #ping -c 1 -t 3 -q $1.$domain 
}


download_results() { # download_results
    for h in $hosts; do
	echo "Downloading results from" $h
        is_online $h || continue
	#echo rsync $RSYNC_FLAGS -r -L --include='*.png' --include='*/' --exclude='*' $user@$h:$remote_base_dir/$result_dir/  $toBeSaved_dir
	if [ "$domain" == "" ]; then
            #rsync $RSYNC_FLAGS -r -L --include='*.png' --include='*/' --exclude='*' $user@$h:$remote_base_dir/$result_dir/  $toBeSaved_dir
            rsync $RSYNC_FLAGS -r -L -t $user@$h:$remote_base_dir/$result_dir/*.png  $toBeSaved_dir
	else
            rsync $RSYNC_FLAGS -r -L -t  $user@$h.$domain:$remote_base_dir/$result_dir/*.png  $toBeSaved_dir
            #rsync $RSYNC_FLAGS -r -L --include='*.png' --include='*/' --exclude='*' $user@$h.$domain:$remote_base_dir/$result_dir  $toBeSaved_dir
	fi
    done
}

download_results
	

    
