#!/bin/bash
rm -f FmE.dat
for pos in `seq -f%4.0f -2 1 12`
do  cd F-\_$pos
    E=`tail -1 OSZICAR|awk '{printf "%12.7f \n", $5}'`
    cd ..
    echo $pos $E >> FmE.dat
done  
    
