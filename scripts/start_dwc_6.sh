#!/bin/bash

#USAGE:sh ./start_dwc.sh [ IMAGE_FILE | "ALL"] [ SETTINGS_FILE | "ALL"]


#hosts="kanisza julesz fechner gregory marr koehler"
domain=informatik.tu-cottbus.de
user=dwc
ssh_id=~/.ssh/id_rsa


local_image_dir=./target
local_settings_dir=./
local_code_dir=./


if [ ! -z $3 ] && test -e $3; then
   echo 'Using' $3
   source $3
else
    echo 'Using MachineSettings.txt'
    source MachineSettings.txt
fi


# derived settings
code_dir=`basename $local_code_dir`
image_dir=`basename $local_image_dir`
result_dir=`basename $local_result_dir`

SSH_FLAGS="-o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no -i $ssh_id"
RSYNC_FLAGS="--exclude=\".*\" --timeout=5"
MATLAB_FLAGS="-nodisplay -nosplash -nodesktop"

is_online() { # is_online HOST
    ping -c 1 -t 3 -q $1.$domain 2>/dev/null 1>/dev/null
    #ping -c 1 -t 3 -q $1.$domain 
}

matlab_running() { # matlab_running HOST
    is_online $1 || return 1
    n=`ssh $SSH_FLAGS $user@$1.$domain "pgrep -u $user MATLAB | wc -l"`
}


stop_matlab() { # stop_matlab HOST
    is_online $1 || return 1
   
    ssh $SSH_FLAGS $user@$1.$domain "pgrep -u $user MATLAB && killall -u $user MATLAB" 1>/dev/null
}

stop_everything() { # stop_everything
    for h in $hosts; do
        is_online $h || return 1
        ssh $SSH_FLAGS $user@$h.$domain "pkill -u $user" 2>/dev/null 1>/dev/null
    done
}

get_jobname() { # get_jobname IMAGE_FILE SETTINGS_FILE
    #test -f "$1" || { echo "MISSING $1"; return 1; }
    test -f "$2" || { echo "MISSING $2"; return 1; }
    echo `basename -s .png $1`_`basename -s .setting  $2`
}

create_main() { # create_main IMAGE_FILE SETTINGS_FILE

    resultname=`get_jobname "$1" "$2"` || return 1
    settings=`echo $(sed "s|^|,|" $2)`

    echo "ImageInpainting_FullAmoeba_June2017(struct('machine', '$h', 'theImage', '`basename $1`','imagePath','$remote_base_dir/$image_dir/','resultsDir','$result_dir',  'logfile', '$remote_base_dir/$result_dir/$resultname.log' $settings)); quit()"
  

}

start_matlab() { # start_matlab HOST MATLAB_CODE
    is_online $1 || return 1
    # NOTE: cshell redirect different from bash
    #echo $SSH_FLAGS $user@$1.$domain "nohup matlab" $MATLAB_FLAGS "-r \"$2\" >& $remote_base_dir/log  & " 
    #ssh $SSH_FLAGS $user@$1.$domain "nohup matlab $MATLAB_FLAGS -r \"$2\" >& ./log  & "
    ssh -t $SSH_FLAGS $user@$1.$domain "cd $remote_base_dir/$code_dir  && nohup /usr/local/bin/matlab $MATLAB_FLAGS -r $2  >& ./log  & "
}


upload_code() { # upload_code
    echo "Update code..."
    for h in $hosts; do
        is_online $h || continue
        echo "...updating " $h
        # create result dir
        ssh $SSH_FLAGS $user@$h.$domain "mkdir -p $remote_base_dir/$result_dir" 1>/dev/null  || exit 1
        # copy code
        rsync $RSYNC_FLAGS -r -L $local_code_dir $user@$h.$domain:$remote_base_dir || exit 1
        # copy images
        rsync $RSYNC_FLAGS -r -L $local_image_dir $user@$h.$domain:$remote_base_dir  || exit 1
    done
}

download_results() { # download_results
    echo "Download results..."
    for h in $hosts; do
        is_online $h || continue
        rsync $RSYNC_FLAGS -r -L $user@$h.$domain:$remote_base_dir/$result_dir `dirname $local_result_dir`
    done
}

delete_results() { # delete_results
    echo "Delete results..."
    for h in $hosts; do
        is_online $h || continue
        ssh $SSH_FLAGS $user@$h.$domain "rm -r $remote_base_dir/$result_dir; mkdir -p $remote_base_dir/$result_dir"
    done
}

delete_everything() { # delete_results
    echo "Delete results..."
    for h in $hosts; do
        is_online $h || continue
        ssh $SSH_FLAGS $user@$h.$domain "rm -r $remote_base_dir; mkdir -p $remote_base_dir"
    done
}

get_free_slot() { # get_free_slot --> HOST
    slot=""
    for h in $hosts; do
	#test is_online || echo $h " is offline :( "
	is_online $h || continue
	n=`ssh $SSH_FLAGS $user@$h.$domain "pgrep -u $user MATLAB | wc -l"`
	#echo $h " is online and has " $n " copies of matlab running!" 
	#echo 
	test $n -lt  $max_processes || continue  && { slot=$h; break; } 
    done
    echo $slot
}

show_status() { # show_status
    echo "Check status..."

    for h in $hosts; do
        n=`matlab_running $h`
        h=`printf "%-10s" "$h"`
        if [ "$n" == "" ]; then
            echo -e "$h is \e[1;31mOFFLINE\e[0m"
        elif [ "$n" == "0" ]; then
            echo -e "$h is \e[1;33mIDLE\e[0m (give him something to do!)"
        else
            echo -e  "$h is happily \e[1;32mRUNNING $n\e[0m jobs :-)"
        fi
    done
}


upload_code
#download_results  && delete_results


test "$1" == "ALL" && image=`ls $local_image_dir` || image=$1
test "$2" == "ALL" && setting=`ls $local_settings_dir` || setting=$2


for i in $image; do
    for s in $setting; do
        i=$local_image_dir/`basename -s .png "$i"`
        i2=$local_image_dir/`basename -s .png "$i"`.png        
        s=$local_settings_dir/`basename -s .setting "$s"`.setting
        test -f $i2 || { echo "MISSING: $i2"; continue; }
        test -f $s || { echo "MISSING: $s"; continue; }
	 #echo $i
	 #echo $s
	 #echo

        # find free machine (or wait)
        slot=""
	echo "looking for free machines"
        while test -z "$slot"; do
	    for h in $hosts; do
		#test is_online #|| echo $h " is offline :( "
		#test is_online || echo $h " is offline :( "
		is_online $h || continue
		n=`ssh $SSH_FLAGS $user@$h.$domain "pgrep -u $user MATLAB | wc -l"`
		#echo $h " is online and has " $n " copies of matlab running!" 
		test $n -lt  $max_processes || continue  && { slot=$h; break; } 
	    done
            #test $slot || { echo "Hmmm...It would seem that everyone is busy. Please wait a few seconds and I will check again..."; sleep 10; }
            test $slot || { printf "." ;  sleep 100; }
        done

	#echo $settings
       
        #echo "START `get_jobname $i $s` @ $h"
	#echo

	#sleep 10s # give matlab time to start

        #create matlab main
	name=tempMatlabCommands
	if [[ -e $name.m ]] ; then
	    myNum=0
	    while [[ -e $name$myNum.m ]] ; do
		let myNum++
	    done
	    name=$name$myNum
	fi

        main=`create_main $i $s $h`
	#echo $name.m
	echo "$main" >$name.m
	echo $main
	rsync $RSYNC_FLAGS -r -L $name.m $user@$h.$domain:$remote_base_dir  || exit 1
        #start_matlab $h "$main"  1>/dev/null
        start_matlab $h $name
	#1>/dev/null


    done
done
echo "Finished!"

