#!/bin/bash
# This should be saved as ~/bin/clean_env.sh
  
# Library paths
unset LD_LIBRARY_PATH
unset DYLD_LIBRARY_PATH
unset INTEL_LICENSE_FILE
unset MPICHDIR
  
# Matlab
export USE_MATLAB_DIR=/opt/matlab
  
export PATH=/opt/torque/bin:/opt/torque/sbin:/opt/maui/bin:/usr/local/bin:/usr/java/default/bin:/opt/vmd/bin:/opt/namd/bin:/opt/mathematica/bin:/opt/matlab/bin:/usr/lpp/mmfs/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/libexec:/usr/kerberos/bin:/usr/X11R6/bin:~/bin
  
export MANPATH=/opt/torque/man:/usr/local/share/man:/usr/share/man:/usr/X11R6/share/man

