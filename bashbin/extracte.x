#!/bin/bash
for dir in *
    do  if [ -d $dir ]; then
	echo $dir
	cd $dir
	vasp_chkstatus OUTCAR|tail -1
        cd .. 
      	fi
done
