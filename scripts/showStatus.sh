#!/bin/bash
#hosts="hering"
#hosts="hering koffka young gibson"
#hosts="kanisza julesz stevens johansson fechner gregory marr koehler"
#hosts="kanisza julesz stevens johansson fechner "
#hosts="kanisza julesz fechner hering stevens"


user=dwc
ssh_id=~/.ssh/id_rsa
domain=informatik.tu-cottbus.de


local_image_dir=./target
local_settings_dir=./
local_code_dir=./
echo $1

if [ ! -z $1 ] && test -e $1; then
   echo 'Using' $1
   source $1
else
    echo 'Using MachineSettings.txt'
    source MachineSettings.txt
fi


echo $domain
# derived settings
code_dir=`basename $local_code_dir`
image_dir=`basename $local_image_dir`
result_dir=`basename $local_result_dir`

SSH_FLAGS="-o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no -i $ssh_id"
RSYNC_FLAGS="--exclude=\".*\" --timeout=5"
MATLAB_FLAGS="-nodisplay -nosplash -nodesktop"


    echo "Check status..."

    for h in $hosts; do
      
	n=`ssh $SSH_FLAGS $user@$h.$domain "pgrep -u $user MATLAB | wc -l"`
        h=`printf "%-10s" "$h"`
        if [ "$n" == "" ]; then
            echo -e "$h is \e[1;31mOFFLINE\e[0m"
        elif [ "$n" == "0" ]; then
            echo -e "$h is \e[1;33mIDLE\e[0m (give him something to do!)"
        else
            echo -e  "$h is happily \e[1;32mRUNNING $n\e[0m jobs :-)"
        fi
    done

    
