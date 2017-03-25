AC_DEFUN([SX_ENVIRONMENT],
[

UNAME=`uname`
WHOAMI=`whoami`
TODAY=`date +%D`
PROCESSOR=`uname -m`

ABS_TOP_SRCDIR=`cd $srcdir; pwd`
ABS_TOP_BUILDDIR=`pwd`
SXLIBTOOL="$ABS_TOP_BUILDDIR/libtool"

# --- read SVN information
if test -e SVN/Tag; then
   SVNTAG=`grep url .svn/entries | awk -F '/' '{print $5}'`
else
   SVNTAG="trunk"
fi

# --- determine distribution
if test -f /etc/redhat-release; then
   PKG_TYPE=rpm
   case `cat /etc/redhat-release` in
   "CentOS release"*)
      DIST_OS=Linux
      DIST_NAME=CentOS
      DIST_VERSION=`cut -f 3 -d ' ' /etc/redhat-release`
      DIST_MAJOR=`echo $DIST_VERSION | cut -f 1 -d '.'`
      DIST_MINOR=`echo $DIST_VERSION | cut -f 2 -d '.'`
      DIST_PATCH=0
      DIST_REPO_VER="${DIST_MAJOR}.${DIST_MINOR}"
      ;;
   "CentOS Linux release"*)
      DIST_OS=Linux
      DIST_NAME=CentOS
      DIST_VERSION=`cut -f 4 -d ' ' /etc/redhat-release`
      DIST_MAJOR=`echo $DIST_VERSION | cut -f 1 -d '.'`
      DIST_MINOR=`echo $DIST_VERSION | cut -f 2 -d '.'`
      DIST_PATCH=0
      DIST_REPO_VER="${DIST_MAJOR}.${DIST_MINOR}"
      ;;
   "Fedora release"*)
      DIST_OS=Linux
      DIST_NAME=Fedora
      DIST_VERSION=`cut -f 3 -d ' ' /etc/redhat-release`
      DIST_MAJOR=`echo $DIST_VERSION | cut -f 1 -d '.'`
      DIST_MINOR=0
      DIST_PATCH=0
      DIST_REPO_VER="${DIST_MAJOR}"
      ;;
   esac
elif test -f /etc/debian_version; then
   DIST_OS=Linux
   DIST_NAME=Debian
   DIST_VERSION=`cat /etc/debian_version`
   DIST_MAJOR=`cut -f 1 -d '.' /etc/debian_version`
   DIST_MINOR=`cut -f 2 -d '.' /etc/debian_version`
   DIST_PATCH=`cut -f 3 -d '.' /etc/debian_version`
   DIST_REPO_VER="${DIST_MAJOR}.${DIST_MINOR}"
   PKG_TYPE=deb
elif test -f /etc/SuSE-release; then
   DIST_OS=Linux
   DIST_NAME=SuSE
   DIST_VERSION=`cat /etc/SuSE-release|grep VERSION|awk '{print $3'}`
   PKG_TYPE=rpm
elif test -d /Library/Preferences; then
   PKG_TYPE=pkg
   DIST_OS=Darwin
   DIST_NAME="MacOSX"
   DIST_VERSION=`system_profiler SPSoftwareDataType|grep 'System Version' | cut -f 12 -d ' '`
   DIST_MAJOR=`echo $DIST_VERSION | cut -f 1 -d '.'`
   DIST_MINOR=`echo $DIST_VERSION | cut -f 2 -d '.'`
   DIST_PATCH=`echo $DIST_VERSION | cut -f 3 -d '.'`
   DIST_REPO_VER="${DIST_MAJOR}.${DIST_MINOR}"
   sysctl=`/usr/sbin/sysctl hw | grep hw.cpu64bit_capable | cut -f 2 -d ':' | sed s/\ //g`
   if test x"$sysctl" = x"1"; then
      PROCESSOR="x86_64"
   fi
else
   echo "WARNING: sxenv.m4 could not determine distribution"
fi
DIST_VERSION_L=`echo ${DIST_MAJOR}${DIST_MINOR}${DIST_PATCH}L`

AC_CHECK_TOOLS([GDB], [ddd gdb])
AC_CHECK_PROG([MEMTRACER], [valgrind], [`which valgrind` --leak-check=full --show-reachable=yes --run-libc-freeres=no --log-fd=1])
GDB=`which $GDB`
case "${host}" in
   *-mingw32)
      isWindowsOS="yes"
      LIBEXT="dll"
      DLLLIBEXT="-0.dll"
      IMPLIBEXT=".dll.a"
      CP_A=`which cp`" -a"
      AC_CHECK_PROG([LDD], [ldd], [ldd])
      LDD_AWK_COL="3"
      ;;
   *-darwin*)
      isWindowsOS="no"
      buildMacBundles="yes"
      LIBEXT="dylib"
      DLLLIBEXT=".$LIBEXT"
      IMPLIBEXT=".$LIBEXT"
      CP_A=`which cp`" -pR"
      AC_CHECK_PROG([LDD], [otool], [otool -L])
      LDD_AWK_COL="1"
      ;;
   *)
      isWindowsOS="no"
      LIBEXT="so"
      DLLLIBEXT=".$LIBEXT"
      IMPLIBEXT=".$LIBEXT"
      CP_A=`which cp`" -a"
      AC_CHECK_PROG([LDD], [ldd], [ldd])
      LDD_AWK_COL="3"
      ;;
esac

AM_CONDITIONAL([COND_BUILD_WIN32], [test x"$isWindowsOS" = x"yes"])
AM_CONDITIONAL([BUILD_LINUX],      [test -n "`uname | grep Linux`"])
AM_CONDITIONAL([BUILD_DARWIN],     [test -n "`uname | grep Darwin`"])



# --- 32 or 64 bit?
AC_CHECK_SIZEOF(void*)
if test x"$ac_cv_sizeof_voidp" = x"8"; then
   AC_DEFINE_UNQUOTED(HAS_64BIT, "1",   [64bit environment])
#   LIB3264=lib64
else
   AC_DEFINE_UNQUOTED(HAS_32BIT, "1",   [32bit environment])
#   LIB3264=lib
fi

# --- Check endian type
AC_C_BIGENDIAN(
[ AC_DEFINE_UNQUOTED(HAS_BIG_ENDIAN, 1, [System byte order]) ], [],
[ AC_MSG_ERROR([Cannot determine byte order of this system.])])

# --- Define variables in header file
AC_DEFINE_UNQUOTED(UNAME,         "$UNAME",         [Output of uname(1)])
AC_DEFINE_UNQUOTED(PROCESSOR,     "$PROCESSOR",     [CPU type])
AC_DEFINE_UNQUOTED(SVNTAG,        "$SVNTAG",        [SVN tag identifier])
AC_DEFINE_UNQUOTED(WHOAMI,        "$WHOAMI",        [User who compiled package])
AC_DEFINE_UNQUOTED(GDB,           "$GDB",           [Debugger])
AC_DEFINE_UNQUOTED(MEMTRACER,     "$MEMTRACER",     [Memory tracer tool])
AC_DEFINE_UNQUOTED(DIST_OS,       "$DIST_OS",       [Operating system ID])
AC_DEFINE_UNQUOTED(DIST_NAME,     "$DIST_NAME",     [Distribution ID])
AC_DEFINE_UNQUOTED(DIST_VERSION,  "$DIST_VERSION",  [Distribution Version])
AC_DEFINE_UNQUOTED(DIST_VERSION_L, $DIST_VERSION_L ,[Distribution Version Integer Number])
AC_DEFINE_UNQUOTED(DIST_MAJOR,    "$DIST_MAJOR",    [Distribution Major Version])
AC_DEFINE_UNQUOTED(DIST_MINOR,    "$DIST_MINOR",    [Distribution Minor Version])
AC_DEFINE_UNQUOTED(DIST_PATCH,    "$DIST_PATCH",    [Distribution Patch Version])
AC_DEFINE_UNQUOTED(DIST_REPO_VER, "$DIST_REPO_VER", [Distribution Repository Version])
AC_DEFINE_UNQUOTED(PKG_TYPE,      "$PKG_TYPE",      [Package type])

# --- Substitute variables in makefile
AC_SUBST([UNAME])
AC_SUBST([PROCESSOR])
AC_SUBST([WHOAMI])
AC_SUBST([TODAY])
AC_SUBST([SVNTAG])
AC_SUBST([LIBEXT])
AC_SUBST([DLLLIBEXT])
AC_SUBST([IMPLIBEXT])
AC_SUBST([CP_A])
AC_SUBST([GDB])
AC_SUBST([LDD])
AC_SUBST([LDD_AWK_COL])
AC_SUBST([SXLIBTOOL])
AC_SUBST([DIST_OS])
AC_SUBST([DIST_NAME])
AC_SUBST([DIST_VERSION])
AC_SUBST([DIST_MAJOR])
AC_SUBST([DIST_MINOR])
AC_SUBST([DIST_PATCH])
AC_SUBST([DIST_REPO_VER])
AC_SUBST([PKG_TYPE])
])
