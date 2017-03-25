#!/bin/bash
echo -n 'please input the number of atoms:
'
read number
echo -n 'please input the kmesh sampling:
'
read kmesh
for pos in `seq -f%2.0f 1 1 14`
do
dis=`echo $pos*0.1-0.1|bc -l`
cd LS.$number.$kmesh.$dis
rm -f LS.$number.$kmesh.$dis.sub CHG POSCAR INCAR EIGENVAL OSZICAR PCDAT CHGCAR DOSCAR IBZKPT OUTCAR vasprun.xml XDATCAR stdout *.sub.o*
cp ../INCAR .
cp ../para.sub .
mv CONTCAR POSCAR
mv para.sub LS.$number.$kmesh.$dis.sub
qsub LS.$number.$kmesh.$dis.sub
cd ..
done

