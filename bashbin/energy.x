#!/bin/bash
echo -n 'please input the number of atoms:
'
read number
echo -n 'please input the kmesh sampling:
'
read kmesh
rm -f energy$number$kmesh.dat
for pos in `seq -f%2.0f 1 1 14`
do
dis=`echo $pos*0.1-0.1|bc -l`
echo $dis
cd LS.$number.$kmesh.$dis
ene=`more OSZICAR|tail -1|awk '{printf "%12.7f",$3}'`
echo $ene
rm -f energy.dat
cd ..
echo $dis $ene >> energy$number$kmesh.dat
done

