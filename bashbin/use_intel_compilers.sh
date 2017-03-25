#!/bin/bash
# This should be saved as ~/bin/use_intel_compilers.sh

unset INTELDIR
unset INTELVER
unset INTEL_LICENSE_FILE

if [ $# -le 0 ] ; then
    echo "Usage: Please specify one of the following: compiler91, compiler100, compiler110, compiler111, ict400"
    exit 1
fi

. ~/bin/clean_env.sh
  
if [ $1 = "ict400" ] ; then
    export I_MPI_CC=icc
    export I_MPI_FC=ifort
    . /opt/intel/ictce/4.0.0.020/ictvars.sh

    # Kluge for MKL
    export LD_PRELOAD=${MKLROOT}/lib/em64t/libmkl_core.so:${MKLROOT}/lib/em64t/libmkl_sequential.so
elif [ $1 = "compiler91" -o $1 = "compiler100" ] ; then
    for product in  icc ifort idb ; do
        . /opt/intel/$1/$product/bin/${product}vars.sh
    done
elif [ $1 = "compiler110" -o $1 = "compiler111" ] ; then
    for product in icc ifort idb ; do
        . /opt/intel/$1/$product/${product}vars.csh intel64
    done
fi

