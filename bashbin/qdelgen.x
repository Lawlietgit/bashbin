#!/bin/bash
echo -n 'please input the first job name:
'
read value
echo -n 'please input the number of jobs to delete:
'
read kaka
lala=`echo $kaka-1|bc -l`
for pos in `seq -f%3.0f 0 1 $lala`
do
newjob=`echo $value+$pos|bc -l`
qdel $newjob
done
