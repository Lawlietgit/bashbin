AC_DEFUN([SX_COMPFLAGS], [


SX_ARG_ENABLE([debug],    [DBG_MODE], [yes], 
              [compile package in DEBUG mode - RELEASE mode otherwise])
SX_ARG_ENABLE([profile],  [PRO_MODE], [no], 
              [compile package in the profile mode])
SX_ARG_ENABLE([openmp],   [USE_OPENMP], [no], 
              [compile package with symmetric multiprocessing support])
SX_ARG_ENABLE([mpi],      [USE_MPI], [no], 
              [compile package with Message-Passing Interface support])
AM_CONDITIONAL([COND_MPI], [test x"$ac_cv_enable_mpi" = x"yes"])

AC_MSG_NOTICE([Determine compiler flags])

# --- Search for C/C++ compilers
AC_PROG_CC(  gcc)              # GNU C compiler for dependencies
if test "$ac_cv_enable_debug" = "yes"; then
AC_PROG_CXX( g++)              # GNU C++ compiler for DEBUG mode
else
AC_PROG_CXX( g++ icc ipcp xlC aCC)  # C++ compilers for RELEASE mode
fi

cxxname=`echo "$CXX" | sed -e's#.*/##'`
if test x"$cxxname" != x"g++" -a $ac_cv_cxx_compiler_gnu = yes ; then
   # CXX not "g++", but seems to be a GNU C++ compiler. Try to verify...
   if $CXX --version | head -n 1 | grep -q -e 'GCC' -e "g++" ; then
      cxxname="g++"
      AC_MSG_NOTICE([$CXX has been identified as GNU C++ (g++)])
   else
      AC_MSG_NOTICE([$CXX pretends to be GCC, but fails to prove it in --version])
   fi
fi

# --- Set OS dependent flags
GCC_M_ARCH=""
ICC_M_ARCH=""
M_SSE=""
AC_MSG_CHECKING(operating system)
if test ! -z "`uname | grep Linux`"; then
   # --- Linux
   AC_MSG_RESULT(Linux)
   AC_DEFINE(LINUX, "1", [Setup Linux Compilation])
   MAKE_SILENT_ARGS="-s --no-print-directory"
   MODEL=`cat /proc/cpuinfo | grep 'model name' | uniq`
   FLAGS=`cat /proc/cpuinfo | grep 'flags' | uniq`

   AC_MSG_CHECKING(processor type)
   # --- Linux Pentium III
   if test ! -z "`echo $MODEL | grep 'Pentium III'`"; then
      AC_MSG_RESULT(Pentium 3)
      GCC_M_ARCH="-march=pentium3"
      ICC_M_ARCH=""
   elif test ! -z "`echo $MODEL | grep 'Pentium(R) III'`"; then
      AC_MSG_RESULT(Pentium 3)
      GCC_M_ARCH="-march=pentium3"
      ICC_M_ARCH=""
   # --- Linux Pentium 4
   elif test ! -z "`echo $MODEL | grep 'Pentium 4 CPU'`"; then
      AC_MSG_RESULT(Pentium 4)
      GCC_M_ARCH="-march=pentium4"
      ICC_M_ARCH=""
   elif test ! -z "`echo $MODEL | grep 'Pentium(R) 4 CPU'`"; then
      AC_MSG_RESULT(Pentium 4)
      GCC_M_ARCH="-march=pentium4"
      ICC_M_ARCH=""
   elif test ! -z "`echo $MODEL | grep 'Pentium(R) M'`"; then
      AC_MSG_RESULT(Pentium 4)
      GCC_M_ARCH="-march=pentium-m"
      ICC_M_ARCH=""
   # --- Linux Xeon (Pentium 4)
   elif test ! -z "`echo $MODEL | grep 'Xeon'`"; then
      AC_MSG_RESULT(Xeon)
      GCC_M_ARCH="-march=native"
      ICC_M_ARCH="-xHost"
   elif test ! -z "`echo $MODEL | grep 'Athlon' | grep 'XP'`"; then
      AC_MSG_RESULT(Athlon XP)
      GCC_M_ARCH="-march=athlon-xp"
      ICC_M_ARCH=""
   elif test ! -z "`echo $MODEL | grep 'Opteron'`"; then
      AC_MSG_RESULT(AMD Opteron)
      GCC_M_ARCH=""
      ICC_M_ARCH=""
   else
      AC_MSG_RESULT(unknown)
   fi

   # -- is SSE supported?
   AC_MSG_CHECKING(for SSE support)
   if test ! -z "`echo $FLAGS | sed s/sse2//g | grep 'sse'`"; then
      AC_MSG_RESULT(yes)
      M_SSE="$M_SSE -msse"
   else
      AC_MSG_RESULT(no)
   fi
   # -- is SSE2 supported?
   AC_MSG_CHECKING(for SSE2 support)
   if test ! -z "`echo $FLAGS | grep 'sse2'`"; then
      AC_MSG_RESULT(yes)
      M_SSE="$M_SSE -msse2"
   else
      AC_MSG_RESULT(no)
   fi

   # -- is SSE3 supported?
   AC_MSG_CHECKING(for SSE3 support)
   if test ! -z "`echo $FLAGS | grep ' sse3'`"; then
      AC_MSG_RESULT(yes)
      M_SSE="$M_SSE -msse3"
   else
      AC_MSG_RESULT(no)
   fi

elif test ! -z "`uname | grep Darwin`"; then
   AC_MSG_RESULT(MacOSX)
   AC_DEFINE(MACOSX, "1", [Setup MACOSX Compilation])
   MAKE_SILENT_ARGS="-s"
   LIBS="$LIBS -framework CoreFoundation"
elif test ! -z "`uname | grep HP-UX`"; then
   AC_MSG_RESULT(HP-UX)
   AC_DEFINE(HPUX, "1", [Setup HPUX Compilation])
   MAKE_SILENT_ARGS="-s --no-print-directory"
elif test ! -z "`uname | grep SunOS`"; then
   AC_MSG_RESULT(Athlon XP)
   AC_DEFINE(SUNOS, "1", [Setup SunOS Compilation])
   MAKE_SILENT_ARGS="-s --no-print-directory"
   GCC_M_ARCH="-mcpu=ultrasparc"
   ICC_M_ARCH=""
elif test ! -z "`uname | grep CYGWIN`"; then
   isWindowsOS="yes"
   AC_MSG_RESULT(Win32)
   AC_DEFINE(WIN32, "1", [Setup Windows Compilation])
   AC_DEFINE_UNQUOTED(CYGWIN, "1", [Compiling in Cygwin environment?])
   AC_SUBST(WIN32FLAGS, "-DWIN32")
   AC_SUBST(CYGWIN)
   MAKE_SILENT_ARGS="-s --no-print-directory"
   # use -no-undefined in windows to build dlls
elif test ! -z "`uname | grep MINGW`"; then
   isWindowsOS="yes"
   AC_MSG_RESULT(Win32)
   MAKE_SILENT_ARGS="-s --no-print-directory"
   AC_SUBST(WIN32FLAGS, "-DWIN32")
   AC_DEFINE(WIN32, "1", [Setup Windows Compilation])
   # use -no-undefined in windows to build dlls
else   
   AC_MSG_RESULT(unknown)
fi   


# --- Set compiler flags for RELEASE mode
found_compiler=yes
case "$cxxname" in
   g++)  # GNU C/C++ Compiler
      CXX_VER=`$CXX --version | head -1`
      # -----------------------------------------------------------------------
      CXX_REL="-Wall -O3 $GCC_M_ARCH $M_SSE"
      #
      # khr:  at least "-funroll-all-loops" is not recommended in general,
      #       so better let the compiler decide on the optimization flags
      # CXX_REL="$CXX_REL -momit-leaf-frame-pointer -funroll-all-loops"
      #
      CXX_REL="$CXX_REL -fpermissive"   # khr: The flag "-fpermissive" is required 
      #         #  for gcc 4.6.0, otherwise compilation fails.  Check source code.
      #
      # khr: the following define is necessary for Intel MPI
      CXX_REL="$CXX_REL -DMPICH_IGNORE_CXX_SEEK"
      #
      CXX_REL="$CXX_REL -DNDEBUG -pipe"
      # -----------------------------------------------------------------------
      CXX_DBG="-g -O2 -W -Wall -ansi -Wcast-align -D_REENTRANT"
      CXX_DBG="$CXX_DBG -Wcast-qual -Wchar-subscripts"
      CXX_DBG="$CXX_DBG -Wpointer-arith"
      CXX_DBG="$CXX_DBG -Wredundant-decls -Wshadow"
      CXX_DBG="$CXX_DBG -Wwrite-strings"
      CXX_DBG="$CXX_DBG -Wconversion"
      CXX_DBG="$CXX_DBG -pipe"
      CXX_PEDANTIC="-pedantic"
      CXX_WARNING_IS_ERROR="-Werror -Wfatal-errors"
      # -----------------------------------------------------------------------
      CXX_OPENMP="-fopenmp"
      LDC_OPENMP="-lgomp"
      # -----------------------------------------------------------------------
      CXX_PRO="-g -pg -DNDEBUG"
      LDF_PRO=""
      # -----------------------------------------------------------------------
      AR_FLAGS="ruv"
      # -----------------------------------------------------------------------
      ;;
   icc|icpc) # Intel C/C++ Compiler
      CXX_VER=`$CXX --version | head -1`
      # -----------------------------------------------------------------------
      CXX_REL="-O3 $ICC_M_ARCH"
      CXX_REL="$CXX_REL -DNDEBUG"
      # -----------------------------------------------------------------------
      CXX_DBG="-O0 -no-ip -g -ansi -Wall -Wcheck -w1 $ICC_M_ARCH"
      # -----------------------------------------------------------------------
      CXX_OPENMP=""
      LDC_OPENMP=""
      # -----------------------------------------------------------------------
      CXX_PRO="-g -O -DNDEBUG"
      LDF_PRO=""
      # -----------------------------------------------------------------------
      AR_FLAGS="ruv"
      # -----------------------------------------------------------------------
      ;;
   aCC)  # HP-UX aCC Compiler
      CXX_VER=`$CXX -V`
      # -----------------------------------------------------------------------
      CXX_REL="-ext -mt -w +p -AA -D_HPUX"
      CXX_REL="$CXX_REL -D_XOPEN_SOURCE_EXTENDED" # force aCC to deal with UNIX sockets
      CXX_REL="$CXX_REL +W749"                    # suppress 'reinterpret_cast' warning
      CXX_REL="$CXX_REL -D__HP_NO_MATH_OVERLOADS" # ignore HP-UX cmath overloading
      CXX_REL="$CXX_REL +O2 +DA2.0W -DNDEBUG"
      CXX_REL="$CXX_REL -DUSE_VECLIB -DUSE_VECLIB_FFT -D_REENTRANT"
      CXX_REL="$CXX_REL -D_POSIX_C_SOURCE=199506L"
      CXX_REL="$CXX_REL -I/usr/local/include/"
      CXX_REL="$CXX_REL -I/usr/local/include/pa20_64"
      # -----------------------------------------------------------------------
      CXX_OPENMP=""
      LDC_OPENMP=""
      # -----------------------------------------------------------------------
      CXX_PRO="-g -O -DNDEBUG"
      LDF_PRO=""
      # -----------------------------------------------------------------------
      AR_FLAGS="ruvl"
      # -----------------------------------------------------------------------
      ;;
   *)    # --- No Compiler found
      found_compiler=no
esac
if test $found_compiler = no -a "$ac_test_CXXFLAGS" != "set"; then
   cat << ERRMSG
$SEPARATOR
ERROR: Compiler not supported.
$SEPARATOR
       This package does not support the compiler "$CXX". 
       You can either provide a C++ compiler supported by SPHInX or
       set the compiler flags (CXXFLAGS) by hand.
$SEPARATOR
ERRMSG
   exit 1
fi


# --- Set up compiler flags according to OS, compiler, and mode   
if test  "$ac_test_CXXFLAGS" != "set"; then
   # remove standard CXXFLAGS provided by autoconf
   CXXFLAGS=""
   if test "$ac_cv_enable_debug" = "yes"; then
      AM_CXXFLAGS="$CXX_DBG"
   else
      AM_CXXFLAGS="$CXX_REL"
   fi
   if test "$ac_cv_enable_profile" = "yes"; then
      AM_CXXFLAGS="$AM_CXXFLAGS $CXX_PRO"
   fi
   if test x"${ac_cv_enable_openmp}" = x"yes"; then
      AM_CXXFLAGS="$AM_CXXFLAGS $CXX_OPENMP"
   fi
   if test x"${ac_cv_enable_mpi}" = x"yes"; then
      # <mpi.h> uses "long long" which is unsupported by C++ ('98)
      CXX_PEDANTIC=""
   fi

   AC_SUBST(AM_CXXFLAGS, "$AM_CXXFLAGS")
   AC_SUBST(CXX_PEDANTIC,"$CXX_PEDANTIC")
   AC_SUBST(CXX_WARNING_IS_ERROR,"$CXX_WARNING_IS_ERROR")
else
   AC_SUBST(AM_CXXFLAGS, "$CXXFLAGS")
fi


# --- check OS dependent libraries
AC_CHECK_LIB([dl],[dlopen], [LIBS="$LIBS -ldl"])
AC_CHECK_LIB([pthreadGCE2], [pthread_create], [LIBS="$LIBS -lpthreadGCE2"],
   [AC_CHECK_LIB([pthread], [pthread_create], [LIBS="$LIBS -lpthread"])]
)
if test x"${ac_cv_enable_openmp}" = x"yes"; then
   LIBS="$LIBS $LDC_OPENMP"
fi

AC_MSG_CHECKING([for suitable compiler flags])
AC_MSG_RESULT([$AM_CXXFLAGS])


# --- SxConfig.h
AC_DEFINE_UNQUOTED(CXX,         "$CXX",         [C++ compiler])
AC_DEFINE_UNQUOTED(CXXFLAGS,    "$AM_CXXFLAGS", [C++ compiler flags])
AC_DEFINE_UNQUOTED(CXXVERSION,  "$CXX_VER",     [C++ compiler version])
AC_DEFINE_UNQUOTED(F77,         "$F77",         [FORTRAN77 compiler])
AC_DEFINE_UNQUOTED(FFLAGS,      "$FFLAGS",      [FORTRAN77 compiler flags])


# --- Makefile & Co
AC_SUBST(CC)
AC_SUBST(MAKE_SILENT_ARGS)


])
