AC_DEFUN([SX_IF_CHECKNUMLIBS], [
if test x"$ac_cv_enable_numlibschecks" = x"yes"; then
   $1
fi
])
AC_DEFUN([SX_CHECK_NUMLIBS], [


AC_MSG_NOTICE([Setting up numlibs])


ORIG_LIBS=$LIBS
LIBS="-lm $LIBS"

# --- some numeric libs require FORTRAN
AC_CHECK_LIB(gfortran, rand)
AC_CHECK_LIB(gfortran, _gfortran_copy_string, 
             [AC_DEFINE([HAVE_GFORTRAN_COPY_STRING],[1],
             [Define to 1 if gfortran does not come with gcc bug 33647])])
SX_BLAS_LIBS="$SX_BLAS_LIBS $LIBS"

if test -d ../3rd-party ; then
   SX_PARAM_NUMLIBS="yes"
else
   SX_PARAM_NUMLIBS="no"
fi
SX_PARAM_ATLAS="yes"
SX_PARAM_ACML="no"
SX_PARAM_MKL="no"
SX_PARAM_GOTO="no"
SX_PARAM_MKLPATH="null"
SX_PARAM_FFTW="yes"
SX_PARAM_ACMLFFT="no"
SX_PARAM_MKLFFT="no"

configFile=$1
if test -n "$configFile"; then
   if test -f "$configFile"; then
      . $configFile
   fi
fi


SX_ARG_WITH(  [numlibs], [.], [NUMLIBS], [$SX_PARAM_NUMLIBS],
              [absolute paths to top level folder for external libraries])
SX_ARG_ENABLE([numlibschecks], [NUMLIBS_CHECKS], [no], 
              [check that numlibs can be used])
if echo x"$ac_cv_enable_numlibschecks" | grep -q '^x *-' ; then
  AC_MSG_NOTICE([Appending $ac_cv_enable_numlibschecks to linker flags for checking numlibs])
   LIBS="$ac_cv_enable_numlibschecks $LIBS"
   ac_cv_enable_numlibschecks="yes"
fi
SX_ARG_ENABLE([atlas],    [USE_ATLAS], [$SX_PARAM_ATLAS], 
              [compile package with ATLAS support])
SX_ARG_ENABLE([acml],     [USE_ACML], [$SX_PARAM_ACML], 
              [compile package with AMD Core Math Library support])

SX_ARG_WITH(  [mklpath], [.], [MKLPATH], [$SX_PARAM_MKLPATH],
              [absolute path to the Intel MKL top level folder])
SX_ARG_ENABLE([mkl],      [USE_INTEL_MKL], [$SX_PARAM_MKL], 
              [compile package with Intel Math Kernel Library support])
SX_ARG_ENABLE([goto],     [USE_GOTO], [$SX_PARAM_GOTO], 
              [compile package with GotoBLAS support])
SX_ARG_ENABLE([fftw],     [USE_FFTW],  [$SX_PARAM_FFTW], 
              [compile package with FFTW support])
SX_ARG_ENABLE([mklfft],   [USE_MKL_FFT],  [$SX_PARAM_MKLFFT], 
              [compile package with MKL's FFT support])
SX_ARG_ENABLE([acmlfft],  [USE_ACML_FFT],  [$SX_PARAM_ACMLFFT], 
              [compile package with ACML's FFT support])
SX_ARG_ENABLE([mpi],      [USE_MPI], [no], 
              [compile package with Message-Passing Interface support])
SX_ARG_ENABLE([openmp],   [USE_OPENMP], [no], 
              [compile package with OpenMP support])
SX_ARG_ENABLE([hdf5], [USE_HDF5], [no], [compile package with HDF5 support])


# --- check mutual exclusions
if test x"${ac_cv_enable_acml}"  = x"yes" \
     -a x"${ac_cv_enable_atlas}" = x"yes"; then
   AC_MSG_ERROR([Cannot use ACML and ATLAS simultaneously.])
fi
if test x"${ac_cv_enable_acml}"  = x"yes" \
     -a x"${ac_cv_enable_mkl}" = x"yes"; then
   AC_MSG_ERROR([Cannot use ACML and MKL simultaneously.])
fi
if test x"${ac_cv_enable_acml}"  = x"yes" \
     -a x"${ac_cv_enable_goto}" = x"yes"; then
   AC_MSG_ERROR([Cannot use ACML and GotoBLAS simultaneously.])
fi
if test x"${ac_cv_enable_mkl}"  = x"yes" \
     -a x"${ac_cv_enable_goto}" = x"yes"; then
   AC_MSG_ERROR([Cannot use MKL and GotoBLAS simultaneously.])
fi
if test x"${ac_cv_enable_atlas}"  = x"yes" \
     -a x"${ac_cv_enable_goto}" = x"yes"; then
   AC_MSG_ERROR([Cannot use ATLAS and GotoBLAS simultaneously.])
fi
if test x"${ac_cv_enable_mkl}"  = x"yes" \
     -a x"${ac_cv_enable_atlas}" = x"yes"; then
   AC_MSG_ERROR([Cannot use MKL and ATLAS simultaneously.])
fi
if test x"${ac_cv_enable_acmlfft}" = x"yes" \
     -a x"${ac_cv_enable_fftw}"    = x"yes"; then
   AC_MSG_ERROR([Cannot use ACML's FFT and FFTW interface simultaneously.])
fi

# If automatic, try build and prefix directories
if test x"$ac_cv_with_numlibs" = x"yes"; then
   ac_cv_with_numlibs=""
   dirs=`cd .. && pwd`/3rd-party;
   #
   if test -d $prefix ; then
      dirs="$dirs "`cd $prefix && pwd`/3rd-party
   fi
   for dir in $dirs ; do
      if test -d $dir/include -a -d $dir/lib ; then
         ac_cv_with_numlibs="$ac_cv_with_numlibs $dir"
      fi
   done
   if test x"$ac_cv_with_numlibs" = x; then
      SX_IF_CHECKNUMLIBS([
         AC_MSG_ERROR([Failed to find numlibs in $dirs !
   Specify path with --with-numlibs=... or use --without-numlibs])
      ])
      # just hope that they will work...
      for dir in $dirs ; do
         ac_cv_with_numlibs="$ac_cv_with_numlibs $dir"
      done
   fi
fi

if test x"$ac_cv_with_numlibs" = x"no"; then
   ac_cv_with_numlibs=""
fi

# add numlibs top levels to library and include search path
for dir in `echo "$ac_cv_with_numlibs" | sed -e's/:/ /g'` ; do
   AC_MSG_NOTICE([Adding include path $dir/include])
   CPPFLAGS="$CPPFLAGS -I$dir/include"
   AC_MSG_NOTICE([Adding library path $dir/lib])
   LDFLAGS="$LDFLAGS -L$dir/lib"
done

   
# MKL include and library paths
if test x"${ac_cv_enable_mkl}"  = x"yes"; then
   if test x"$ac_cv_with_mklpath" = x"null"; then
      # we require that the path to MKL is explicitly given
      AC_MSG_ERROR([Cannot find Intel MKL.  Use the flag --with-mklpath to point to an MKL installation.])
   fi
   AC_CHECK_FILE([$ac_cv_with_mklpath/include/mkl.h], [],
                 [AC_MSG_ERROR([Cannot find Intel MKL.  Use the flag --with-mklpath to point to an MKL installation.])]
   )
   if test -d "$ac_cv_with_mklpath" ; then
     ac_cv_with_mklpath=`cd $ac_cv_with_mklpath; pwd`
   fi
   CPPFLAGS="$CPPFLAGS -I$ac_cv_with_mklpath/include"

   # find the actual lib path
   if test -d ${ac_cv_with_mklpath}/lib/em64t ; then
      mkllibpath=`cd ${ac_cv_with_mklpath}/lib/em64t && pwd`
   elif test -d ${ac_cv_with_mklpath}/lib/intel64 ; then
      mkllibpath=`cd ${ac_cv_with_mklpath}/lib/intel64 && pwd`
   else
      AC_MSG_ERROR([Cannot find Intel MKL library path. Expected ${ac_cv_with_mklpath}/lib/intel64 or  ${ac_cv_with_mklpath}/lib/em64t ])
   fi
     
   # cxxname is set in sxcompflags.m4
   case "$cxxname" in
      g++)
         LDFLAGS="-L${mkllibpath} -Wl,-rpath=${ac_cv_with_mklpath}/lib/intel64 ${LDFLAGS}"
         mkl_thread=mkl_gnu_thread
         ;;
      icc|icpc)
         LDFLAGS="-L${mkllibpath} -Xlinker -rpath=${mkllibpath} ${LDFLAGS}"
         mkl_thread=mkl_intel_thread
         ;;
      *)
         AC_MSG_ERROR([Intel MKL is not supported for your compiler $CXX.])
   esac
fi

# --- Determine suitable set of numlibs
if test x"$ac_cv_enable_fftw" = x"yes"; then
   SX_FFT_LIBS="-lfftw3"
   SX_IF_CHECKNUMLIBS([
      AC_CHECK_HEADER([fftw3.h],,[AC_MSG_ERROR([Cannot find fftw3.h])] )
      AC_CHECK_LIB([fftw3], [fftw_plan_dft], 
                   [],
                   [AC_MSG_ERROR([Cannot link against FFTW library])])
    ])

   if test x"$ac_cv_enable_openmp" = x"yes" ; then
      SX_FFT_LIBS="-lfftw3_threads -lfftw3"
      SX_IF_CHECKNUMLIBS([
         AC_SEARCH_LIBS([fftw_init_threads], [fftw3_threads], [],
                      [AC_MSG_ERROR([Cannot link against threaded FFTW library])],
                      [-lfftw3])
      ])
   fi
fi

SX_NETCDF_LIBS="-lnetcdf"
SX_IF_CHECKNUMLIBS([
   AC_CHECK_LIB([netcdf], [nc_get_vars], [],
                [AC_MSG_ERROR([Cannot link against netCDF library])])
])

if test x"$ac_cv_enable_acml"     = x"yes" \
     -o x"$ac_cv_enable_acmlfft"  = x"yes"; then

   # does ACML provide fast math support?
   AC_CHECK_LIB([acml_mv], [fastpow], [SX_BLAS_LIBS="-lacml_mv $SX_BLAS_LIBS"])

   case "${host}" in
      *-mingw32*)
         acmllib="acml"
         test x"${enable_shared}" = x"yes" && acmllib="acml_dll"
         ;;
      *)
         echo "ACML-normal: ${enable_shared}"
         acmllib="acml"
         test x"${ac_cv_enable_openmp}" = x"yes" && acmllib="acml_mp"
         ;;
   esac
   SX_BLAS_LIBS="-l${acmllib} $SX_BLAS_LIBS"
   SX_IF_CHECKNUMLIBS([
      AC_CHECK_LIB([$acmllib],   [zfft1mx],       
                   [SX_BLAS_LIBS="-l${acmllib} $SX_BLAS_LIBS"],
                   [AC_MSG_ERROR([Cannot link against ACML library $acmllib, $SX_BLAS_LIBS])])
   ])
fi

# --- check if ATLAS provides BLAS/LAPACK routines
if test x"$ac_cv_enable_atlas" = x"yes"; then
   case "${host}" in
      *-darwin*)
         AC_MSG_CHECKING([for ATLAS support])
         SX_BLAS_LIBS="-framework Accelerate $SX_BLAS_LIBS"
         AC_DEFINE_UNQUOTED(USE_ACCELERATE_FRAMEWORK, "1", [Darwin ATLAS])
         AC_MSG_RESULT([Apple Accelerate Framework])
         ;;
      *)
         SX_IF_CHECKNUMLIBS([
         AC_CHECK_HEADER([cblas.h],,[AC_MSG_ERROR([Cannot find cblas.h])] )
         AC_CHECK_HEADER([f2c.h],,[AC_MSG_ERROR([Cannot find f2c.h])] )
         AC_CHECK_HEADER([clapack.h],,[AC_MSG_ERROR([Cannot find clapack.h])],
                         [#include <f2c.h>])
 
         AC_CHECK_LIB([f2c], [dtime_], [],
                      [AC_MSG_ERROR([Cannot link against F2C library])]
         )

         AC_CHECK_LIB([atlas], [ATL_dnrm2], [],
                      [AC_MSG_ERROR([Cannot link against ATLAS library])],
                      [-lf2c]
         )
         ])
         SX_BLAS_LIBS="-latlas -lf2c $SX_BLAS_LIBS"

         # by setting pt, use threaded ATLAS (which is not open MP!)
         # test x"${ac_cv_enable_openmp}" = x"yes" && pt="pt"
         SX_BLAS_LIBS="-l${pt}lapack -l${pt}cblas -l${pt}f77blas $SX_BLAS_LIBS"

         SX_IF_CHECKNUMLIBS([
         AC_CHECK_LIB([${pt}f77blas], [dnrm2_], [],
                      [AC_MSG_ERROR([Cannot link against ${pt}F77BLAS wrapper])],
                      [-latlas -lf2c]
         )
         AC_CHECK_LIB([${pt}cblas], [cblas_dnrm2], [],
                      [AC_MSG_ERROR([Cannot link against ${pt}CBLAS library])],
                      [-latlas -lf2c]
         )
         AC_SEARCH_LIBS([zhpev_], [${pt}lapack lapack], [],
                        [AC_MSG_ERROR([Cannot link against LAPACK library])],
                        [-lf77blas -latlas -lf2c]
         )
         LIBS="$SX_BLAS_LIBS $LIBS"
         AC_CHECK_FUNC([dsptri_],        
                      [],
                      [AC_MSG_ERROR([ATLAS does not fully support LAPACK])]
         )
         ])
         ;;
   esac
fi



#####  khr: Intel MKL #####
#
### link lines generated by <http://software.intel.com/en-us/articles/intel-mkl-link-line-advisor/> ... ###
### MKL_HOME is set on RZG machines after "module load mkl"
#
## gcc, MKL 10.3 static sequential
# -Wl,--start-group $(MKL_HOME)/lib/intel64/libmkl_intel_lp64.a $(MKL_HOME)/lib/intel64/libmkl_sequential.a $(MKL_HOME)/lib/intel64/libmkl_core.a -Wl,--end-group -lpthread
#
## gcc, MKL 10.3 static thread-parallel
# -Wl,--start-group $(MKL_HOME)/lib/intel64/libmkl_intel_lp64.a $(MKL_HOME)/lib/intel64/libmkl_gnu_thread.a $(MKL_HOME)/lib/intel64/libmkl_core.a -Wl,--end-group -fopenmp -lpthread
#
## gcc, MKL 10.3 dynamic sequential
# -L$(MKL_HOME)/lib/intel64  -Wl,--start-group -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -Wl,--end-group -lpthread
#
## gcc, MKL 10.3 dynamic thread-parallel
# -L$(MKL_HOME)/lib/intel64  -Wl,--start-group -lmkl_intel_lp64 -lmkl_gnu_thread -lmkl_core -Wl,--end-group -fopenmp -lpthread
#
#
### versions of MKL <10.3
#
## gcc, MKL 10.X static sequential
# $(MKL_HOME)/lib/em64t/libmkl_solver_lp64_sequential.a -Wl,--start-group $(MKL_HOME)/lib/em64t/libmkl_intel_lp64.a $(MKL_HOME)/lib/em64t/libmkl_sequential.a $(MKL_HOME)/lib/em64t/libmkl_core.a -Wl,--end-group -lpthread
#
## gcc, MKL 10.X static thread-parallel
# $(MKL_HOME)/lib/em64t/libmkl_solver_lp64.a -Wl,--start-group $(MKL_HOME)/lib/em64t/libmkl_intel_lp64.a $(MKL_HOME)/lib/em64t/libmkl_gnu_thread.a $(MKL_HOME)/lib/em64t/libmkl_core.a -Wl,--end-group -fopenmp -lpthread 
#
## gcc, MKL 10.X dynamic sequential
# -L$(MKL_HOME)/lib/em64t -lmkl_solver_lp64_sequential -Wl,--start-group -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -Wl,--end-group -lpthread 
#
## gcc, MKL 10.X dynamic thread-parallel
# -L$(MKL_HOME)/lib/em64t -lmkl_solver_lp64 -Wl,--start-group -lmkl_intel_lp64 -lmkl_gnu_thread -lmkl_core -Wl,--end-group -fopenmp -lpthread
#
### valid for all:  general recommendation for gcc
# -m64
###

# --- check if INTEL MKL provides BLAS/LAPACK routines
if test x"$ac_cv_enable_mkl" = x"yes"; then

   ### dynamic linking for MKL 10.X (<10.3)
   #
   ## serial MKL
   # SX_MKL_LIBS="-lmkl_solver_lp64_sequential -lmkl_intel_lp64 -lmkl_sequential -lmkl_core"
   #
   ## Thread-parallel MKL, turned out to be slower than the sequential MKL
   ## when comparing 2 vs 1 threads, so don't use it!
   # SX_MKL_LIBS="-lmkl_solver_lp64 -lmkl_intel_lp64 -lmkl_gnu_thread -lmkl_core -fopenmp"

   if test x"$ac_cv_enable_openmp" = x"yes" ; then
      AC_MSG_NOTICE([Using ${mkl_thread} for MKL threading])
   else
      mkl_thread=mkl_sequential
   fi
   ### dynamic linking for MKL 10.3
   #
   ## serial MKL
   if test x"${enable_shared}" = x"yes"; then
      SX_MKL_LIBS="-lmkl_intel_lp64 -l${mkl_thread} -lmkl_core"
   else
      mkdir -p mkllibs
      rm -f mkllibs/*.a 2>/dev/null
      ln -s ${mkllibpath}/libmkl_core.a `pwd`/mkllibs/libmkl_core_1.a
      ln -s ${mkllibpath}/libmkl_core.a `pwd`/mkllibs/libmkl_core_2.a
      ln -s ${mkllibpath}/lib${mkl_thread}.a `pwd`/mkllibs/lib${mkl_thread}_1.a
      SX_MKL_LIBS="-L`pwd`/mkllibs -lmkl_intel_lp64 -lmkl_core -l${mkl_thread} -lmkl_core_1 -l${mkl_thread}_1 -lmkl_core_2"
   fi
   
   # follow the general recommendation given by the MKL link line generator
   SX_MKL_LIBS="$SX_MKL_LIBS -lpthread -m64"


   # checks if the library functions can actually be linked
   SX_BLAS_LIBS="$SX_MKL_LIBS $SX_BLAS_LIBS"
   LIBS="$SX_BLAS_LIBS $LIBS"
   AC_CHECK_FUNC([dnrm2], [], AC_MSG_ERROR([Cannot link the MKL]))

fi
#####


# --- khr: check for GotoBLAS/OpenBLAS
if test x"$ac_cv_enable_goto" = x"yes"; then

   AC_CHECK_HEADER([cblas.h],,[AC_MSG_ERROR([Cannot find cblas.h])] )
   AC_CHECK_HEADER([f2c.h],,[AC_MSG_ERROR([Cannot find f2c.h])] )
   AC_CHECK_HEADER([clapack.h],,[AC_MSG_ERROR([Cannot find clapack.h])],
                   [#include <f2c.h>])
   
   # TODO:  implement checks if the library functions can actually be linked, see ACML
   
   # libf2c does not appear to be needed:
   # SX_GOTO_LIBS="-lf2c -lgoto2 -lgfortran -lpthread -m64"
   # SMT mode slows down the code, so use the unthreaded Library version:
   # SX_GOTO_LIBS="-lgoto2smt -lgfortran -lpthread -m64"

   # If you're using OpenBLAS ("libopenblas.a/so") create a symbolic link named
   # "libgoto2.a/so" or change the name of the library below:
   #
   SX_GOTO_LIBS="-lgoto2 -lgfortran -lpthread -m64"
   SX_BLAS_LIBS="$SX_GOTO_LIBS $SX_BLAS_LIBS"
   
   if test  "$ac_test_LDFLAGS" != "set"; then
      # cxxname is set in sxcompflags.m4
      case "$cxxname" in
         g++)
            LDFLAGS="-Wl,-rpath=${ac_cv_with_numlibs}/lib ${LDFLAGS}"
            ;;
         icc|icpc)
            LDFLAGS="-Xlinker -rpath=${ac_cv_with_numlibs}/lib ${LDFLAGS}"
            ;;
         *)
            LDFLAGS=""
            AC_MSG_ERROR([Intel MKL is not supported for your compiler.])
      esac
   fi
      
fi
#####



# --- set up the MPI compiler
if test x"$ac_cv_enable_mpi"     = x"yes"; then
   AC_CHECK_TOOLS(MPICXX, [mpic++ mpicxx])
   # AC_CHECK_TOOLS(MPICXX, [mpigxx mpic++ mpicxx])
   MPICXX=${ac_cv_prog_ac_ct_MPICXX}
   if test x"${MPICXX}" = x; then
      AC_MSG_ERROR([MPI C++ compiler wrapper not found.])
   fi
   AC_MSG_CHECKING([whether ${MPICXX} wraps ${CXX}])
   # ${CXX} -v    > config.out.cxx     2>&1
   # ${MPICXX} -v > config.out.mpicxx  2>&1
   # khr: "--version" appears to be more robust with certain MPI wrappers
   ${CXX}    --version > config.out.cxx     2>&1
   ${MPICXX} --version > config.out.mpicxx  2>&1
   if test -f config.out.cxx; then
      if test -f config.out.mpicxx; then
         cmp config.out.cxx config.out.mpicxx > /dev/null
         if test $? -ne 0; then
            AC_MSG_ERROR([${MPICXX} is not a wrapper for ${CXX}.])
         fi
      else
         AC_MSG_ERROR([Could not execute ${MPICXX} -v])
      fi
   else
      AC_MSG_ERROR([Could not execute ${CXX} -v])
   fi
   rm -f config.out.cxx config.out.mpicxx
   AC_MSG_RESULT([yes])
   AC_SUBST(CXX, "$MPICXX")
fi


LIBS=$ORIG_LIBS

# HDF5 (if requested and working)
if test -d "$ac_cv_enable_hdf5"/lib ; then
   LDFLAGS="-L$ac_cv_enable_hdf5/lib $LDFLAGS"
fi
if test -d "$ac_cv_enable_hdf5"/include ; then
   CPPFLAGS="-I$ac_cv_enable_hdf5/include $CPPFLAGS"
fi
if test ! x"$ac_cv_enable_hdf5" = x"no"; then
   AC_DEFINE([USE_HDF5])
   AC_CHECK_LIB([hdf5], [H5Fopen], [],
                AC_MSG_ERROR([Cannot link to HDF5]), [-lz -lm])
   LIBS="-lhdf5_cpp -lhdf5 -lz -lm $LIBS"
fi


SX_PARAM_ATLAS="$ac_cv_enable_atlas"
SX_PARAM_MKL="$ac_cv_enable_mkl"
SX_PARAM_ACML="$ac_cv_enable_acml"
SX_PARAM_FFTW="$ac_cv_enable_fftw"
SX_PARAM_ACMLFFT="$ac_cv_enable_acmlfft"
SX_PARAM_MKLFFT="$ac_cv_enable_mklfft"

SX_SHORTCUT_LIBS=""


# --- replace libraries with libtool archives
case "${host}" in
   *-mingw32*)
      AC_CHECK_LIB([shortcut], [sxnumlibs_createShortcut],
                   [SX_SHORTCUT_LIBS="-lshortcut"],
                   [AC_MSG_ERROR([Cannot link against WinShortCut helper])])

      SX_BLAS_LIBS=`echo $SX_BLAS_LIBS | sed s#-lacml_dll#${ac_cv_with_numlibs}/lib/libacml_dll.la#`
      SX_BLAS_LIBS=`echo $SX_BLAS_LIBS | sed s#-lacml#${ac_cv_with_numlibs}/lib/libacml.la#`
      SX_NETCDF_LIBS=`echo $SX_NETCDF_LIBS | sed s#-lnetcdf#${ac_cv_with_numlibs}/lib/libnetcdf.la#`
      LIBS=`echo $LIBS | sed s#-lgnurx#${ac_cv_with_numlibs}/lib/libgnurx.la#`
      ;;
esac


# --- Link against MINGW regex if available
AC_CHECK_LIB([gnurx], [regexec], [LIBS="-lgnurx $LIBS"], [])

AC_SUBST([SX_FFT_LIBS])
AC_SUBST([SX_NETCDF_LIBS])
AC_SUBST([SX_SHORTCUT_LIBS])
AC_SUBST([SX_BLAS_LIBS])
AC_SUBST([SX_PARAM_NUMLIBS])
AC_SUBST([SX_PARAM_ATLAS])
AC_SUBST([SX_PARAM_MKL])
AC_SUBST([SX_PARAM_FFTW])
AC_SUBST([SX_PARAM_ACML])
AC_SUBST([SX_PARAM_ACMLFFT])
AC_SUBST([SX_PARAM_MKLFFT])
])
