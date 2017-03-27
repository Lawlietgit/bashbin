for dir in LS.*; do


f1=`grep -A19 TOTAL-F $dir/OUTCAR | tail -18 | \
    awk '{if(NR==6) print $4,$5,$6}'`
f2=`grep -A19 TOTAL-F $dir/OUTCAR | tail -18 | \
    awk '{if(NR==15) print $4,$5,$6}'`

r1=`grep -A19 TOTAL-F $dir/OUTCAR | tail -18 | \
    awk '{if(NR==6) print $1,$2,$3}'`
r2=`grep -A19 TOTAL-F $dir/OUTCAR | tail -18 | \
    awk '{if(NR==15) print $1,$2,$3}'`

f1av=`echo $f1 $f2 | awk '{print ($1-$4)/2.0, ($2-$5)/2, ($3-$6)/2.0}'`
rcm=`echo $r1 $r2 | awk '{print ($1+$4)/2.0, ($2+$5)/2, ($3+$6)/2.0}'`

echo $f1 $f2 $r1 $r2

r12=`echo $r1 $rcm | awk '{print ($1-$4), ($2-$5), ($3-$6)}'`

d=`echo $r12 | awk '{print sqrt(($1*2)^2+($2*2)^2+($3*2)^2)}'`

t=`echo $r12 $f1av | awk \
'{
  x=$1 
  y=$2
  z=$3
  fx=$4 
  fy=$5
  fz=$6
  tx=x*fz-z*fx
  ty=z*fx-x*fz
  tz=x*fy-y*fx
  print sqrt(tx*tx + ty*ty + tz*tz)
  }'`

F=`grep F= $dir/stdout | tail -1 | awk '{print $3}'`
echo $d $t $F
done | sort -nk 1


