# $NetBSD: AIX.mk,v 1.4.2.1 2004/12/31 20:25:30 tv Exp $
#
# Variable definitions for the AIX operating system.

AWK?=		/usr/bin/awk
BASENAME?=	/usr/bin/basename
CAT?=		/bin/cat
CHMOD?=		/bin/chmod
CHOWN?=		/usr/sbin/chown
CHGRP?=		/usr/bin/chgrp
CMP?=		/usr/bin/cmp
CP?=		/bin/cp
CPP?=       ${LOCALBASE}/bin/cpp
CUT?=		/usr/bin/cut
DATE?=		/bin/date
DC?=		/usr/bin/dc
DIRNAME?=	/usr/bin/dirname
ECHO?=		echo				# Shell builtin
ECHO_N?=	${ECHO} -n
.if exists(${LOCALBASE}/bin/egrep)
EGREP?=		${LOCALBASE}/bin/egrep
.else
EGREP?=     /usr/bin/grep -E
.endif
EXPR?=		/bin/expr
FALSE?=		false				# Shell builtin
FETCH_CMD?= ${LOCALBASE}/bin/ftp
.if exists(${LOCALBASE}/bin/fgrep)
FGREP?=		${LOCALBASE}/bin/fgrep
.else
FGREP?=     /usr/bin/grep -F
.endif
FILE_CMD?=	/usr/bin/file
FIND?=		/usr/bin/find
GMAKE?=		${LOCALBASE}/bin/gmake
.if exists(${LOCALBASE}/bin/grep)
GREP?=		${LOCALBASE}/bin/grep
.else
GREP?=		/usr/bin/grep
.endif
.if exists(/bin/tar)
GTAR?=		/bin/tar
.else
GTAR?=		/usr/bin/tar
.endif
GUNZIP_CMD?=	${LOCALBASE}/bin/gunzip -f
GZCAT?=		${LOCALBASE}/bin/zcat
GZIP?=		-9
GZIP_CMD?=	${LOCALBASE}/bin/gzip -nf ${GZIP}
HEAD?=		/usr/bin/head
HOSTNAME_CMD?=	/bin/hostname
ID?=		/usr/bin/id
#.if ${INSTALL} == "install"
INSTALL=   ${LOCALBASE}/bin/install-sh
#.endif
LDCONFIG?=	/sbin/ldconfig
LN?=		/bin/ln
LS?=		/bin/ls
M4?=		/usr/bin/m4
MAIL_CMD?=	/usr/bin/mailx
MKDIR?=		/bin/mkdir -p
MTREE?=		${LOCALBASE}/sbin/mtree
MV?=		/bin/mv
NICE?=		/usr/bin/nice
PATCH?=		${LOCALBASE}/bin/gpatch
.if exists(${LOCALBASE}/bin/pax)
PAX?=       ${LOCALBASE}/bin/pax
.else
PAX?=		/bin/pax
.endif
PERL5?=		${LOCALBASE}/bin/perl
PKGLOCALEDIR?=	share
PS?=		/bin/ps
PWD_CMD?=	/bin/pwd	# needs to print physical path
RM?=		/bin/rm
RMDIR?=		/bin/rmdir
# XXX: default from bsd.pkg.defaults.mk.  Verify/corerct for this platform
# and remove this comment.
RSH?=		/usr/bin/rsh
.if exists(${LOCALBASE}/bin/nbsed)
SED?=		${LOCALBASE}/bin/nbsed
.else
SED?=		/usr/bin/sed
.endif
SETENV?=	/usr/bin/env
SH?=		/bin/sh
SHLOCK=		/usr/bin/shlock
SORT?=		/usr/bin/sort
# AIX strip fails too easily.  Use a wrapper script instead
.if exists(${LOCALBASE}/bin/strip)
STRIP?=     ${LOCALBASE}/bin/strip
.endif
SU?=		/usr/bin/su
TAIL?=		/usr/bin/tail
.if exists(${LOCALBASE}/bin/tar)
TAR?=		${LOCALBASE}/bin/tar
.else
TAR?=		/usr/bin/tar
.endif
TEE?=		/usr/bin/tee
TEST?=		test				# Shell builtin
TOUCH?=		/usr/bin/touch
TR?=		/usr/bin/tr
TRUE?=		true				# Shell builtin
TSORT?=		/usr/bin/tsort
TYPE?=		type				# Shell builtin
WC?=		/usr/bin/wc
XARGS?=		/usr/bin/xargs

CPP_PRECOMP_FLAGS?=	# unset
DEF_UMASK?=		0022
EXPORT_SYMBOLS_LDFLAGS?=-Wl,-E	# add symbols to the dynamic symbol table
MOTIF_TYPE_DEFAULT?=	openmotif	# default 2.0 compatible libs type
NOLOGIN?=		/sbin/nologin
PKG_TOOLS_BIN?=		${LOCALBASE}/sbin
ROOT_CMD?=		${SU} - root -c
ROOT_USER?=		root
ROOT_GROUP?=	system
ULIMIT_CMD_datasize?=	ulimit -d `ulimit -H -d`
ULIMIT_CMD_stacksize?=	ulimit -s `ulimit -H -s`
ULIMIT_CMD_memorysize?=	ulimit -m `ulimit -H -m`

# imake installs manpages in weird places
# these values from /usr/X11R6/lib/X11/config/NetBSD.cf
IMAKE_MAN_SOURCE_PATH=	man/cat
IMAKE_MAN_SUFFIX=	1
IMAKE_LIBMAN_SUFFIX=	3
IMAKE_FILEMAN_SUFFIX=	5
IMAKE_MAN_DIR=		${IMAKE_MAN_SOURCE_PATH}1
IMAKE_LIBMAN_DIR=	${IMAKE_MAN_SOURCE_PATH}3
IMAKE_FILEMAN_DIR=	${IMAKE_MAN_SOURCE_PATH}5
IMAKE_MANNEWSUFFIX=	0

_DO_SHLIB_CHECKS=	no	# fixup PLIST for shared libs/run ldconfig
                 	  	# doesn't work on AIX b/c no ldd.
_IMAKE_MAKE=		${MAKE}	# program which gets invoked by imake
.if exists(/usr/include/netinet6)
_OPSYS_HAS_INET6=	yes	# IPv6 is standard
.else
_OPSYS_HAS_INET6=	no	# IPv6 is not standard
.endif
_OPSYS_HAS_JAVA=	no	# Java is not standard
_OPSYS_HAS_MANZ=	yes	# MANZ controls gzipping of man pages
_OPSYS_HAS_OSSAUDIO=	no	# libossaudio is available
_OPSYS_PERL_REQD=		# no base version of perl required
_OPSYS_PTHREAD_AUTO=	no	# -lpthread needed for pthreads
_OPSYS_SHLIB_TYPE=	aixlib	# type of shared lib
_PATCH_CAN_BACKUP=	yes	# native patch(1) can make backups
_PATCH_BACKUP_ARG?=	-b -V simple -z 	# switch to patch(1) for backup suffix
_PREFORMATTED_MAN_DIR=	cat	# directory where catman pages are
_USE_GNU_GETTEXT=	no	# Don't use GNU gettext
_USE_RPATH=		yes	# add rpath to LDFLAGS

# flags passed to the linker to extract all symbols from static archives.
# this is GNU ld.
_OPSYS_WHOLE_ARCHIVE_FLAG=	-Wl,--whole-archive
_OPSYS_NO_WHOLE_ARCHIVE_FLAG=	-Wl,--no-whole-archive

# for programs which use dlopen()
# not necessary since 1.6 (shared libs are linked against libgcc_pic)
.if !empty(OS_VERSION:M1.5*)
LINK_ALL_LIBGCC_HACK=	-Wl,--whole-archive -lgcc -Wl,--no-whole-archive
.endif

.if (!defined(INSTALL_UNSTRIPPED) || empty(INSTALL_UNSTRIPPED:M[yY][eE][sS])) && !defined(DEBUG_FLAGS)
_STRIPFLAG_CC?=		-s	# cc(1) option to strip
_STRIPFLAG_INSTALL?=	-s	# install(1) option to strip
.endif

DEFAULT_SERIAL_DEVICE?=	/dev/tty0
SERIAL_DEVICES?=	/dev/tty0 \
			/dev/tty

# check for maximum command line length and set it in configure's environment,
# to avoid a test required by the libtool script that takes forever.
# FIXME: Adjust to work on this system and enable the lines below.
#.if defined(GNU_CONFIGURE) && defined(USE_LIBTOOL)
#_OPSYS_MAX_CMDLEN!=	/sbin/sysctl -n kern.argmax
#.endif

# If games are to be installed setgid, then SETGIDGAME is set to 'yes'
# (it defaults to 'no' as per bsd.pkg.defaults.mk).
# Set the group and mode to meaningful values in that case (defaults to
# BINOWN, BINGRP and BINMODE as per bsd.pkg.defaults.mk).
# FIXME: Adjust to work on this system and enable the lines below.
#.if !(empty(SETGIDGAME:M[yY][eE][sS]))
#GAMEOWN=		games
#GAMEGRP=		games
#GAMEMODE=		2555
#.endif
