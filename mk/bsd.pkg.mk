#	$NetBSD: bsd.pkg.mk,v 1.1216.2.2 2003/07/24 09:25:58 jlam Exp $
#
# This file is in the public domain.
#
# This file is derived from bsd.port.mk - 940820 Jordan K. Hubbard.
#
# Please see the NetBSD packages(7) manual page for details on the
# that variables used in this make file template.

# Default sequence for "all" is:  fetch checksum extract patch configure build
#
# Please read the comments in the targets section below, you
# should be able to use the pre-* or post-* targets/scripts
# (which are available for every stage except checksum) or
# override the do-* targets to do pretty much anything you want.
#
# NEVER override the "regular" targets unless you want to open
# a major can of worms.

##### Include any preferences, if not already included, and common definitions
.include "../../mk/bsd.prefs.mk"

##### Prevent /etc/mk.conf from being included by a distribution's BSD-style
##### Makefiles.  We really don't want to pick up settings that are used by
##### builds in /usr/src, e.g. DESTDIR.
MAKE_ENV+=	MAKECONF=/dev/null

##### Pass information about desired toolchain to package build.
.if defined(USETOOLS)
MAKE_ENV+=	USETOOLS="${USETOOLS}"
.endif

##### Some NetBSD platforms permitted the user to set the binary format while
##### they were in the process of transitioning to ELF. Packages with BSD-style
##### make systems need this setting to be passed in.
.if defined(OBJECT_FMT)
MAKE_ENV+=	OBJECT_FMT="${OBJECT_FMT}"
.endif

##### Build crypto packages by default.
MKCRYPTO?=		yes

CLEANDEPENDS?=		NO
DEINSTALLDEPENDS?=	NO	# add -R to pkg_delete
REINSTALL?=		NO	# reinstall upon update
CHECK_SHLIBS?=		YES	# run check-shlibs after install
SHLIB_HANDLING?=	YES	# do automatic shared lib handling
NOCLEAN?=		NO	# don't clean up after update

PKGBASE?=		${PKGNAME:C/-[^-]*$//}
PKGVERSION?=		${PKGNAME:C/^.*-//}
PKGWILDCARD?=		${PKGBASE}-[0-9]*

_DISTDIR?=		${DISTDIR}/${DIST_SUBDIR}

INTERACTIVE_STAGE?=	none

# Set the default BUILDLINK_DIR, BUILDLINK_X11PKG_DIR,  BUILDLINK_X11_DIR so
# that if no buildlink2.mk files are included, then they still point to
# where headers and libraries for installed packages and X11R6 may be found.
#
USE_BUILDLINK2?=	no		# default to not using buildlink2
BUILDLINK_DIR?=		${LOCALBASE}
BUILDLINK_X11PKG_DIR?=	${X11BASE}
BUILDLINK_X11_DIR?=	${X11BASE}

.if defined(USE_IMAKE)
USE_X11BASE?=		implied
PLIST_SUBST+=          IMAKE_MAN_SOURCE_PATH=${IMAKE_MAN_SOURCE_PATH}  \
                       IMAKE_MAN_DIR=${IMAKE_MAN_DIR}                  \
                       IMAKE_LIBMAN_DIR=${IMAKE_LIBMAN_DIR}            \
                       IMAKE_FILEMAN_DIR=${IMAKE_FILEMAN_DIR}          \
                       IMAKE_MAN_SUFFIX=${IMAKE_MAN_SUFFIX}            \
                       IMAKE_LIBMAN_SUFFIX=${IMAKE_LIBMAN_SUFFIX}      \
                       IMAKE_FILEMAN_SUFFIX=${IMAKE_FILEMAN_SUFFIX}    \
                       IMAKE_MANNEWSUFFIX=${IMAKE_MANNEWSUFFIX}
.endif
.if defined(USE_X11BASE)
USE_X11?=		implied
.endif

# If xpkgwedge.def is found, then we need to require xpkgwedge as
# a build dependency for X11 packages.
#
.if exists(${LOCALBASE}/lib/X11/config/xpkgwedge.def) ||		\
    exists(${X11BASE}/lib/X11/config/xpkgwedge.def)
_OPSYS_NEEDS_XPKGWEDGE?=	yes
.else
_OPSYS_NEEDS_XPKGWEDGE?=	no
.endif

.if defined(USE_X11BASE)
.  if !empty(_OPSYS_NEEDS_XPKGWEDGE:M[yY][eE][sS])
BUILD_DEPENDS+=		xpkgwedge>=1.5:../../pkgtools/xpkgwedge
BUILDLINK_X11PKG_DIR=	${LOCALBASE}
.  endif
PREFIX=			${X11PREFIX}
.elif defined(USE_CROSSBASE)
PREFIX=			${CROSSBASE}
NO_MTREE=		yes
.else
PREFIX=			${LOCALBASE}
.endif

# We need to make sure the buildlink-x11 package is not installed since it
# breaks builds that use imake.
#
.if defined(USE_IMAKE)
.  if exists(${LOCALBASE}/lib/X11/config/buildlinkX11.def) || \
      exists(${X11BASE}/lib/X11/config/buildlinkX11.def)
PKG_FAIL_REASON+= "${PKGNAME} uses imake, but the buildlink-x11 package was found." \
	 "    Please deinstall it (pkg_delete buildlink-x11)."
.  endif
.endif	# USE_IMAKE

.if defined(USE_GMAKE)
.  if ${_OPSYS_HAS_GMAKE} == "no"
BUILD_DEPENDS+=		gmake>=3.78:../../devel/gmake
.  endif
MAKE_PROGRAM=		${GMAKE}
.else
.  if defined(USE_IMAKE)
MAKE_PROGRAM=		${_IMAKE_MAKE}
.  else
MAKE_PROGRAM=		${MAKE}
.  endif
.endif
CONFIGURE_ENV+=		MAKE="${MAKE_PROGRAM}"

.if defined(PKG_USE_KERBEROS)
RESTRICTED?=		uses Kerberos encryption code
BUILD_DEFS+=		KERBEROS
.endif

PERL5_REQD?=		5.0
PERL5_PKGSRCDIR?=	../../lang/perl5

# _PERL58_PATTERNS contains perl versions >=5.8.0 but before 6.0.
_PERL58_PATTERNS=	5.8.* 5.9* 5.[1-9][0-9]*

.if defined(_OPSYS_PERL_REQD) && ${_OPSYS_PERL_REQD} != ""
_PERL58_REQD?=		${_OPSYS_PERL_REQD}
.  for _pattern_ in ${_PERL58_PATTERNS}
.    if !empty(PERL5_REQD:M${_pattern_})
_PERL58_REQD:=		${PERL5_REQD}
.    endif
.  endfor
PERL5_REQD:=		${_PERL58_REQD}
.endif

# For perl>=5.8.0, we need to build perl from ../../lang/perl58.
.for _pattern_ in ${_PERL58_PATTERNS}
.  if !empty(PERL5_REQD:M${_pattern_})
PERL5_PKGSRCDIR=	../../lang/perl58
.  endif
.endfor

# Convert USE_PERL5 to be two-valued: either "build" or "run" to denote
# whether we want a build-time or run-time dependency on perl.
#
.if defined(USE_PERL5)
.  if (${USE_PERL5} == "build")
_PERL5_DEPMETHOD=	BUILD_DEPENDS
.  else
USE_PERL5:=		run
_PERL5_DEPMETHOD=	DEPENDS
.  endif
_PERL5_DEPENDS=		perl>=${PERL5_REQD}
.  if !defined(PERL5_BUILDLINK2_MK)
${_PERL5_DEPMETHOD}+=	${_PERL5_DEPENDS}:${PERL5_PKGSRCDIR}
.  endif
.endif

.if defined(USE_PERL5) && (${USE_PERL5} == "run")
.  if exists(${PERL5})
.    if exists(${LOCALBASE}/share/mk/bsd.perl.mk)
.      include "${LOCALBASE}/share/mk/bsd.perl.mk"
.    elif !defined(PERL5_SITELIB) || !defined(PERL5_SITEARCH) || !defined(PERL5_ARCHLIB)
PERL5_SITELIB!=		eval `${PERL5} -V:installsitelib 2>/dev/null`; \
			${ECHO} $${installsitelib}
PERL5_SITEARCH!=	eval `${PERL5} -V:installsitearch 2>/dev/null`; \
			${ECHO} $${installsitearch}
PERL5_ARCHLIB!=		eval `${PERL5} -V:installarchlib 2>/dev/null`; \
			${ECHO} $${installarchlib}
MAKEFLAGS+=		PERL5_SITELIB=${PERL5_SITELIB}
MAKEFLAGS+=		PERL5_SITEARCH=${PERL5_SITEARCH}
MAKEFLAGS+=		PERL5_ARCHLIB=${PERL5_ARCHLIB}
.    endif # !exists(bsd.perl.mk) && !defined(PERL5_*)
.  endif # exists($PERL5)
.endif # USE_PERL5 == run

.if defined(USE_FORTRAN)
.  if !exists(/usr/bin/f77)
PKG_FC?=		f2c-f77
.  endif
# it is anticipated that once /usr/bin/f77 is more stable that the following
# default will be changed to f77.  However, in the case where there is no
# /usr/bin/f77, the default will remain as f2c-f77.
.for __tmp__ in 1.[5-9]* [2-9].*
.  if ${MACHINE_PLATFORM:MNetBSD-${__tmp__}-*} != ""
PKG_FC?=		f77
.  endif    # MACHINE_PLATFORM
.endfor     # __tmp__
PKG_FC?=	f2c-f77
.  if  (${PKG_FC} == "f2c-f77")
# this is a DEPENDS not BUILD_DEPENDS because of the
# shared Fortran libs
.    if empty(USE_BUILDLINK2:M[nN][oO])
.      include "../../lang/f2c/buildlink2.mk"
.    else
DEPENDS+=	f2c>=20001205nb3:../../lang/f2c
.    endif
.  endif
FC=             ${PKG_FC}
F77=            ${PKG_FC}
CONFIGURE_ENV+=	F77="${F77}"
CONFIGURE_ENV+=	FFLAGS="${FFLAGS}"
MAKE_ENV+=	F77="${F77}"
MAKE_ENV+=	FC="${FC}"
.endif

# Automatically increase process limit where necessary for building.
_ULIMIT_CMD=
.if defined(UNLIMIT_RESOURCES)
.  for __tmp__ in ${UNLIMIT_RESOURCES}
.    if defined(ULIMIT_CMD_${__tmp__})
_ULIMIT_CMD+=	${ULIMIT_CMD_${__tmp__}} ;
.    endif
.  endfor
.endif

CPPFLAGS+=	${CPP_PRECOMP_FLAGS}

# If GNU_CONFIGURE is defined, then pass LIBS to the GNU configure script.
# also pass in a CONFIG_SHELL to avoid picking up bash
.if defined(GNU_CONFIGURE)
CONFIGURE_ENV+=		LIBS="${LIBS}"
CONFIG_SHELL?=		${SH}
CONFIGURE_ENV+=		CONFIG_SHELL=${CONFIG_SHELL}
.endif

.if defined(_OPSYS_LIBTOOL_REQD)
LIBTOOL_REQD=		${_OPSYS_LIBTOOL_REQD}
.else
LIBTOOL_REQD?=		1.4.20010614nb11
.endif
LIBTOOL=		${LOCALBASE}/bin/libtool
SHLIBTOOL=		${LOCALBASE}/bin/shlibtool
.if defined(USE_LIBTOOL)
PKGLIBTOOL=		${LIBTOOL}
PKGSHLIBTOOL=		${SHLIBTOOL}
BUILD_DEPENDS+=		libtool-base>=${LIBTOOL_REQD}:../../devel/libtool-base
CONFIGURE_ENV+=		LIBTOOL="${PKGLIBTOOL} ${LIBTOOL_FLAGS}"
MAKE_ENV+=		LIBTOOL="${PKGLIBTOOL} ${LIBTOOL_FLAGS}"
.endif

.if defined(BUILD_USES_MSGFMT) && \
    (!exists(/usr/bin/msgfmt) || ${_USE_GNU_GETTEXT} == "yes")
BUILD_DEPENDS+=		gettext>=0.10.35nb1:../../devel/gettext
.endif

EXTRACT_COOKIE=		${WRKDIR}/.extract_done
BUILDLINK_COOKIE=	${WRKDIR}/.buildlink_done
CONFIGURE_COOKIE=	${WRKDIR}/.configure_done
INSTALL_COOKIE=		${WRKDIR}/.install_done
TEST_COOKIE=		${WRKDIR}/.test_done
BUILD_COOKIE=		${WRKDIR}/.build_done
PATCH_COOKIE=		${WRKDIR}/.patch_done
PACKAGE_COOKIE=		${WRKDIR}/.package_done
INTERACTIVE_COOKIE=	.interactive_stage
NULL_COOKIE=		${WRKDIR}/.null

# New message digest defs
DIGEST_ALGORITHM?=	SHA1

# Miscellaneous overridable commands:
SHCOMMENT?=		${ECHO_MSG} >/dev/null '***'

DISTINFO_FILE?=		${.CURDIR}/distinfo

FIX_RPATH+=		LIBS
LDFLAGS+=		-Wl,${RPATH_FLAG}${LOCALBASE}/lib
LDFLAGS+=		-L${LOCALBASE}/lib
.if defined(USE_X11)
X11_LDFLAGS=		# empty
X11_LDFLAGS+=		-Wl,${RPATH_FLAG}${X11BASE}/lib
X11_LDFLAGS+=		-L${X11BASE}/lib
LDFLAGS+=		${X11_LDFLAGS}
.endif
FIX_RPATH+=		LDFLAGS
MAKE_ENV+=		LDFLAGS="${LDFLAGS}"
MAKE_ENV+=		RPATH_FLAG="${RPATH_FLAG}"
MAKE_ENV+=		WHOLE_ARCHIVE_FLAG="${WHOLE_ARCHIVE_FLAG}"
MAKE_ENV+=		NO_WHOLE_ARCHIVE_FLAG="${NO_WHOLE_ARCHIVE_FLAG}"
MAKE_ENV+=		LINK_ALL_LIBGCC_HACK="${LINK_ALL_LIBGCC_HACK}"

CONFIGURE_ENV+=		LDFLAGS="${LDFLAGS}" M4="${M4}" YACC="${YACC}"
CONFIGURE_ENV+=		RPATH_FLAG="${RPATH_FLAG}"

MAKE_FLAGS?=
MAKEFILE?=		Makefile
MAKE_ENV+=		PATH=${PATH}:${LOCALBASE}/bin:${X11BASE}/bin
MAKE_ENV+=		PREFIX=${PREFIX} LOCALBASE=${LOCALBASE}
MAKE_ENV+=		X11BASE=${X11BASE} CFLAGS="${CFLAGS}"
MAKE_ENV+=		CPPFLAGS="${CPPFLAGS}" FFLAGS="${FFLAGS}"
MAKE_ENV+=		X11PREFIX=${X11PREFIX}
.if defined(CC)
MAKE_ENV+=		CC="${CC}"
.endif
.if defined(CXX)
MAKE_ENV+=		CXX="${CXX}"
.endif
.if defined(CPP)
MAKE_ENV+=		CPP="${CPP}"
.endif

# Ensure the correct rpath is passed to the linker to enable packages
# to find shared libraries from gcc. Has no effect when pkgsrc gcc is
# not being used.
#
# Valid compilers are:
#
#	USE_GCC2    - GNU Compiler Collection 2.x
# 	USE_GCC3    - GNU Compiler Collection 3.x
#	USE_MIPSPRO - Silicon Graphics, Inc. MIPSpro Compiler
#	USE_SUNPRO  - Sun Microsystems, Inc. WorkShop/Forte/Sun ONE Studio
#	              Compiler Collection
#
.if !defined(USE_MIPSPRO) && !defined(USE_SUNPRO)
.  include "../../mk/gcc.buildlink2.mk"
.endif

# export the flags needed to compile and link pthreaded code
MAKE_ENV+=		PTHREAD_CFLAGS="${PTHREAD_CFLAGS}"
MAKE_ENV+=		PTHREAD_LDFLAGS="${PTHREAD_LDFLAGS}"

.if exists(${ZOULARISBASE}/bin/ftp)			# Zoularis
FETCH_CMD?=		${ZOULARISBASE}/bin/ftp
.else
FETCH_CMD?=		/usr/bin/ftp
.endif

TOUCH_FLAGS?=		-f

PATCH_STRIP?=		-p0
PATCH_DIST_STRIP?=	-p0
.if defined(PATCH_DEBUG) || defined(PKG_VERBOSE)
PATCH_DEBUG_TMP=	yes
PATCH_ARGS?=		-d ${WRKSRC} -E ${PATCH_STRIP}
PATCH_DIST_ARGS?=	-d ${WRKSRC} -E ${PATCH_DIST_STRIP}
.else
PATCH_DEBUG_TMP=	no
PATCH_ARGS?=		-d ${WRKSRC} --forward --quiet -E ${PATCH_STRIP}
PATCH_DIST_ARGS?=	-d ${WRKSRC} --forward --quiet -E ${PATCH_DIST_STRIP}
.endif
.if defined(BATCH)
PATCH_ARGS+=		--batch
PATCH_DIST_ARGS+=	--batch
.endif
.if defined(_PATCH_CAN_BACKUP) && ${_PATCH_CAN_BACKUP} == "yes"
PATCH_ARGS+=		${_PATCH_BACKUP_ARG} .orig
PATCH_DIST_ARGS+=	${_PATCH_BACKUP_ARG} .orig_dist
.endif
PATCH_FUZZ_FACTOR?=	-F0			# Default to zero fuzz

EXTRACT_SUFX?=		.tar.gz

# We need bzip2 for PATCHFILES with .bz2 suffix.
.if defined(PATCHFILES)
.  if ${PATCHFILES:E} == "bz2" && ${EXTRACT_SUFX} != ".tar.bz2"
.    if exists(/usr/bin/bzcat)
BZCAT=			/usr/bin/bzcat
.    else
BZCAT=			${LOCALBASE}/bin/bzcat
BUILD_DEPENDS+=		bzip2>=0.9.0b:../../archivers/bzip2
.    endif # !exists bzcat
.  endif
.endif # defined(PATCHFILES)

# Figure out where the local mtree file is
.if !defined(MTREE_FILE)
.  if defined(USE_X11BASE)
MTREE_FILE=	${_PKGSRCDIR}/mk/${OPSYS}.x11.dist
.  else
MTREE_FILE=	${_PKGSRCDIR}/mk/${OPSYS}.pkg.dist
.  endif
.endif # ! MTREE_FILE

MTREE_ARGS?=	-U -f ${MTREE_FILE} -d -e -p

# Debugging levels for this file, dependent on PKG_DEBUG_LEVEL definition
# 0 == normal, default, quiet operation
# 1 == all shell commands echoed before invocation
# 2 == shell "set -x" operation
PKG_DEBUG_LEVEL?=	0
_PKG_SILENT=		@
_PKG_DEBUG=		# empty
_PKG_DEBUG_SCRIPT=	# empty

.if ${PKG_DEBUG_LEVEL} > 0
_PKG_SILENT=		# empty
.endif

.if ${PKG_DEBUG_LEVEL} > 1
_PKG_DEBUG=		set -x;
_PKG_DEBUG_SCRIPT=	${SH} -x
.endif

WRKSRC?=		${WRKDIR}/${DISTNAME}

.if defined(NO_WRKSUBDIR)
PKG_FAIL_REASON+='NO_WRKSUBDIR has been deprecated - please replace it with an explicit'
PKG_FAIL_REASON+='assignment of WRKSRC= $${WRKDIR}'
.endif # NO_WRKSUBDIR

# A few aliases for *-install targets
PKGDIRMODE?=	755
INSTALL_PROGRAM?= \
	${INSTALL} ${COPY} ${_STRIPFLAG_INSTALL} -o ${BINOWN} -g ${BINGRP} -m ${BINMODE}
INSTALL_SCRIPT?= \
	${INSTALL} ${COPY} -o ${BINOWN} -g ${BINGRP} -m ${BINMODE}
INSTALL_DATA?= \
	${INSTALL} ${COPY} -o ${SHAREOWN} -g ${SHAREGRP} -m ${SHAREMODE}
INSTALL_MAN?= \
	${INSTALL} ${COPY} -o ${MANOWN} -g ${MANGRP} -m ${MANMODE}
INSTALL_PROGRAM_DIR?= \
	${INSTALL} -d -o ${BINOWN} -g ${BINGRP} -m ${PKGDIRMODE}
INSTALL_SCRIPT_DIR?= \
	${INSTALL_PROGRAM_DIR}
INSTALL_DATA_DIR?= \
	${INSTALL} -d -o ${SHAREOWN} -g ${SHAREGRP} -m ${PKGDIRMODE}
INSTALL_MAN_DIR?= \
	${INSTALL} -d -o ${MANOWN} -g ${MANGRP} -m ${PKGDIRMODE}

INSTALL_MACROS=	BSD_INSTALL_PROGRAM="${INSTALL_PROGRAM}"		\
		BSD_INSTALL_SCRIPT="${INSTALL_SCRIPT}"			\
		BSD_INSTALL_DATA="${INSTALL_DATA}"			\
		BSD_INSTALL_MAN="${INSTALL_MAN}"			\
		BSD_INSTALL="${INSTALL}"				\
		BSD_INSTALL_PROGRAM_DIR="${INSTALL_PROGRAM_DIR}"	\
		BSD_INSTALL_SCRIPT_DIR="${INSTALL_SCRIPT_DIR}"		\
		BSD_INSTALL_DATA_DIR="${INSTALL_DATA_DIR}"		\
		BSD_INSTALL_MAN_DIR="${INSTALL_MAN_DIR}"
MAKE_ENV+=	${INSTALL_MACROS}
SCRIPTS_ENV+=	${INSTALL_MACROS}

# The user can override the NO_PACKAGE by specifying this from
# the make command line
.if defined(FORCE_PACKAGE)
.  undef NO_PACKAGE
.endif

.if !defined(COMMENT)
COMMENT!=	(${CAT} ${PKGDIR}/COMMENT || ${ECHO} -n "(no description)") 2>/dev/null
.endif

DESCR=			${WRKDIR}/.DESCR
.if !defined(DESCR_SRC)
DESCR_SRC?=		${PKGDIR}/DESCR
.endif
PLIST=			${WRKDIR}/.PLIST

# Automatic platform dependent PLIST handling
.if !defined(PLIST_SRC)
.  if exists(${PKGDIR}/PLIST.common)
PLIST_SRC=		${PKGDIR}/PLIST.common
.    if exists(${PKGDIR}/PLIST.${OPSYS})
PLIST_SRC+=		${PKGDIR}/PLIST.${OPSYS}
.    endif
.    if exists(${PKGDIR}/PLIST.common_end)
PLIST_SRC+=		${PKGDIR}/PLIST.common_end
.    endif
.  elif exists(${PKGDIR}/PLIST.${OPSYS})
PLIST_SRC=		${PKGDIR}/PLIST.${OPSYS}
.  else
PLIST_SRC=		${PKGDIR}/PLIST
.  endif
.endif

DLIST=			${WRKDIR}/.DLIST
DDIR=			${WRKDIR}/.DDIR


# Set PLIST_SUBST to substitute "${variable}" to "value" in PLIST
PLIST_SUBST+=	OPSYS=${OPSYS}						\
		OS_VERSION=${OS_VERSION}				\
		MACHINE_ARCH=${MACHINE_ARCH}				\
		MACHINE_GNU_ARCH=${MACHINE_GNU_ARCH}			\
		MACHINE_GNU_PLATFORM=${MACHINE_GNU_PLATFORM}		\
		LN=${LN:Q}						\
		LOWER_VENDOR=${LOWER_VENDOR}				\
		LOWER_OPSYS=${LOWER_OPSYS}				\
		LOWER_OS_VERSION=${LOWER_OS_VERSION}			\
		PKGBASE=${PKGBASE}					\
		PKGNAME=${PKGNAME_NOREV}				\
		PKGLOCALEDIR=${PKGLOCALEDIR}				\
		PKGVERSION=${PKGVERSION:C/nb[0-9]*$//}			\
		LOCALBASE=${LOCALBASE}					\
		X11BASE=${X11BASE}					\
		X11PREFIX=${X11PREFIX}					\
		SVR4_PKGNAME=${SVR4_PKGNAME}				\
		CHGRP=${CHGRP:Q}					\
		CHMOD=${CHMOD:Q}					\
		CHOWN=${CHOWN:Q}					\
		INSTALL_INFO=${INSTALL_INFO:Q}				\
		MKDIR=${MKDIR:Q}					\
		RMDIR=${RMDIR:Q}					\
		RM=${RM:Q}						\
		TRUE=${TRUE:Q}						\
		QMAILDIR=${QMAILDIR}
.if defined(PERL5_SITELIB)
PLIST_SUBST+=	PERL5_SITELIB=${PERL5_SITELIB:S/^${LOCALBASE}\///}
.endif
.if defined(PERL5_SITEARCH)
PLIST_SUBST+=	PERL5_SITEARCH=${PERL5_SITEARCH:S/^${LOCALBASE}\///}
.endif
.if defined(PERL5_ARCHLIB)
PLIST_SUBST+=	PERL5_ARCHLIB=${PERL5_ARCHLIB:S/^${LOCALBASE}\///}
.endif

.if defined(USE_NEW_TEXINFO)
.  if defined(INFO_FILES)
.    include "../../mk/texinfo.mk"
.  endif
.endif

.if defined(USE_PKGINSTALL) && !empty(USE_PKGINSTALL:M[yY][eE][sS])
.  include "../../mk/bsd.pkg.install.mk"
.endif

# Set INSTALL_FILE to be the name of any INSTALL file
.if !defined(INSTALL_FILE) && exists(${PKGDIR}/INSTALL)
INSTALL_FILE=		${PKGDIR}/INSTALL
.endif

# Set DEINSTALL_FILE to be the name of any DEINSTALL file
.if !defined(DEINSTALL_FILE) && exists(${PKGDIR}/DEINSTALL)
DEINSTALL_FILE=		${PKGDIR}/DEINSTALL
.endif

# If MESSAGE hasn't been defined, then set MESSAGE_SRC to be a space-separated
# list of files to be concatenated together to generate the MESSAGE file.
#
.if !defined(MESSAGE_SRC) && !defined(MESSAGE)
.  if exists(${PKGDIR}/MESSAGE)
MESSAGE_SRC=		${PKGDIR}/MESSAGE
.  else
.    if exists(${PKGDIR}/MESSAGE.common)
MESSAGE_SRC=		${PKGDIR}/MESSAGE.common
.    endif
.    if exists(${PKGDIR}/MESSAGE.${OPSYS})
MESSAGE_SRC+=		${PKGDIR}/MESSAGE.${OPSYS}
.    endif
.    if exists(${PKGDIR}/MESSAGE.${MACHINE_ARCH:C/i[3-6]86/i386/g})
MESSAGE_SRC+=	${PKGDIR}/MESSAGE.${MACHINE_ARCH:C/i[3-6]86/i386/g}
.    endif
.    if exists(${PKGDIR}/MESSAGE.${OPSYS}-${MACHINE_ARCH:C/i[3-6]86/i386/g})
MESSAGE_SRC+=	${PKGDIR}/MESSAGE.${OPSYS}-${MACHINE_ARCH:C/i[3-6]86/i386/g}
.    endif
.  endif
.endif

.if defined(MESSAGE_SRC)
MESSAGE=		${WRKDIR}/.MESSAGE

# Set MESSAGE_SUBST to substitute "${variable}" to "value" in MESSAGE
MESSAGE_SUBST+=	PKGNAME=${PKGNAME}					\
		PREFIX=${PREFIX}					\
		LOCALBASE=${LOCALBASE}					\
		X11PREFIX=${X11PREFIX}					\
		X11BASE=${X11BASE}					\
		PKG_SYSCONFDIR=${PKG_SYSCONFDIR}			\
		ROOT_GROUP=${ROOT_GROUP}				\
		ROOT_USER=${ROOT_USER}					\
		QMAILDIR=${QMAILDIR}

MESSAGE_SUBST_SED=	${MESSAGE_SUBST:S/=/}!/:S/$/!g/:S/^/ -e s!\\\${/}
.endif

PKGCONFIG_OVERRIDE_SED=	\
		'-e s|^\(Libs:.*[ 	]\)-L\([ 	]*[^ 	]*\)\(.*\)$$|\1-Wl,${RPATH_FLAG}\2 -L\2\3|'

# Latest version of digest(1) required for pkgsrc
DIGEST_REQD=		20010302

.PHONY: uptodate-digest
uptodate-digest:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -f ${DISTINFO_FILE} -a \( ! -f ${DIGEST} -o ${DIGEST_VERSION} -lt ${DIGEST_REQD} \) ]; then \
		{ cd ${_PKGSRCDIR}/pkgtools/digest;			\
		${MAKE} clean;						\
		if [ -f ${DIGEST} ]; then				\
			${MAKE} ${MAKEFLAGS} deinstall;			\
		fi;							\
		${MAKE} ${MAKEFLAGS} ${DEPENDS_TARGET};			\
		${MAKE} ${MAKEFLAGS} clean; } 				\
	fi

# Latest version of pkgtools required for correct pkgsrc operation.
.if defined(_OPSYS_PKGTOOLS_REQD)
PKGTOOLS_REQD=		${_OPSYS_PKGTOOLS_REQD}
.else
PKGTOOLS_REQD=		20021123
.endif

# Check that we are using up-to-date pkg_* tools with this file.
.PHONY: uptodate-pkgtools uptodate-zoularis
.if defined(ZOULARIS_VERSION)
uptodate-pkgtools: uptodate-zoularis
.else
uptodate-pkgtools:
.endif
.	if !defined(NO_PKGTOOLS_REQD_CHECK)
.		if ${PKGTOOLS_VERSION} < ${PKGTOOLS_REQD}
PKG_FAIL_REASON+='Your package tools need to be updated to ${PKGTOOLS_REQD:C|(....)(..)(..)|\1/\2/\3|} versions.'
PKG_FAIL_REASON+='The installed package tools were last updated on ${PKGTOOLS_VERSION:C|(....)(..)(..)|\1/\2/\3|}.'
PKG_FAIL_REASON+='To fix this, use the following command:'
PKG_FAIL_REASON+='	cd ${_PKGSRCDIR}/pkgtools/pkg_install && ${MAKE} install'
.		endif
.	endif

# Latest version of Zoularis required for this file.
ZOULARIS_REQD=		20010323

# Check that we are using up-to-date Zoularis.
.if defined(ZOULARIS_VERSION)
uptodate-zoularis:
.	if ${ZOULARIS_VERSION} < ${ZOULARIS_REQD}
PKG_FAIL_REASON+='Your Zoularis needs to be updated to the ${ZOULARIS_REQD:C|(....)(..)(..)|\1/\2/\3|} version.'
PKG_FAIL_REASON+='The installed Zoularis was last updated on ${ZOULARIS_VERSION:C|(....)(..)(..)|\1/\2/\3|}.'
.	endif
.endif

# Files to create for versioning and build information
BUILD_VERSION_FILE=	${WRKDIR}/.build_version
BUILD_INFO_FILE=	${WRKDIR}/.build_info

# Files containing size of pkg w/o and w/ all required pkgs
SIZE_PKG_FILE=		${WRKDIR}/.SizePkg
SIZE_ALL_FILE=		${WRKDIR}/.SizeAll

# File to denote "no deletion of a package"
PRESERVE_FILE=		${WRKDIR}/.PRESERVE

.ifndef PKG_ARGS_COMMON
PKG_ARGS_COMMON=	-v -c -${COMMENT:Q}" " -d ${DESCR} -f ${PLIST}
PKG_ARGS_COMMON+=	-l -b ${BUILD_VERSION_FILE} -B ${BUILD_INFO_FILE}
PKG_ARGS_COMMON+=	-s ${SIZE_PKG_FILE} -S ${SIZE_ALL_FILE}
PKG_ARGS_COMMON+=	-P "`${MAKE} ${MAKEFLAGS} run-depends-list PACKAGE_DEPENDS_QUICK=true | ${SORT} -u`"
.  ifdef CONFLICTS
PKG_ARGS_COMMON+=	-C "${CONFLICTS}"
.  endif
.  ifdef INSTALL_FILE
PKG_ARGS_COMMON+=	-i ${INSTALL_FILE}
.  endif
.  ifdef DEINSTALL_FILE
PKG_ARGS_COMMON+=	-k ${DEINSTALL_FILE}
.  endif
.  ifdef MESSAGE
PKG_ARGS_COMMON+=	-D ${MESSAGE}
.  endif
.  ifndef NO_MTREE
PKG_ARGS_COMMON+=	-m ${MTREE_FILE}
.  endif
.  ifdef PKG_PRESERVE
PKG_ARGS_COMMON+=	-n ${PRESERVE_FILE}
.  endif

PKG_ARGS_INSTALL=	-p ${PREFIX} ${PKG_ARGS_COMMON}
PKG_ARGS_BINPKG=	-p ${PREFIX:S/^${DESTDIR}//} -L ${PREFIX} ${PKG_ARGS_COMMON}
.endif # !PKG_ARGS_COMMON

PKG_SUFX?=		.tgz
#PKG_SUFX?=		.tbz		# bzip2(1) pkgs

# Define SMART_MESSAGES in /etc/mk.conf for messages giving the tree
# of dependencies for building, and the current target.
.ifdef SMART_MESSAGES
_PKGSRC_IN?=		===> ${.TARGET} [${PKGNAME}${_PKGSRC_DEPS}] ===
.else
_PKGSRC_IN?=		===
.endif

# Used to print all the '===>' style prompts - override this to turn them off.
ECHO_MSG?=		${ECHO}

# How to do nothing.  Override if you, for some strange reason, would rather
# do something.
DO_NADA?=		${TRUE}

ALL_TARGET?=		all
INSTALL_TARGET?=	install

.if defined(USE_IMAKE) && !defined(NO_INSTALL_MANPAGES)
INSTALL_TARGET+=	install.man
.endif

# If this host is behind a filtering firewall, use passive ftp(1)
.if defined(PASSIVE_FETCH)
FETCH_BEFORE_ARGS += -p
.endif

# Check if we got "rman" with XFree86, for packages that need "rman".
.if defined(USE_RMAN)
.  if !exists(${X11BASE}/bin/rman)
DEPENDS+=		rman-3.0.9:../../textproc/rman
RMAN?=			${LOCALBASE}/bin/rman
.  else
RMAN?=			${X11BASE}/bin/rman
.  endif
.endif

# FIX_RPATH will remove compiler or linker settings related to run-time
# library search path settings if _USE_RPATH is "no".
#
.if !empty(_USE_RPATH:M[nN][oO])
.  if defined(FIX_RPATH) && !empty(FIX_RPATH)
.    for var in ${FIX_RPATH}
.      for _rpath_flag in ${RPATH_FLAG} -R -rpath -rpath-link
${var}:=	${${var}:N-Wl,${_rpath_flag}*:N${_rpath_flag}*}
.      endfor
.    endfor
.  endif
.endif

.if defined(EVAL_PREFIX)
.  for def in ${EVAL_PREFIX}
.    if !defined(${def:C/=.*//}_DEFAULT)
${def:C/=.*//}_DEFAULT=	${X11PREFIX}
.    endif
.    if !defined(${def:C/=.*//})
_depend_${def:C/=.*//} != ${PKG_INFO} -e ${def:C/.*=//} 2>/dev/null; ${ECHO}
.      if (${_depend_${def:C/=.*//}} == "")
${def:C/=.*//}=${${def:C/=.*//}_DEFAULT}
.      else
_dir_${def:C/=.*//} != (${PKG_INFO} -qp ${def:C/.*=//} 2>/dev/null) | ${AWK} '{ print $$2; exit }'
${def:C/=.*//}=${_dir_${def:C/=.*//}}
MAKEFLAGS+= ${def:C/=.*//}=${_dir_${def:C/=.*//}}
.      endif
.    endif
.  endfor
.endif

# Set the CLASSPATH for Java packages.  This must come after EVAL_PREFIX
# is evaluated because PKG_JAVA_HOME is used in a .if.endif conditional,
# and it's value is indirectly set by EVAL_PREFIX.
#
.if defined(USE_JAVA)
.  if exists(${PKG_JAVA_HOME}/lib/${_JAVA_BASE_CLASSES})
_JAVA_CLASSES_ZIP=	${PKG_JAVA_HOME}/lib/${_JAVA_BASE_CLASSES}:
.  endif
.  if exists(${PKG_JAVA_HOME}/lib/tools.jar)
_JAVA_TOOLS_JAR=	${PKG_JAVA_HOME}/lib/tools.jar:
.  endif
CLASSPATH?=		${_JAVA_CLASSES_ZIP}${_JAVA_TOOLS_JAR}.

MAKE_ENV+=		CLASSPATH=${CLASSPATH}
CONFIGURE_ENV+=		CLASSPATH=${CLASSPATH}
SCRIPTS_ENV+=		CLASSPATH=${CLASSPATH}
.endif

# Popular master sites
MASTER_SITE_XCONTRIB+=	\
	ftp://uiarchive.uiuc.edu/pub/ftp/ftp.x.org/contrib/ \
	ftp://sunsite.doc.ic.ac.uk/packages/X11/contrib/ \
	ftp://ftp.gwdg.de/pub/x11/x.org/contrib/ \
	ftp://ftp.sunet.se/pub/X11/contrib/ \
	ftp://sunsite.sut.ac.jp/pub/archives/X11/contrib/ \
	ftp://sunsite.icm.edu.pl/pub/X11/contrib/ \
	ftp://ftp.task.gda.pl/mirror/ftp.x.org/contrib/ \
	ftp://ftp.ntua.gr/pub/X11/contrib/ \
	ftp://sunsite.cnlab-switch.ch/mirror/X11/contrib/ \
	ftp://ftp.cica.es/pub/X/contrib/ \
	ftp://ftp.unicamp.br/pub/X11/contrib/ \
	ftp://ftp.x.org/contrib/

MASTER_SITE_GNU+=	\
	ftp://ftp.gnu.org/pub/gnu/ \
	ftp://ftp.gwdg.de/pub/gnu/ \
	ftp://ftp.progsoc.uts.edu.au/pub/gnu/ \
	ftp://gatekeeper.dec.com/pub/GNU/ \
	ftp://ftp.uu.net/archive/systems/gnu/ \
	ftp://ftp.de.uu.net/pub/gnu/ \
	ftp://ftp.funet.fi/pub/gnu/prep/ \
	ftp://ftp.leo.org/pub/comp/os/unix/gnu/ \
	ftp://ftp.digex.net/pub/gnu/ \
	ftp://ftp.wustl.edu/mirrors/gnu/ \
	ftp://ftp.kddlabs.co.jp/pub/gnu/ \
	ftp://ftp.dti.ad.jp/pub/GNU/ \
	ftp://ftp.mirror.ac.uk/sites/ftp.gnu.org/gnu/ \
	ftp://sunsite.org.uk/Mirrors/ftp.gnu.org/pub/gnu/ \
	ftp://ftp.informatik.hu-berlin.de/pub/gnu/ \
	ftp://ftp.rediris.es/mirror/gnu/ \
	ftp://ftp.lip6.fr/pub/gnu/ \
	ftp://ftp.tuwien.ac.at/linux/gnu/gnusrc/ \
	ftp://ftp.chg.ru/pub/gnu/

MASTER_SITE_GNUSTEP+=	\
	ftp://ftp.gnustep.org/pub/gnustep/ \
	http://public.planetmirror.com.au/pub/gnustep/gnustep/ \
	http://www.peanuts.org/peanuts/Mirrors/GNUstep/gnustep/ \
	ftp://archive.progeny.com/gnustep/ \
	http://archive.progeny.com/gnustep/ \
	ftp://ftp.easynet.nl/mirror/GNUstep/ \
	http://ftp.easynet.nl/mirror/GNUstep/

MASTER_SITE_PERL_CPAN+=	\
	ftp://cpan.pair.com/pub/CPAN/modules/by-module/ \
	ftp://mirrors.cloud9.net/pub/mirrors/CPAN/modules/by-module/ \
	ftp://ftp.sunet.se/pub/lang/perl/CPAN/modules/by-module/ \
	ftp://ftp.uvsq.fr/pub/perl/CPAN/modules/by-module/ \
	ftp://ftp.gmd.de/mirrors/CPAN/modules/by-module/ \
	ftp://ftp.tuwien.ac.at/pub/CPAN/modules/by-module/ \
	ftp://cpan.perl.org/CPAN/modules/by-module/

MASTER_SITE_R_CRAN+=	\
	http://cran.r-project.org/src/ \
	ftp://cran.r-project.org/pub/R/src/ \
	http://cran.at.r-project.org/src/ \
	ftp://cran.at.r-project.org/pub/R/src/ \
	http://cran.dk.r-project.org/src/ \
	http://cran.ch.r-project.org/src/ \
	http://cran.uk.r-project.org/src/ \
	http://cran.us.r-project.org/src/ \
	http://lib.stat.cmu.edu/R/CRAN/src/ \
	ftp://ftp.biostat.washington.edu/mirrors/R/CRAN/src/ \
	http://cran.stat.wisc.edu/src/ \
	http://SunSITE.auc.dk/R/src/ \
	http://www.stat.unipg.it/pub/stat/statlib/R/CRAN/src/ \
	ftp://ftp.u-aizu.ac.jp/pub/lang/R/CRAN/src/ \
	ftp://dola.snu.ac.kr/pub/R/CRAN/src/ \
	http://stat.ethz.ch/CRAN/src/ \
	http://www.stats.bris.ac.uk/R/src/

MASTER_SITE_TEX_CTAN+= \
	ftp://ftp.wustl.edu/packages/TeX/ \
	ftp://ftp.funet.fi/pub/TeX/CTAN/ \
	ftp://ftp.tex.ac.uk/public/ctan/tex-archive/ \
	ftp://ftp.dante.de/tex-archive/

MASTER_SITE_SUNSITE+=	\
	ftp://sunsite.unc.edu/pub/Linux/ \
	ftp://ftp.infomagic.com/pub/mirrors/linux/sunsite/ \
	ftp://ftp.chg.ru/pub/Linux/sunsite/ \
	ftp://ftp.is.co.za/linux/sunsite/ \
	ftp://ftp.kddlabs.co.jp/Linux/metalab.unc.edu/ \
	ftp://ftp.kobe-u.ac.jp/pub/Linux/metalab.unc.edu/ \
	ftp://ftp.cse.cuhk.edu.hk/pub4/Linux/ \
	ftp://ftp.icm.edu.pl/pub/Linux/sunsite/ \
	ftp://ftp.nvg.ntnu.no/pub/mirrors/metalab.unc.edu/ \
	ftp://ftp.uvsq.fr/pub5/linux/sunsite/ \
	ftp://ftp.lip6.fr/pub/linux/sunsite/ \
	ftp://ftp.uni-stuttgart.de/pub/mirror/sunsite.unc.edu/pub/Linux/ \
	ftp://ftp.uni-magdeburg.de/pub/mirror/linux/ftp.metalab.unc.edu/ \
	ftp://ftp.uni-jena.de/pub/linux/MIRROR.sunsite/ \
	ftp://ftp.fu-berlin.de/unix/linux/mirrors/sunsite.unc.edu/ \
	ftp://ftp.cs.tu-berlin.de/pub/linux/Mirrors/sunsite.unc.edu/ \
	ftp://sunsite.cnlab-switch.ch/mirror/linux/sunsite/ \
	ftp://ftp.tuwien.ac.at/pub/linux/ibiblio/ \
	ftp://ftp.unicamp.br/pub/systems/Linux/

MASTER_SITE_GNOME+=	\
	ftp://ftp.gnome.org/pub/GNOME/ \
	ftp://ftp.sunet.se/pub/X11/GNOME/ \
	ftp://ftp.tuwien.ac.at/hci/GNOME/ \
	ftp://ftp.cse.buffalo.edu/pub/Gnome/ \
	ftp://ftp.tuwien.ac.at/linux/gnome.org/ \
	ftp://ftp.dti.ad.jp/pub/X/gnome/ \
	ftp://ftp.kddlabs.co.jp/pub/GNOME/ \
	ftp://ftp.chg.ru/pub/X11/gnome/ \
	ftp://ftp.dataplus.se/pub/linux/gnome/ \
	ftp://ftp.dit.upm.es/linux/gnome/ \
	ftp://ftp.mirror.ac.uk/sites/ftp.gnome.org/pub/GNOME/

MASTER_SITE_SOURCEFORGE+=	\
	http://aleron.dl.sourceforge.net/sourceforge/ \
	http://cesnet.dl.sourceforge.net/sourceforge/ \
	http://easynews.dl.sourceforge.net/sourceforge/ \
	http://flow.dl.sourceforge.net/sourceforge/ \
	http://heanet.dl.sourceforge.net/sourceforge/ \
	http://switch.dl.sourceforge.net/sourceforge/ \
	http://telia.dl.sourceforge.net/sourceforge/ \
	http://twtelecom.dl.sourceforge.net/sourceforge/ \
	http://umn.dl.sourceforge.net/sourceforge/ \
	http://unc.dl.sourceforge.net/sourceforge/ \
	http://osdn.dl.sourceforge.net/sourceforge/ \
	ftp://ftp3.sourceforge.net/pub/sourceforge/ \
	ftp://ftp.tuwien.ac.at/linux/sourceforge/

MASTER_SITE_SUSE+=	\
	ftp://fr2.rpmfind.net/linux/SuSE-Linux/suse/${MACHINE_ARCH}/${SUSE_VERSION}/suse/ \
	ftp://ftp.duth.gr/pub/suse/${MACHINE_ARCH}/${SUSE_VERSION}/suse/ \
	ftp://ftp.kddlabs.co.jp/Linux/packages/SuSE/suse/${MACHINE_ARCH}/${SUSE_VERSION}/suse/ \
	ftp://sunsite.cnlab-switch.ch/mirror/SuSE/suse/${MACHINE_ARCH}/${SUSE_VERSION}/suse/ \
	ftp://ftp.mirror.ac.uk/sites/ftp.suse.com/pub/suse/${MACHINE_ARCH}/${SUSE_VERSION}/suse/ \
	ftp://mirror.mcs.anl.gov/pub/ftp.suse.com/${MACHINE_ARCH}/${SUSE_VERSION}/suse/

MASTER_SITE_MOZILLA+=	\
	ftp://ftp.mozilla.org/pub/mozilla/releases/ \
	ftp://ftp.fu-berlin.de/pub/unix/network/www/mozilla/releases/ \
	ftp://sunsite.utk.edu/pub/netscape-source/ \
	ftp://ftp.informatik.uni-bonn.de/pub/www/mozilla/ \
	ftp://ftp-stud.fht-esslingen.de/pub/Mirrors/ftp.mozilla.org/pub/ \
	ftp://sunsite.auc.dk/pub/mozilla/ \
	ftp://ftp.funet.fi/pub/mirrors/ftp.mozilla.org/pub/ \
	ftp://ftp.sunsite.kth.se/archive/www/ftp.mozilla.org/ \
	http://public.planetmirror.com.au/pub/mozilla/releases/ \
	ftp://ftp2.sinica.edu.tw/pub3/www/mozilla/ \
	ftp://ftp.is.co.za/networking/info-service/www/clients/netscape/mozilla/ \
	ftp://ftp.rediris.es/mirror/mozilla/ \
	ftp://ftp.chg.ru/pub/WWW/mozilla/

MASTER_SITE_XEMACS+=	\
	ftp://ftp.xemacs.org/pub/xemacs/ \
	ftp://ftp.dti.ad.jp/pub/unix/editor/xemacs/ \
	ftp://ftp.jaist.ac.jp/pub/GNU/xemacs/ \
	ftp://ftp.pasteur.fr/pub/computing/xemacs/ \
	ftp://ftp.tu-darmstadt.de/pub/editors/xemacs/ \
	http://public.planetmirror.com.au/pub/xemacs/ \
	ftp://mirror.aarnet.edu.au/pub/xemacs/ \
	ftp://mirror.cict.fr/xemacs/ \
	ftp://mirror.nucba.ac.jp/mirror/xemacs/ \
	ftp://ring.aist.go.jp/pub/text/xemacs/ \
	ftp://ring.asahi-net.or.jp/pub/text/xemacs/

MASTER_SITE_APACHE+=	\
	http://www.apache.org/dist/ \
	http://mirrors.midco.net/pub/apache.org/ \
	http://apache.mirror.digitalspace.net/ \
	http://apache.mirrorcentral.com/dist/ \
	http://www.rge.com/pub/infosystems/apache/ \
	http://mirrors.ccs.neu.edu/Apache/dist/ \
	http://www.apache.inetcosmos.org/dist/ \
	http://www.ibiblio.org/pub/packages/infosystems/WWW/servers/apache/ \
	http://apache.ttlhost.com/ \
	http://apache.towardex.com/ \
	http://mirrors.theonlinerecordstore.com/apache/ \
	http://apache.oregonstate.edu/ \
	http://mirror.telentente.com/pub/apache/dist/ \
	http://www.tux.org/pub/net/apache/dist/ \
	http://apache.secsup.org/dist/ \
	http://ftp.epix.net/apache/ \
	http://public.planetmirror.com.au/pub/apache/dist/ \
	ftp://ftp.rge.com/pub/infosystems/apache/ \
	ftp://ftp.epix.net/pub/apache/ \
	ftp://ftp.ccs.neu.edu/net/mirrors/Apache/dist/ \
	ftp://ftp.tux.org/pub/net/apache/dist/ \
	ftp://ftp.apache.inetcosmos.org/pub/apache/dist/ \
	ftp://www.ibiblio.org/pub/packages/infosystems/WWW/servers/apache/ \
	ftp://ftp.knowledge.com/pub/mirrors/apache/dist/ \
	ftp://ftp.sunsite.utk.edu/pub/apache/dist/ \
	ftp://ftp.oregonstate.edu/pub/apache/ \
	ftp://apache.secsup.org/pub/apache/dist/ \
	ftp://mirror.telentente.com/pub/apache/dist/ \
	ftp://mirrors.midco.net/pub/apache.org/ \
	http://nagoya.apache.org/mirror/

MASTER_SITE_DEBIAN+= \
	http://ftp.debian.org/debian/ \
	http://ftp.at.debian.org/debian/ \
	http://ftp.au.debian.org/debian/ \
	http://ftp.wa.au.debian.org/debian/ \
	http://ftp.bg.debian.org/debian/ \
	http://ftp.br.debian.org/debian/ \
	http://ftp.cl.debian.org/debian/ \
	http://ftp.cz.debian.org/debian/ \
	http://ftp.de.debian.org/debian/ \
	http://ftp2.de.debian.org/debian/ \
	http://ftp.dk.debian.org/debian/ \
	http://ftp.ee.debian.org/debian/ \
	http://ftp.es.debian.org/debian/ \
	http://ftp.fi.debian.org/debian/ \
	http://ftp.fr.debian.org/debian/ \
	http://ftp2.fr.debian.org/debian/ \
	http://ftp.uk.debian.org/debian/ \
	http://ftp.hk.debian.org/debian/ \
	http://ftp.hr.debian.org/debian/ \
	http://ftp.hu.debian.org/debian/ \
	http://ftp.ie.debian.org/debian/ \
	http://ftp.is.debian.org/debian/ \
	http://ftp.it.debian.org/debian/ \
	http://ftp2.it.debian.org/debian/ \
	http://ftp.jp.debian.org/debian/ \
	http://ftp.nl.debian.org/debian/ \
	http://ftp.no.debian.org/debian/ \
	http://ftp.nz.debian.org/debian/ \
	http://ftp.pl.debian.org/debian/ \
	http://ftp.ru.debian.org/debian/ \
	http://ftp.se.debian.org/debian/ \
	http://ftp.si.debian.org/debian/ \
	http://ftp.sk.debian.org/debian/ \
	http://ftp.tr.debian.org/debian/ \
	http://ftp.us.debian.org/debian/

# The primary backup site.
MASTER_SITE_BACKUP?=	\
	ftp://ftp.fi.netbsd.org/pub/NetBSD/packages/distfiles/ \
	ftp://ftp.netbsd.org/pub/NetBSD/packages/distfiles/ \
	ftp://ftp.freebsd.org/pub/FreeBSD/distfiles/
.if defined(DIST_SUBDIR)
_MASTER_SITE_BACKUP:=	${MASTER_SITE_BACKUP:=${DIST_SUBDIR}/}
.  if defined(MASTER_SITE_OVERRIDE)
_MASTER_SITE_OVERRIDE:=	${MASTER_SITE_OVERRIDE:=${DIST_SUBDIR}/}
.  endif # MASTER_SITE_OVERRIDE
.else  # !DIST_SUBDIR
_MASTER_SITE_BACKUP:=	${MASTER_SITE_BACKUP}
.  if defined(MASTER_SITE_OVERRIDE)
_MASTER_SITE_OVERRIDE:= ${MASTER_SITE_OVERRIDE}
.  endif # MASTER_SITE_OVERRIDE
.endif # DIST_SUBDIR

# Where to put distfiles that don't have any other master site
MASTER_SITE_LOCAL?= \
	${MASTER_SITE_BACKUP:=LOCAL_PORTS/} \

# Derived names so that they're easily overridable.
DISTFILES?=		${DISTNAME}${EXTRACT_SUFX}
.if defined(PKGREVISION) && ${PKGREVISION} != "" && ${PKGREVISION} != "0"
.  if defined(PKGNAME)
PKGNAME_NOREV:=		${PKGNAME}
PKGNAME:=		${PKGNAME}nb${PKGREVISION}
.  else
PKGNAME?=		${DISTNAME}nb${PKGREVISION}
PKGNAME_NOREV=		${DISTNAME}
.  endif
.else
PKGNAME?=		${DISTNAME}
PKGNAME_NOREV=		${PKGNAME}
.endif
SVR4_PKGNAME?=		${PKGNAME}

MAINTAINER?=		tech-pkg@netbsd.org

ALLFILES?=	${DISTFILES} ${PATCHFILES}
CKSUMFILES?=	${ALLFILES}
.for __tmp__ in ${IGNOREFILES}
CKSUMFILES:=	${CKSUMFILES:N${__tmp__}}
.endfor

# List of all files, with ${DIST_SUBDIR} in front.  Used for fetch and checksum.
.if defined(DIST_SUBDIR)
.  if ${CKSUMFILES} != ""
_CKSUMFILES?=	${CKSUMFILES:S/^/${DIST_SUBDIR}\//}
.  endif
_DISTFILES?=	${DISTFILES:S/^/${DIST_SUBDIR}\//}
_IGNOREFILES?=	${IGNOREFILES:S/^/${DIST_SUBDIR}\//}
_PATCHFILES?=	${PATCHFILES:S/^/${DIST_SUBDIR}\//}
.else
_CKSUMFILES?=	${CKSUMFILES}
_DISTFILES?=	${DISTFILES}
_IGNOREFILES?=	${IGNOREFILES}
_PATCHFILES?=	${PATCHFILES}
.endif
_ALLFILES?=	${_DISTFILES} ${_PATCHFILES}

# This is what is actually going to be extracted, and is overridable
#  by user.
EXTRACT_ONLY?=	${DISTFILES}

.if !defined(CATEGORIES) || !defined(DISTNAME)
PKG_FAIL_REASON+='CATEGORIES and DISTNAME are mandatory.'
.endif

.if defined(LIB_DEPENDS)
PKG_FAIL_REASON+='LIB_DEPENDS is deprecated and must be replaced with DEPENDS.'
.endif

.if defined(PKG_PATH)
PKG_FAIL_REASON+='Please unset PKG_PATH before doing pkgsrc work!'
.endif

.if defined(MASTER_SITE_SUBDIR)
PKG_FAIL_REASON+='MASTER_SITE_SUBDIR is deprecated and must be replaced with MASTER_SITES.'
.endif

.if defined(PATCH_SITE_SUBDIR)
PKG_FAIL_REASON+='PATCH_SITE_SUBDIR is deprecated and must be replaced with PATCH_SITES.'
.endif

.if defined(ONLY_FOR_ARCHS) || defined(NOT_FOR_ARCHS) \
	|| defined(ONLY_FOR_OPSYS) || defined(NOT_FOR_OPSYS)
PKG_FAIL_REASON+='ONLY/NOT_FOR_ARCHS/OPSYS are deprecated and must be replaced with ONLY/NOT_FOR_PLATFORM.'
.endif

.if (${PKGSRC_LOCKTYPE} == "sleep" || ${PKGSRC_LOCKTYPE} == "once")
. if !defined(OBJHOSTNAME)
PKG_FAIL_REASON+='PKGSRC_LOCKTYPE needs OBJHOSTNAME defined.'
. elif !exists(${SHLOCK})
PKG_FAIL_REASON+='The ${SHLOCK} utility does not exist, and is necessary for locking.'
PKG_FAIL_REASON+='Please "${MAKE} install" in ../../pkgtools/shlock.'
. endif
.endif

PKGREPOSITORYSUBDIR?=	All
PKGREPOSITORY?=		${PACKAGES}/${PKGREPOSITORYSUBDIR}
PKGFILE?=		${PKGREPOSITORY}/${PKGNAME}${PKG_SUFX}

CONFIGURE_DIRS?=	${WRKSRC}
CONFIGURE_SCRIPT?=	./configure
CONFIGURE_ENV+=		PATH=${PATH}:${LOCALBASE}/bin:${X11BASE}/bin

.if defined(GNU_CONFIGURE)
#
# CONFIGURE_PREFIX is the argument to the --prefix option passed to the
# GNU configure script.
#
GNU_CONFIGURE_PREFIX?=	${PREFIX}
CONFIGURE_ARGS+=	--host=${MACHINE_GNU_PLATFORM}
CONFIGURE_ARGS+=	--prefix=${GNU_CONFIGURE_PREFIX}
HAS_CONFIGURE=		yes
.  if ${X11PREFIX} == ${LOCALBASE}
CONFIGURE_ARGS+=	--x-includes=${X11BASE}/include
CONFIGURE_ARGS+=        --x-libraries=${X11BASE}/lib
.  endif
.endif

#
# Config file related settings - see Packages.txt
#
PKG_SYSCONFVAR?=	${PKGBASE}
PKG_SYSCONFBASE?=	${PREFIX}/etc
.if defined(PKG_SYSCONFDIR.${PKG_SYSCONFVAR})
PKG_SYSCONFDIR=		${PKG_SYSCONFDIR.${PKG_SYSCONFVAR}}
.else
PKG_SYSCONFSUBDIR?=	# empty
.  if empty(PKG_SYSCONFSUBDIR)
PKG_SYSCONFDIR=		${PKG_SYSCONFBASE}
.  else
PKG_SYSCONFDIR=		${PKG_SYSCONFBASE}/${PKG_SYSCONFSUBDIR}
.  endif
.endif

CONFIGURE_ENV+=		PKG_SYSCONFDIR="${PKG_SYSCONFDIR}"
MAKE_ENV+=		PKG_SYSCONFDIR="${PKG_SYSCONFDIR}"
BUILD_DEFS+=		PKG_SYSCONFDIR

# Passed to most of script invocations
SCRIPTS_ENV+= CURDIR=${.CURDIR} DISTDIR=${DISTDIR} \
	PATH=${PATH}:${LOCALBASE}/bin:${X11BASE}/bin \
	WRKDIR=${WRKDIR} WRKSRC=${WRKSRC} PATCHDIR=${PATCHDIR} \
	SCRIPTDIR=${SCRIPTDIR} FILESDIR=${FILESDIR} \
	_PKGSRCDIR=${_PKGSRCDIR} DEPENDS="${DEPENDS}" \
	PREFIX=${PREFIX} LOCALBASE=${LOCALBASE} X11BASE=${X11BASE}

.if defined(BATCH)
SCRIPTS_ENV+=	BATCH=yes
.endif

.if !empty(USE_BUILDLINK2:M[nN][oO])
NO_BUILDLINK=		# defined
.endif

.if !defined(NO_BUILDLINK)
.  include "../../mk/buildlink2/bsd.buildlink2.mk"
.endif

.MAIN: all

# Use aliases, so that all versions of English are acceptable
.if defined(LICENCE) && !defined(LICENSE)
LICENSE=	${LICENCE}
.endif

.if defined(ACCEPTABLE_LICENCES) && !defined(ACCEPTABLE_LICENSES)
ACCEPTABLE_LICENSES=	${ACCEPTABLE_LICENCES}
.endif

################################################################
# Many ways to disable a package.
#
# Ignore packages that can't be resold if building for a CDROM.
#
# Don't build a package if it's restricted and we don't want to
# get into that.
#
# Don't build any package that utilizes strong cryptography, for
# when the law of the land forbids it.
#
# Don't attempt to build packages against X if we don't have X.
#
# Don't build a package if it's broken.
################################################################

.if !defined(NO_SKIP)
.  if (defined(NO_BIN_ON_CDROM) && defined(FOR_CDROM))
PKG_FAIL_REASON+= "${PKGNAME} may not be placed in binary form on a CDROM:" \
         "    "${NO_BIN_ON_CDROM:Q}
.  endif
.  if (defined(NO_SRC_ON_CDROM) && defined(FOR_CDROM))
PKG_FAIL_REASON+= "${PKGNAME} may not be placed in source form on a CDROM:" \
         "    "${NO_SRC_ON_CDROM:Q}
.  endif
.  if (defined(RESTRICTED) && defined(NO_RESTRICTED))
PKG_FAIL_REASON+= "${PKGNAME} is restricted:" \
	 "    "${RESTRICTED:Q}
.  endif
.  if !(${MKCRYPTO} == "YES" || ${MKCRYPTO} == yes)
.    if defined(CRYPTO)
PKG_FAIL_REASON+= "${PKGNAME} may not be built, because it utilizes strong cryptography"
.    endif
.  endif
.  if defined(USE_X11) && !exists(${X11BASE})
PKG_FAIL_REASON+= "${PKGNAME} uses X11, but ${X11BASE} not found"
.  endif
.  if defined(BROKEN)
PKG_FAIL_REASON+= "${PKGNAME} is marked as broken:" ${BROKEN:Q}
.  endif

.  if defined(LICENSE)
.    ifdef ACCEPTABLE_LICENSES
.      for _lic in ${ACCEPTABLE_LICENSES}
.        if ${LICENSE} == "${_lic}"
_ACCEPTABLE=	yes
.        endif	# LICENSE == _lic
.      endfor	# _lic
.    endif	# ACCEPTABLE_LICENSES
.    ifndef _ACCEPTABLE
PKG_FAIL_REASON+= "${PKGNAME} has an unacceptable license: ${LICENSE}." \
	 "    To build this package, add this line to your /etc/mk.conf:" \
	 "    ACCEPTABLE_LICENSES+=${LICENSE}" \
	 "    To view the license, enter \"make show-license\"."
.    endif	# _ACCEPTABLE
.  endif	# LICENSE

# Define __PLATFORM_OK only if the OS matches the pkg's allowed list.
.  if defined(ONLY_FOR_PLATFORM) && !empty(ONLY_FOR_PLATFORM)
.    for __tmp__ in ${ONLY_FOR_PLATFORM}
.      if ${MACHINE_PLATFORM:M${__tmp__}} != ""
__PLATFORM_OK?=	yes
.      endif	# MACHINE_PLATFORM
.    endfor	# __tmp__
.  else	# !ONLY_FOR_PLATFORM
__PLATFORM_OK?=	yes
.  endif	# ONLY_FOR_PLATFORM
.  for __tmp__ in ${NOT_FOR_PLATFORM}
.    if ${MACHINE_PLATFORM:M${__tmp__}} != ""
.      undef __PLATFORM_OK
.    endif	# MACHINE_PLATFORM
.  endfor	# __tmp__
.  if !defined(__PLATFORM_OK)
PKG_SKIP_REASON+= "${PKGNAME} is not available for ${MACHINE_PLATFORM}"
.  endif	# !__PLATFORM_OK

#
# Now print some error messages that we know we should ignore the pkg
#
.  if defined(PKG_FAIL_REASON) || defined(PKG_SKIP_REASON)
fetch checksum extract patch configure all build install package \
update install-depends:
.    if defined(SKIP_SILENT)
	@${DO_NADA}
.    else
	@for str in ${PKG_FAIL_REASON} ${PKG_SKIP_REASON} ; \
	do \
		${ECHO} "${_PKGSRC_IN}> $$str" ; \
	done
.    endif
.    if defined(PKG_FAIL_REASON)
	@${FALSE}
.    endif
.  endif # SKIP
.endif # !NO_SKIP

# Add these defs to the ones dumped into +BUILD_DEFS
BUILD_DEFS+=	PKGPATH
BUILD_DEFS+=	OPSYS OS_VERSION MACHINE_ARCH MACHINE_GNU_ARCH
BUILD_DEFS+=	CPPFLAGS CFLAGS FFLAGS LDFLAGS
BUILD_DEFS+=	CONFIGURE_ENV CONFIGURE_ARGS
BUILD_DEFS+=	OBJECT_FMT LICENSE RESTRICTED
BUILD_DEFS+=	NO_SRC_ON_FTP NO_SRC_ON_CDROM
BUILD_DEFS+=	NO_BIN_ON_FTP NO_BIN_ON_CDROM

.if defined(OSVERSION_SPECIFIC)
BUILD_DEFS+=	OSVERSION_SPECIFIC
.endif # OSVERSION_SPECIFIC

.PHONY: all
.if !target(all)
.  if ${PKGSRC_RUN_TEST} == "YES" || ${PKGSRC_RUN_TEST} == "yes"
all: test
.  else
all: build
.  endif
.endif

.if !defined(DEPENDS_TARGET)
.  if make(package)
DEPENDS_TARGET=	package
.  elif make(update)
.    if defined(UPDATE_TARGET) && ${UPDATE_TARGET} == "replace"
DEPENDS_TARGET=	${UPDATE_TARGET}
.    else
DEPENDS_TARGET=	update
.    endif
.  elif make(bin-install)
DEPENDS_TARGET=	bin-install
.  else
DEPENDS_TARGET=	reinstall
.  endif
.endif

.if !defined(UPDATE_TARGET)
.  if ${DEPENDS_TARGET} == "update"
.    if make(package)
UPDATE_TARGET=	package
.    else
UPDATE_TARGET=	install
.    endif
.  else
UPDATE_TARGET=	${DEPENDS_TARGET}
.  endif
.endif

################################################################
# The following are used to create easy dummy targets for
# disabling some bit of default target behavior you don't want.
# They still check to see if the target exists, and if so don't
# do anything, since you might want to set this globally for a
# group of packages in a Makefile.inc, but still be able to
# override from an individual Makefile.
################################################################

# Disable checksum
.PHONY: checksum
.if (defined(NO_CHECKSUM) && !target(checksum)) || exists(${EXTRACT_COOKIE})
checksum: fetch
	@${DO_NADA}
.endif

# Disable buildlink
.PHONY: buildlink
.if defined(NO_BUILDLINK) && !target(configure)
buildlink: patch
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${BUILDLINK_COOKIE}
.endif

# Disable configure
.PHONY: configure
.if defined(NO_CONFIGURE) && !target(configure)
configure: buildlink
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${CONFIGURE_COOKIE}
.endif

# Disable build
.PHONY: build
.if defined(NO_BUILD) && !target(build)
build: configure
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${BUILD_COOKIE}
.endif

# Disable install
.PHONY: install
.if defined(NO_INSTALL) && !target(install)
install: build
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${INSTALL_COOKIE}
.endif

# Disable package
.PHONY: package
.if defined(NO_PACKAGE) && !target(package)
package:
.  if defined(SKIP_SILENT)
	@${DO_NADA}
.  else
	@${ECHO_MSG} "${_PKGSRC_IN}> ${PKGNAME} may not be packaged: ${NO_PACKAGE}."
.  endif
.endif

################################################################
# More standard targets start here.
#
# These are the body of the build/install framework.  If you are
# not happy with the default actions, and you can't solve it by
# adding pre-* or post-* targets/scripts, override these.
################################################################

#
# Define the elementary fetch macros.
#
_FETCH_FILE=								\
	if [ ! -f $$file -a ! -f $$bfile -a ! -h $$bfile ]; then	\
		${ECHO_MSG} "=> $$bfile doesn't seem to exist on this system."; \
		if [ ! -w ${_DISTDIR}/. ]; then 			\
			${ECHO_MSG} "=> Can't download to ${_DISTDIR} (permission denied?)."; \
			exit 1; 					\
		fi; 							\
		for site in $$sites; do					\
			${ECHO_MSG} "=> Attempting to fetch $$bfile from $${site}."; \
			if [ -f ${DISTINFO_FILE} ]; then		\
				${AWK} 'NF == 5 && $$1 == "Size" && $$2 == "('$$bfile')" { printf("=> [%s %s]\n", $$4, $$5) }' ${DISTINFO_FILE}; \
			fi;						\
			if ${FETCH_CMD} ${FETCH_BEFORE_ARGS} $${site}$${bfile} ${FETCH_AFTER_ARGS}; then \
				if [ -n "${FAILOVER_FETCH}" -a -f ${DISTINFO_FILE} -a -f ${_DISTDIR}/$$bfile ]; then \
					alg=`${AWK} 'NF == 4 && $$2 == "('$$file')" && $$3 == "=" {print $$1;}' ${DISTINFO_FILE}`; \
					if [ -z "$$alg" ]; then		\
						alg=${DIGEST_ALGORITHM};\
					fi;				\
					CKSUM=`${DIGEST} $$alg < ${_DISTDIR}/$$bfile`; \
					CKSUM2=`${AWK} '$$1 == "'$$alg'" && $$2 == "('$$file')" {print $$4;}' <${DISTINFO_FILE}`; \
					if [ "$$CKSUM" = "$$CKSUM2" -o "$$CKSUM2" = "IGNORE" ]; then \
						break;			\
					else				\
						${ECHO_MSG} "=> Checksum failure - trying next site."; \
					fi;				\
				elif [ ! -f ${_DISTDIR}/$$bfile ]; then \
					${ECHO_MSG} "=> FTP didn't fetch expected file, trying next site." ; \
				else					\
					break;				\
				fi;					\
			fi						\
		done;							\
		if [ ! -f ${_DISTDIR}/$$bfile ]; then \
			${ECHO_MSG} "=> Couldn't fetch $$bfile - please try to retrieve this";\
			${ECHO_MSG} "=> file manually into ${_DISTDIR} and try again."; \
			exit 1;						\
		fi;							\
	fi

_CHECK_DIST_PATH=							\
	if [ "X${DIST_PATH}" != "X" ]; then				\
		for d in "" ${DIST_PATH:S/:/ /g}; do	\
			if [ "X$$d" = "X" -o "X$$d" = "X${DISTDIR}" ]; then continue; fi; \
			if [ -f $$d/${DIST_SUBDIR}/$$bfile ]; then	\
				${ECHO} "Using $$d/${DIST_SUBDIR}/$$bfile"; \
				${RM} -f $$bfile;			\
				${LN} -s $$d/${DIST_SUBDIR}/$$bfile $$bfile; \
				break;					\
			fi;						\
		done;							\
	fi

#
# Set up ORDERED_SITES to work out the exact list of sites for every file,
# using the dynamic sites script, or sorting according to the master site
# list or the patterns in MASTER_SORT or MASTER_SORT_REGEX as appropriate.
# No actual sorting is done until ORDERED_SITES is expanded.
#
.if defined(MASTER_SORT) || defined(MASTER_SORT_REGEX)
MASTER_SORT?=
MASTER_SORT_REGEX?=
MASTER_SORT_REGEX+= ${MASTER_SORT:S/./\\./g:C/.*/:\/\/[^\/]*&\//}

MASTER_SORT_AWK= BEGIN { RS = " "; ORS = " "; IGNORECASE = 1 ; gl = "${MASTER_SORT_REGEX}"; }
.  for srt in ${MASTER_SORT_REGEX}
MASTER_SORT_AWK+= /${srt:C/\//\\\//g}/ { good["${srt}"] = good["${srt}"] " " $$0 ; next; }
.  endfor
MASTER_SORT_AWK+= { rest = rest " " $$0; } END { n=split(gl, gla); for(i=1;i<=n;i++) { print good[gla[i]]; } print rest; }

SORT_SITES_CMD= ${ECHO} $$unsorted_sites | ${AWK} '${MASTER_SORT_AWK}'
ORDERED_SITES= ${_MASTER_SITE_OVERRIDE} `${SORT_SITES_CMD:C/"/\"/g}`
.else
ORDERED_SITES= ${_MASTER_SITE_OVERRIDE} $$unsorted_sites
.endif

#
# Associate each file to fetch with the correct site(s).
#
.if defined(DYNAMIC_MASTER_SITES)
.  for fetchfile in ${_ALLFILES}
SITES_${fetchfile:T:S/=/--/}?= `${SH} ${FILESDIR}/getsite.sh ${fetchfile:T}`
.  endfor
.endif
.if !empty(_DISTFILES)
.  for fetchfile in ${_DISTFILES}
SITES_${fetchfile:T:S/=/--/}?= ${MASTER_SITES}
.  endfor
.endif
.if !empty(_PATCHFILES)
.  for fetchfile in ${_PATCHFILES}
SITES_${fetchfile:T:S/=/--/}?= ${PATCH_SITES}
.  endfor
.endif

# This code is only called in a batch case, to check for the presence of
# the distfiles
.PHONY: batch-check-distfiles
batch-check-distfiles:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	gotfiles=yes;							\
	for file in "" ${_ALLFILES}; do					\
		case "$$file" in					\
		"")	continue ;;					\
		*)	if [ ! -f ${DISTDIR}/$$file ]; then		\
				gotfiles=no;				\
			fi ;;						\
		esac;							\
	done;								\
	case "$$gotfiles" in						\
	no)	${ECHO} "*** This package requires user intervention to download the distfiles"; \
		${ECHO} "*** Please fetch the distfiles manually and place them in"; \
		${ECHO} "*** ${DISTDIR}";				\
		[ ! -z "${MASTER_SITES}" ] &&				\
			${ECHO} "*** The distfiles are available from ${MASTER_SITES}";	\
		[ ! -z "${HOMEPAGE}" ] && 				\
			${ECHO} "*** See ${HOMEPAGE} for more details";	\
		${ECHO};						\
		${TOUCH} ${INTERACTIVE_COOKIE};				\
		${FALSE} ;;						\
	esac

# check for any vulnerabilities in the package
# Please do not modify the leading "@" here
.PHONY: check-vulnerable
check-vulnerable:
	@if [ -f ${PKGVULNDIR}/vulnerabilities ]; then			\
		${SETENV} PKGNAME="${PKGNAME}"				\
			  PKGBASE="${PKGBASE}"				\
			${AWK} '/^$$/ { next }				\
				/^#.*/ { next }				\
				$$1 !~ ENVIRON["PKGBASE"] { next }	\
				{ s = sprintf("${PKG_ADMIN} pmatch \"%s\" %s && ${ECHO} \"*** WARNING - %s vulnerability in %s - see %s for more information ***\"", $$1, ENVIRON["PKGNAME"], $$2, ENVIRON["PKGNAME"], $$3); system(s); }' < ${PKGVULNDIR}/vulnerabilities || ${FALSE}; \
	fi

.PHONY: do-fetch
.if !target(do-fetch)
do-fetch:
.  if !defined(ALLOW_VULNERABLE_PACKAGES)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -f ${PKGVULNDIR}/vulnerabilities ]; then			\
		${ECHO_MSG} "${_PKGSRC_IN}> Checking for vulnerabilities in ${PKGNAME}"; \
		vul=`${MAKE} ${MAKEFLAGS} check-vulnerable`;		\
		case "$$vul" in						\
		"")	;;						\
		*)	${ECHO} "$$vul";				\
			${ECHO} "or define ALLOW_VULNERABLE_PACKAGES if this package is absolutely essential"; \
			${FALSE} ;;					\
		esac;							\
	else								\
		${ECHO_MSG} "${_PKGSRC_IN}> *** No ${PKGVULNDIR}/vulnerabilities file found,"; \
		${ECHO_MSG} "${_PKGSRC_IN}> *** skipping vulnerability checks. To fix, install"; \
		${ECHO_MSG} "${_PKGSRC_IN}> *** the pkgsrc/security/audit-packages package and run"; \
		${ECHO_MSG} "${_PKGSRC_IN}> *** '${LOCALBASE}/sbin/download-vulnerability-list'."; \
	fi
.  endif
.  if !empty(_ALLFILES)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${TEST} -d ${_DISTDIR} || ${MKDIR} ${_DISTDIR}
.    if ${INTERACTIVE_STAGE:Mfetch} == "fetch" && defined(BATCH)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${MAKE} ${MAKEFLAGS} batch-check-distfiles
.    else
.      for fetchfile in ${_ALLFILES}
.        if defined(_FETCH_MESSAGE)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	file="${fetchfile}";						\
	if [ ! -f ${DISTDIR}/$$file ]; then				\
		${_FETCH_MESSAGE};					\
	fi
.        else
	${_PKG_SILENT}${_PKG_DEBUG}					\
	cd ${_DISTDIR};							\
	file="${fetchfile}";						\
	bfile="${fetchfile:T}";						\
	unsorted_sites="${SITES_${fetchfile:T:S/=/--/}} ${_MASTER_SITE_BACKUP}"; \
	sites="${ORDERED_SITES}";					\
	${_CHECK_DIST_PATH};						\
	${_FETCH_FILE};
.        endif # defined(_FETCH_MESSAGE)
.      endfor
.    endif # INTERACTIVE_STAGE == fetch
.  endif # !empty(_ALLFILES)
.endif

# show both build and run depends directories (non-recursively)
.PHONY: show-depends-dirs
.if !target(show-depends-dirs)
show-depends-dirs:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	dlist="";							\
	thisdir=`${PWD_CMD}`;						\
	for reldir in "" ${DEPENDS:C/^[^:]*://:C/:.*$//} ${BUILD_DEPENDS:C/^[^:]*://:C/:.*$//} ;\
	do								\
		if [ "X$$reldir" = "X" ]; then continue; fi;		\
		cd $$thisdir/$$reldir;					\
		WD=`${PWD_CMD}`;					\
		d=`dirname $$WD`;					\
		absdir=`basename $$d`/`basename $$WD`;			\
		dlist="$$dlist $$absdir";				\
	done;								\
	cd $$thisdir;							\
	${ECHO} "$$dlist"
.endif

# Show all build and run depends, reverse-breadth first, with options.
.if make(show-all-depends-dirs) || make(show-all-depends-dirs-excl) || make (show-root-dirs)
.PHONY: show-all-depends-dirs show-all-depends-dirs-excl show-root-dirs

# "awk" macro to recurse over the dependencies efficiently, never running in
# the same same directory twice. You may set the following options via "-v":
#
#	NonSelf = 1	to not print own directory;
#	RootsOnly = 1	to print only root directories (i.e. directories
#			of packages with no dependencies), including possibly
#			own directory
#
_RECURSE_DEPENDS_DIRS=							\
	function append_dirs(dir) {					\
		command = "cd ../../" dir " && ${MAKE} show-depends-dirs"; \
		command | getline tmp_dirs;				\
		close(command);						\
		if (tmp_dirs ~ /^$$/)					\
			root_dirs[p++] = dir;				\
		for (i = 1; i <= split(tmp_dirs, tmp_r); i++)		\
			if (!(tmp_r[i] in hash_all_dirs)) {		\
				all_dirs[n++] = tmp_r[i];		\
				hash_all_dirs[tmp_r[i]] = 1		\
			}						\
	}								\
	BEGIN {								\
		command = "${PWD_CMD}";					\
		command | getline start_dir;				\
		close(command);						\
		i = split(start_dir, tmp_r, /\//);			\
		all_dirs[n++] = tmp_r[i-1] "/" tmp_r[i];		\
		for (; m < n; )						\
			append_dirs(all_dirs[m++]);			\
		if (RootsOnly) {					\
			printf("%s", root_dirs[--p]);			\
			for (; p > 0; )					\
				printf(" %s", root_dirs[--p])		\
		}							\
		else {							\
			if (m > NonSelf)				\
				printf("%s", all_dirs[--m]);		\
			for (; m > NonSelf; )				\
				printf(" %s", all_dirs[--m])		\
		}							\
		print							\
	}

.PHONY: show-all-depends-dirs
.if make(show-all-depends-dirs)
show-all-depends-dirs:
	${_PKG_SILENT}${_PKG_DEBUG}${AWK} '${_RECURSE_DEPENDS_DIRS}'
.endif

.PHONY: show-all-depends-dirs-excl
.if make(show-all-depends-dirs-excl)
show-all-depends-dirs-excl:
	${_PKG_SILENT}${_PKG_DEBUG}${AWK} -v NonSelf=1 '${_RECURSE_DEPENDS_DIRS}'
.endif

.PHONY: show-root-dirs
.if make(show-root-dirs)
show-root-dirs:
	${_PKG_SILENT}${_PKG_DEBUG}${AWK} -v RootsOnly=1 '${_RECURSE_DEPENDS_DIRS}'
.endif

.endif # make(show-{all-depends-dirs{,-excl},root-dirs})

.PHONY: show-distfiles
.if !target(show-distfiles)
show-distfiles:
.  if defined(PKG_FAIL_REASON)
	${_PKG_SILENT}${_PKG_DEBUG}${DO_NADA}
.  else
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for file in "" ${_CKSUMFILES}; do				\
		if [ "X$$file" = "X" ]; then continue; fi;		\
		${ECHO} $$file;						\
	done
.  endif
.endif

.PHONY: show-downlevel
.if !target(show-downlevel)
show-downlevel:
.  if defined(PKG_FAIL_REASON)
	${_PKG_SILENT}${_PKG_DEBUG}${DO_NADA}
.  else
	${_PKG_SILENT}${_PKG_DEBUG}					\
	found="`${PKG_INFO} -e \"${PKGBASE}\" || ${TRUE}`";		\
	if [ "X$$found" != "X" -a "X$$found" != "X${PKGNAME}" ]; then	\
		${ECHO} "${PKGBASE} package: $$found installed, pkgsrc version ${PKGNAME}"; \
		if [ "X$$STOP_DOWNLEVEL_AFTER_FIRST" != "X" ]; then	\
			${ECHO} "stopping after first downlevel pkg found"; \
			exit 1;						\
		fi;							\
	fi
.  endif
.endif

.PHONY: show-installed-depends
.if !target(show-installed-depends)
show-installed-depends:
.  if defined(DEPENDS)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for i in ${DEPENDS:C/:.*$//:Q:S/\ / /g} ; do			\
		echo "$$i =>" `${PKG_INFO} -e "$$i"` ;			\
	done
.  endif
.endif

.PHONY: show-needs-update
.if !target(show-needs-update)
show-needs-update:
.  if defined(DEPENDS)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for i in `${MAKE} show-all-depends-dirs`; do			\
		cd ${_PKGSRCDIR}/$$i;					\
		want=`make show-vars VARNAMES=PKGNAME`;			\
		have=`${PKG_INFO} -e "$${want%-*}" || true`;		\
		if [ -z "$$have" ]; then				\
			echo "$$i => (none) => needs install of $$want"; \
		elif [ "$$have" != "$$want" ]; then			\
			echo "$$i => $$have => needs update to $$want";	\
		fi;							\
	done
.  endif
.endif

.PHONY: show-pkgsrc-dir
.if !target(show-pkgsrc-dir)
show-pkgsrc-dir:
.  if defined(PKG_FAIL_REASON)
	${_PKG_SILENT}${_PKG_DEBUG}${DO_NADA}
.  else
	${_PKG_SILENT}${_PKG_DEBUG}					\
	found="`${PKG_INFO} -e \"${PKGWILDCARD}\" || ${TRUE}`";		\
	if [ "X$$found" != "X" ]; then					\
		${ECHO} ${PKGPATH};					\
	fi
.  endif
.endif

# Extract

# pkgsrc coarse-grained locking definitions and targets
.if ${PKGSRC_LOCKTYPE} == "none"
_ACQUIRE_LOCK=	${_PKG_SILENT}${_PKG_DEBUG}${DO_NADA}
_RELEASE_LOCK=	${_PKG_SILENT}${_PKG_DEBUG}${DO_NADA}
.else
LOCKFILE=	${WRKDIR}/.lockfile

_ACQUIRE_LOCK=								\
	${_PKG_SILENT}${_PKG_DEBUG}					\
	ppid=`${PS} -p $$$$ -o ppid | ${AWK} 'NR == 2 { print $$1 }'`;	\
	while true; do							\
		${SHLOCK} -f ${LOCKFILE} -p $$ppid && break;		\
		${ECHO} "=> Lock is held by pid `cat ${LOCKFILE}`";	\
		case "${PKGSRC_LOCKTYPE}" in				\
		once)	exit 1 ;;					\
		sleep)	sleep ${PKGSRC_SLEEPSECS} ;;			\
		esac							\
	done;								\
	if [ "${PKG_VERBOSE}" != "" ]; then				\
		${ECHO_MSG} "=> Lock acquired on behalf of process $$ppid"; \
	fi

_RELEASE_LOCK=								\
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ "${PKG_VERBOSE}" != "" ]; then				\
		${ECHO_MSG} "=> Lock released on behalf of process `${CAT} ${LOCKFILE}`"; \
	fi;								\
	${RM} ${LOCKFILE}
.endif # PKGSRC_LOCKTYPE

${WRKDIR}:
.if !defined(KEEP_WRKDIR)
.  if ${PKGSRC_LOCKTYPE} == "sleep" || ${PKGSRC_LOCKTYPE} == "once"
.    if !exists(${LOCKFILE})
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -rf ${WRKDIR}
.    endif
.  endif
.endif
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${WRKDIR}
.ifdef WRKOBJDIR
.  if ${PKGSRC_LOCKTYPE} == "sleep" || ${PKGSRC_LOCKTYPE} == "once"
.    if !exists(${LOCKFILE})
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${RM} -f ${WRKDIR_BASENAME} || ${TRUE}
.    endif
.  endif
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if ${LN} -s ${WRKDIR} ${WRKDIR_BASENAME} 2>/dev/null; then	\
		${ECHO} "${WRKDIR_BASENAME} -> ${WRKDIR}";		\
	fi
.endif # WRKOBJDIR

_EXTRACT_SUFFICES=	.tar.gz .tgz .tar.bz2 .tbz .tar.Z .tar _tar.gz
_EXTRACT_SUFFICES+=	.shar.gz .shar.bz2 .shar.Z .shar
_EXTRACT_SUFFICES+=	.zip
_EXTRACT_SUFFICES+=	.lha .lzh
_EXTRACT_SUFFICES+=	.Z .bz2 .gz
_EXTRACT_SUFFICES+=	.zoo

# If the distfile has a tar.bz2 suffix, use bzcat in preference to gzcat,
# pulling in the "bzip2" package if necessary.  [Note: this is only for
# the benefit of pre-1.5 NetBSD systems. "gzcat" on newer systems happily
# decodes bzip2.]  Do likewise for ".zip" and ".lha" distfiles.
#
.if !empty(EXTRACT_ONLY:M*.bz2) || !empty(EXTRACT_ONLY:M*.tbz) || \
    !empty(EXTRACT_SUFX:M*.bz2) || !empty(EXTRACT_SUFX:M*.tbz)
.  if exists(/usr/bin/bzcat)
BZCAT=			/usr/bin/bzcat <
.  else
BUILD_DEPENDS+=		bzip2>=0.9.0b:../../archivers/bzip2
BZCAT=			${LOCALBASE}/bin/bzcat
.  endif
.endif
.if !empty(EXTRACT_ONLY:M*.zip) || !empty(EXTRACT_SUFX:M*.zip)
BUILD_DEPENDS+=		unzip-[0-9]*:../../archivers/unzip
.endif
.if !empty(EXTRACT_ONLY:M*.lzh) || !empty(EXTRACT_ONLY:M*.lha) || \
    !empty(EXTRACT_SUFX:M*.lzh) || !empty(EXTRACT_SUFX:M*.lha)
BUILD_DEPENDS+=		lha>=114.9:../../archivers/lha
.endif
.if !defined(GZCAT)
.  if !empty(EXTRACT_ONLY:M*.gz) || !empty(EXTRACT_ONLY:M*.tgz) || \
      !empty(EXTRACT_SUFX:M*.gz) || !empty(EXTRACT_SUFX:M*.tgz)
BUILD_DEPENDS+=         gzip-base:../../archivers/gzip-base
GZCAT=                  ${LOCALBASE}/bin/zcat
.  endif
.endif
.if !empty(EXTRACT_ONLY:M*.zoo) || !empty(EXTRACT_SUFX:M*.zoo)
BUILD_DEPENDS+=		unzoo-[0-9]*:../../archivers/unzoo
.endif

DECOMPRESS_CMD.tar.gz?=		${GZCAT}
DECOMPRESS_CMD.tgz?=		${DECOMPRESS_CMD.tar.gz}
DECOMPRESS_CMD.tar.bz2?=	${BZCAT}
DECOMPRESS_CMD.tbz?=		${DECOMPRESS_CMD.tar.bz2}
DECOMPRESS_CMD.tar.Z?=		${GZCAT}
DECOMPRESS_CMD.tar?=		${CAT}

DECOMPRESS_CMD.shar.gz?=	${GZCAT}
DECOMPRESS_CMD.shar.bz2?=	${BZCAT}
DECOMPRESS_CMD.shar.Z?=		${GZCAT}
DECOMPRESS_CMD.shar?=		${CAT}

DECOMPRESS_CMD.Z?=		${GZCAT}
DECOMPRESS_CMD.bz2?=		${BZCAT}
DECOMPRESS_CMD.gz?=		${GZCAT}

DECOMPRESS_CMD?=		${GZCAT}
.for __suffix__ in ${_EXTRACT_SUFFICES}
.  if !defined(DECOMPRESS_CMD${__suffix__})
DECOMPRESS_CMD${__suffix__}?=	${DECOMPRESS_CMD}
.  endif
.endfor

# If this is empty, then everything gets extracted.
EXTRACT_ELEMENTS?=	# empty

DOWNLOADED_DISTFILE=	$${extract_file}

EXTRACT_CMD.zip?=	${LOCALBASE}/bin/unzip -Laqo $${extract_file}
EXTRACT_CMD.lha?=	${LOCALBASE}/bin/lha xq $${extract_file}
EXTRACT_CMD.lzh?=	${EXTRACT_CMD.lha}
EXTRACT_CMD.zoo?=	${LOCALBASE}/bin/unzoo -x $${extract_file}

.for __suffix__ in .gz .bz2 .Z
EXTRACT_CMD${__suffix__}?=	${DECOMPRESS_CMD${__suffix__}} $${extract_file} > `${BASENAME} $${extract_file} ${__suffix__}`
.endfor

.for __suffix__ in .shar.gz .shar.bz2 .shar.Z .shar
EXTRACT_CMD${__suffix__}?=	${DECOMPRESS_CMD${__suffix__}} $${extract_file} | ${SH}
.endfor

# If EXTRACT_USING_PAX is defined, use pax in preference to (GNU) tar,
# and append 2 tar blocks of zero bytes on the end, in case the archive
# was written with a buggy version of GNU tar.
#
.if defined(EXTRACT_USING_PAX)
_DFLT_EXTRACT_CMD?=	{ ${DECOMPRESS_CMD} $${extract_file} ; dd if=/dev/zero bs=10k count=2; } | ${PAX} -O -r ${EXTRACT_ELEMENTS}
.else
_DFLT_EXTRACT_CMD?=	${DECOMPRESS_CMD} $${extract_file} | ${GTAR} -xf - ${EXTRACT_ELEMENTS}
.endif

.for __suffix__ in ${_EXTRACT_SUFFICES}
.  if !defined(EXTRACT_CMD${__suffix__})
.    if defined(EXTRACT_USING_PAX)
EXTRACT_CMD${__suffix__}?=	{ ${DECOMPRESS_CMD${__suffix__}} $${extract_file} ; dd if=/dev/zero bs=10k count=2; } | ${PAX} -O -r ${EXTRACT_ELEMENTS}
.  else
EXTRACT_CMD${__suffix__}?=	${DECOMPRESS_CMD${__suffix__}} $${extract_file} | ${GTAR} -xf - ${EXTRACT_ELEMENTS}
.    endif
.  endif
.endfor

# _SHELL_EXTRACT is a "subroutine" for extracting an archive.  It extracts
# the contents of archive named by the shell variable "extract_file" based
# on the file extension of the archive.
#
_SHELL_EXTRACT=		case $${extract_file} in
.for __suffix__ in ${_EXTRACT_SUFFICES}
_SHELL_EXTRACT+=	*${__suffix__})	${EXTRACT_CMD${__suffix__}} ;;
.endfor
_SHELL_EXTRACT+=	*)		${_DFLT_EXTRACT_CMD} ;;
_SHELL_EXTRACT+=	esac

EXTRACT_CMD?=		${_SHELL_EXTRACT}

.PHONY: do-extract
.if !target(do-extract)
do-extract: ${WRKDIR}
.  for __file__ in ${EXTRACT_ONLY}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	extract_file="${_DISTDIR}/${__file__}";	export extract_file;	\
	cd ${WRKDIR}; ${EXTRACT_CMD}
.  endfor
.endif

# Patch

# LOCALPATCHES contains the location of local patches to packages
#	that are maintained in a directory tree reflecting the same
#	hierarchy as the pkgsrc tree, i.e. local patches for www/apache
#	would be found as ${LOCALPATCHES}/www/apache/*.
#
.if defined(LOCALPATCHES)
_DFLT_LOCALPATCHFILES=	${LOCALPATCHES}/${PKGPATH}/*
_LOCALPATCHFILES=	${_DFLT_LOCALPATCHFILES}
.endif

.PHONY: do-patch
.if !target(do-patch)
do-patch: uptodate-digest
.  if defined(PATCHFILES)
	@${ECHO_MSG} "${_PKGSRC_IN}> Applying distribution patches for ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}cd ${_DISTDIR};			\
	  for i in ${PATCHFILES}; do					\
		if [ ${PATCH_DEBUG_TMP} = yes ]; then			\
			${ECHO_MSG} "${_PKGSRC_IN}> Applying distribution patch $$i" ; \
		fi;							\
		case $$i in						\
			*.Z|*.gz)					\
				${GZCAT} $$i | ${PATCH} ${PATCH_DIST_ARGS} \
				|| { ${ECHO} Patch $$i failed ; exit 1; } ; \
				;;					\
			*.bz2)						\
				${BZCAT} $$i | ${PATCH} ${PATCH_DIST_ARGS} \
				|| { ${ECHO} Patch $$i failed ; exit 1; } ; \
				;;					\
			*)						\
				${PATCH} ${PATCH_DIST_ARGS} < $$i	\
				|| { ${ECHO} Patch $$i failed ; exit 1; } ; \
				;;					\
		esac;							\
	  done
.  endif
	${_PKG_SILENT}${_PKG_DEBUG}					\
	patchlist="";							\
	if [ -d ${PATCHDIR} ]; then					\
		if [ "`${ECHO} ${PATCHDIR}/patch-*`" = "${PATCHDIR}/patch-*" ]; then \
			${ECHO_MSG} "${_PKGSRC_IN}> Ignoring empty patch directory"; \
			if [ -d ${PATCHDIR}/CVS ]; then			\
				${ECHO_MSG} "${_PKGSRC_IN}> Perhaps you forgot the -P flag to 'cvs checkout' or 'cvs update'?"; \
			fi;						\
		else							\
			patchlist=`${ECHO} ${PATCHDIR}/patch-*`;	\
		fi;							\
	fi;								\
	if [ "X${_LOCALPATCHFILES}" = "X${_DFLT_LOCALPATCHFILES}" ]; then \
		localpatchfiles="`${ECHO} ${_LOCALPATCHFILES}`";	\
		if [ "$${localpatchfiles}" != "${_LOCALPATCHFILES}" ]; then \
			patchlist="$${patchlist} $${localpatchfiles}";	\
		fi;							\
	else								\
		patchlist=`${ECHO} $${patchlist} ${_LOCALPATCHFILES}`;	\
	fi;								\
	if [ -n "$${patchlist}" ]; then					\
		${ECHO_MSG} "${_PKGSRC_IN}> Applying pkgsrc patches for ${PKGNAME}" ; \
		fail="";						\
		for i in $${patchlist}; do				\
			if [ ! -f "$$i" ]; then				\
				${ECHO_MSG} "${_PKGSRC_IN}> $$i is not a valid patch file - skipping"; \
				continue; 				\
			fi;						\
			case $$i in					\
			*.orig|*.rej|*~)				\
				${ECHO_MSG} "${_PKGSRC_IN}> Ignoring patchfile $$i"; \
				continue;				\
				;;					\
			${PATCHDIR}/patch-local-*) 			\
				;;					\
			${PATCHDIR}/patch-*)	 			\
				if [ -f ${DISTINFO_FILE} ]; then	\
					filename=`expr $$i : '.*/\(.*\)'`; \
					algsum=`${AWK} 'NF == 4 && $$2 == "('$$filename')" && $$3 == "=" {print $$1 " " $$4}' ${DISTINFO_FILE} || ${TRUE}`; \
					if [ "X$$algsum" != "X" ]; then	\
						alg=`${ECHO} $$algsum | ${AWK} '{ print $$1 }'`; \
						recorded=`${ECHO} $$algsum | ${AWK} '{ print $$2 }'`; \
						calcsum=`${SED} -e '/\$$NetBSD.*/d' $$i | ${DIGEST} $$alg`; \
						if [ ${PATCH_DEBUG_TMP} = yes ]; then \
							${ECHO_MSG} "=> Verifying $$filename (using digest algorithm $$alg)"; \
						fi;			\
					fi;				\
					if [ "X$$algsum" = "X" -o "X$$recorded" = "X" ]; then \
						${ECHO_MSG} "**************************************"; \
						${ECHO_MSG} "Ignoring unknown patch file: $$i"; \
						${ECHO_MSG} "**************************************"; \
						continue;		\
					fi;				\
					if [ "X$$calcsum" != "X$$recorded" ]; then \
						${ECHO_MSG} "**************************************"; \
						${ECHO_MSG} "Patch file $$i has been modified"; \
						${ECHO_MSG} "**************************************"; \
						fail="$$fail $$filename"; \
						continue;		\
					fi;				\
				fi;					\
				;;					\
			esac;						\
			if [ ${PATCH_DEBUG_TMP} = yes ]; then		\
				${ECHO_MSG} "${_PKGSRC_IN}> Applying pkgsrc patch $$i" ; \
			fi;						\
			fuzz="";					\
			${PATCH} -v > /dev/null 2>&1 && fuzz="${PATCH_FUZZ_FACTOR}"; \
			${PATCH} $$fuzz ${PATCH_ARGS} < $$i ||		\
				{ ${ECHO} Patch $$i failed ; exit 1; };	\
		done;							\
		if [ "X$$fail" != "X" ]; then				\
			${ECHO_MSG} "Patching failed due to modified patch file(s): $$fail"; \
			exit 1;						\
		fi;							\
	fi
.endif

# Configure

# _CONFIGURE_PREREQ is a list of targets to run after pre-configure but before
#	do-configure.  These targets typically edit the files used by the
#	do-configure target.  The targets are run as dependencies of
#	pre-configure-override.
#
# _CONFIGURE_POSTREQ is a list of targets to run after do-configure but before
#	post-configure.  These targets typically edit the files generated by
#	the do-configure target that are used during the build phase.

.if defined(REPLACE_PERL)
REPLACE_INTERPRETER+=	perl
_REPLACE.perl.old=	.*/bin/perl
_REPLACE.perl.new=	${PERL5}
_REPLACE_FILES.perl=	${REPLACE_PERL}
.endif

_CONFIGURE_PREREQ+=	replace-interpreter
.PHONY: replace-interpreter
replace-interpreter:
.if defined(REPLACE_INTERPRETER)
.  for lang in ${REPLACE_INTERPRETER}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	cd ${WRKSRC};							\
	for f in ${_REPLACE_FILES.${lang}}; do				\
	    if [ -f $${f} ]; then					\
		    ${SED} -e 's|#!${_REPLACE.${lang}.old}|#!${_REPLACE.${lang}.new}|' \
			    $${f} > $${f}.new;				\
		    if [ -x $${f} ]; then				\
			    ${CHMOD} a+x $${f}.new;			\
		    fi;							\
		    ${MV} -f $${f}.new $${f};				\
	    fi;								\
	done
.  endfor
.else
	${_PKG_SILENT}${_PKG_DEBUG}${TRUE}
.endif

_CONFIGURE_PREREQ+=	do-ltconfig-override
.PHONY: do-ltconfig-override
do-ltconfig-override:
.if defined(USE_LIBTOOL) && defined(LTCONFIG_OVERRIDE)
.  for ltconfig in ${LTCONFIG_OVERRIDE}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -f ${ltconfig} ]; then					\
		${RM} -f ${ltconfig};					\
		${ECHO} "${RM} -f libtool; ${LN} -s ${PKGLIBTOOL} libtool" \
			> ${ltconfig};					\
		${CHMOD} +x ${ltconfig};				\
	fi
.  endfor
.else
	${_PKG_SILENT}${_PKG_DEBUG}${TRUE}
.endif

.if defined(CONFIG_GUESS_OVERRIDE) || defined(CONFIG_SUB_OVERRIDE)
_CONFIGURE_PREREQ+=	do-config-star-override
.PHONY: do-config-star-override
do-config-star-override:
.  if defined(CONFIG_GUESS_OVERRIDE)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for g in ${CONFIG_GUESS_OVERRIDE}; do				\
		${RM} -f $$g;						\
		${LN} -s ${_PKGSRCDIR}/mk/gnu-config/config.guess $$g;	\
	done
.  endif
.  if defined(CONFIG_SUB_OVERRIDE)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for s in ${CONFIG_SUB_OVERRIDE}; do				\
		${RM} -f $$s;						\
		${LN} -s ${_PKGSRCDIR}/mk/gnu-config/config.sub $$s;	\
	done
.  endif
.endif

.if defined(PKGCONFIG_OVERRIDE)
_CONFIGURE_PREREQ+=	do-pkgconfig-override
.PHONY: do-pkgconfig-override
do-pkgconfig-override:
.  for pkgconfig in ${PKGCONFIG_OVERRIDE}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -f ${pkgconfig} ]; then					\
		${MV} ${pkgconfig} ${pkgconfig}.norpath ;		\
		${SED} ${PKGCONFIG_OVERRIDE_SED}			\
			< ${pkgconfig}.norpath > ${pkgconfig} ;		\
	fi
.  endfor
.endif

.if empty(USE_BUILDLINK2:M[nN][oO])
#
# By default, prevent invocation of GNU "auto*" driven by the generated
# Makefiles during the build process by touching various auto{conf,make}
# source files to make them up-to-date.  Packages that require regenerating
# the configure script and Makefile.in files should make the appropriate
# calls to auto{conf,make} in a pre-configure target.
#
# The rationale for the choice of patterns is:
#
#   Before configure script is run:
#	* configure.in might be generated from configure.in.in,
#	* aclocal.m4 is generated by aclocal from acinclude.m4 and
#	  configure.in,
#	* stamp-h.in, stamp-h[0-9].in are the automake timestamp files
#	  for config.h.in,
#	* config.h.in is generated by autoheader from configure.in
#	* Makefile.in is generated from Makefile.am,
#	* the configure script is generated by autoconf from configure.in,
#	  aclocal.m4, and various other *.m4 files.
#
#   After configure script is run:
#	* config.status is generated by the configure script,
#	* Makefile, stamp-h, stamp-h[0-9] are generated by config.status.
#	* config.h are generated by config.status.
#
# NOTE: If you change the patterns listed below, then it's recommended that
#	you verify that the changes are correct by trying to build the
#	following packages:
#
#		sysutils/fileutils, www/curl, x11/lesstif, x11/kdelibs2
#
AUTOMAKE_OVERRIDE?=	YES
.  if empty(AUTOMAKE_OVERRIDE:M[nN][oO])
AUTOMAKE_PATTERNS+=     aclocal.m4
AUTOMAKE_PATTERNS+=     configure.in
AUTOMAKE_PATTERNS+=     Makefile.in
AUTOMAKE_PATTERNS+=     stamp-h.in stamp-h\[0-9\].in
AUTOMAKE_PATTERNS+=     stamp-vti
AUTOMAKE_PATTERNS+=     config.h.in
AUTOMAKE_PATTERNS+=     ${CONFIGURE_SCRIPT:T}

_CONFIGURE_PREREQ+=	automake-pre-override
.PHONY: automake-pre-override
automake-pre-override:
.    if defined(HAS_CONFIGURE)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	(for _PATTERN in ${AUTOMAKE_PATTERNS}; do			\
	   ${FIND} ${WRKSRC} -type f -name "$$_PATTERN" -print;		\
	 done; echo ${NULL_COOKIE} ) |					\
	${XARGS} ${TOUCH} ${TOUCH_FLAGS}
.    endif

AUTOMAKE_POST_PATTERNS+=     config.status
AUTOMAKE_POST_PATTERNS+=     Makefile
AUTOMAKE_POST_PATTERNS+=     stamp-h stamp-h[0-9]
AUTOMAKE_POST_PATTERNS+=     config.h

_CONFIGURE_POSTREQ+=	automake-post-override
.PHONY: automake-post-override
automake-post-override:
.    if defined(HAS_CONFIGURE)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	(for _PATTERN in ${AUTOMAKE_POST_PATTERNS}; do			\
	   ${FIND} ${WRKSRC} -type f -name "$$_PATTERN" -print;		\
	 done; echo ${NULL_COOKIE} ) |					\
	${XARGS} ${TOUCH} ${TOUCH_FLAGS}
.    endif
.  endif	# AUTOMAKE_OVERRIDE
.endif		# USE_BUILDLINK != "no"

# By adding this target, it makes sure the the above PREREQ's work.
.PHONY: pre-configure-override
pre-configure-override: ${_CONFIGURE_PREREQ}
	@${DO_NADA}

.PHONY: do-configure
.if !target(do-configure)
do-configure: 
.  if defined(HAS_CONFIGURE)
.    for DIR in ${CONFIGURE_DIRS}
	${_PKG_SILENT}${_PKG_DEBUG}${_ULIMIT_CMD}cd ${DIR} && ${SETENV} \
	    AWK="${AWK}" CC="${CC}" CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" \
	    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" FC="${FC}" F77="${FC}" FFLAGS="${FFLAGS}" \
	    INSTALL="`${TYPE} ${INSTALL} | ${AWK} '{ print $$NF }'` -c -o ${BINOWN} -g ${BINGRP}" \
	    ac_given_INSTALL="`${TYPE} ${INSTALL} | ${AWK} '{ print $$NF }'` -c -o ${BINOWN} -g ${BINGRP}" \
	    INSTALL_DATA="${INSTALL_DATA}" \
	    INSTALL_PROGRAM="${INSTALL_PROGRAM}" \
	    INSTALL_SCRIPT="${INSTALL_SCRIPT}" \
	    ${CONFIGURE_ENV} ${CONFIGURE_SCRIPT} ${CONFIGURE_ARGS}
.    endfor
.  endif
.  if defined(USE_IMAKE)
.    for DIR in ${CONFIGURE_DIRS}
	${_PKG_SILENT}${_PKG_DEBUG}cd ${DIR} && ${SETENV} ${SCRIPTS_ENV} XPROJECTROOT=${X11BASE} ${XMKMF}
.    endfor
.  endif
.endif

_CONFIGURE_POSTREQ+=	do-libtool-override
.PHONY: do-libtool-override
do-libtool-override:
.if defined(USE_LIBTOOL)
.  if defined(LIBTOOL_OVERRIDE)
.    for libtool in ${LIBTOOL_OVERRIDE}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -f ${libtool} ]; then					\
		${RM} -f ${libtool};					\
		${LN} -sf ${PKGLIBTOOL} ${libtool};			\
	fi
.    endfor
.  endif
.  if defined(SHLIBTOOL_OVERRIDE)
.    for libtool in ${SHLIBTOOL_OVERRIDE}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -f ${libtool} ]; then					\
		${RM} -f ${libtool};					\
		${LN} -sf ${PKGSHLIBTOOL} ${libtool};			\
	fi
.    endfor
.  endif
.else
	${_PKG_SILENT}${_PKG_DEBUG}${TRUE}
.endif

.PHONY: post-configure
post-configure: ${_CONFIGURE_POSTREQ}

# Build

BUILD_DIRS?=	${WRKSRC}

.PHONY: do-build
.if !target(do-build)
do-build:
.  for DIR in ${BUILD_DIRS}
	${_PKG_SILENT}${_PKG_DEBUG}${_ULIMIT_CMD}cd ${DIR} && ${SETENV} ${MAKE_ENV} ${MAKE_PROGRAM} ${MAKE_FLAGS} -f ${MAKEFILE} ${ALL_TARGET}
.  endfor
.endif

#Test

TEST_DIRS?=	${BUILD_DIRS}

.PHONY: do-test
.if !target(do-test)
do-test:
.  if defined(TEST_TARGET)
.    for DIR in ${TEST_DIRS}
	${_PKG_SILENT}${_PKG_DEBUG}${_ULIMIT_CMD}cd ${DIR} && ${SETENV} ${MAKE_ENV} ${MAKE_PROGRAM} ${MAKE_FLAGS} -f ${MAKEFILE} ${TEST_TARGET}
.    endfor
.  else
	@${DO_NADA}
.  endif
.endif

# Install

INSTALL_DIRS?=	${BUILD_DIRS}

.PHONY: do-install
.if !target(do-install)
do-install:
.  for DIR in ${INSTALL_DIRS}
	${_PKG_SILENT}${_PKG_DEBUG}${_ULIMIT_CMD}cd ${DIR} && ${SETENV} ${MAKE_ENV} ${MAKE_PROGRAM} ${MAKE_FLAGS} -f ${MAKEFILE} ${INSTALL_TARGET}
.  endfor
.endif

# Package

.PHONY: real-su-package
.if !target(real-su-package)
real-su-package: ${PLIST} ${DESCR}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${ECHO_MSG} "${_PKGSRC_IN}> Building binary package for ${PKGNAME}"; \
	if [ ! -d ${PKGREPOSITORY} ]; then				\
		${MKDIR} ${PKGREPOSITORY};				\
		if [ $$? -ne 0 ]; then					\
			${ECHO_MSG} "=> Can't create directory ${PKGREPOSITORY}."; \
			exit 1;						\
		fi;							\
	fi;								\
	if ${PKG_CREATE} ${PKG_ARGS_BINPKG} ${PKGFILE}; then		\
		${MAKE} ${MAKEFLAGS} package-links;			\
	else								\
		${MAKE} ${MAKEFLAGS} delete-package;			\
		exit 1;							\
	fi
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${PACKAGE_COOKIE}
.  if defined(NO_BIN_ON_CDROM)
	@${ECHO_MSG} "${_PKGSRC_IN}> Warning: ${PKGNAME} may not be put on a CD-ROM:"
	@${ECHO_MSG} "${_PKGSRC_IN}>         " ${NO_BIN_ON_CDROM:Q}
.  endif
.  if defined(NO_BIN_ON_FTP)
	@${ECHO_MSG} "${_PKGSRC_IN}> Warning: ${PKGNAME} may not be made available through FTP:"
	@${ECHO_MSG} "${_PKGSRC_IN}>         " ${NO_BIN_ON_FTP:Q}
.  endif
.endif

# Some support rules for real-su-package

.PHONY: package-links
.if !target(package-links)
package-links:
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${MAKEFLAGS} delete-package-links
	${_PKG_SILENT}${_PKG_DEBUG}for cat in ${CATEGORIES}; do		\
		if [ ! -d ${PACKAGES}/$$cat ]; then			\
			${MKDIR} ${PACKAGES}/$$cat;			\
			if [ $$? -ne 0 ]; then				\
				${ECHO_MSG} "=> Can't create directory ${PACKAGES}/$$cat."; \
				exit 1;					\
			fi;						\
		fi;							\
		${RM} -f ${PACKAGES}/$$cat/${PKGNAME}${PKG_SUFX};	\
		${LN} -s ../${PKGREPOSITORYSUBDIR}/${PKGNAME}${PKG_SUFX} ${PACKAGES}/$$cat; \
	done;
.endif

.PHONY: delete-package-links
.if !target(delete-package-links)
delete-package-links:
	${_PKG_SILENT}${_PKG_DEBUG}\
	${FIND} ${PACKAGES} -type l -name ${PKGNAME}${PKG_SUFX} | ${XARGS} ${RM} -f
.endif

.PHONY: delete-package
.if !target(delete-package)
delete-package:
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${MAKEFLAGS} delete-package-links
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${PKGFILE}
.endif

.PHONY: real-su-install
real-su-install: ${MESSAGE}
.if !defined(NO_PKG_REGISTER) && !defined(FORCE_PKG_REGISTER)
.  if defined(CONFLICTS)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${RM} -f ${WRKDIR}/.CONFLICTS
.    for conflict in ${CONFLICTS}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	found="`${PKG_INFO} -e \"${conflict}\" || ${TRUE}`";		\
	if [ X"$$found" != X"" ]; then					\
		${ECHO} "$$found" >> ${WRKDIR}/.CONFLICTS;		\
	fi
.     endfor
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -s ${WRKDIR}/.CONFLICTS ]; then				\
		found=`${SED} -e s'|${PKG_DBDIR}/||g' ${WRKDIR}/.CONFLICTS | tr '\012' ' '`; \
		${ECHO_MSG} "${_PKGSRC_IN}> ${PKGNAME} conflicts with installed package(s): $$found found."; \
		${ECHO_MSG} "*** They install the same files into the same place."; \
		${ECHO_MSG} "*** Please remove $$found first with pkg_delete(1)."; \
		${RM} -f ${WRKDIR}/.CONFLICTS;				\
		exit 1;							\
	fi
.  endif	# CONFLICTS
	${_PKG_SILENT}${_PKG_DEBUG}					\
	found="`${PKG_INFO} -e \"${PKGWILDCARD}\" || ${TRUE}`";		\
	if [ "$$found" != "" ]; then					\
		${ECHO_MSG} "${_PKGSRC_IN}>  $$found is already installed - perhaps an older version?"; \
		${ECHO_MSG} "*** If so, you may use either of:"; \
		${ECHO_MSG} "***  - \"pkg_delete $$found\" and \"${MAKE} reinstall\" to upgrade properly"; \
		${ECHO_MSG} "***  - \"${MAKE} update\" to rebuild the package and all of its dependencies"; \
		${ECHO_MSG} "***  - \"${MAKE} replace\" to replace only the package without re-linking"; \
		${ECHO_MSG} "***    dependencies, risking various problems."; \
		exit 1;							\
	fi
.endif # !NO_PKG_REGISTER && !NO_FORCE_REGISTER
	${_PKG_SILENT}${_PKG_DEBUG}if [ `${SH} -c umask` -ne ${DEF_UMASK} ]; then \
		${ECHO_MSG} "${_PKGSRC_IN}>  Warning: your umask is \"`${SH} -c umask`"\".; \
		${ECHO_MSG} "If this is not desired, set it to an appropriate value (${DEF_UMASK})"; \
		${ECHO_MSG} "and install this package again by \`\`${MAKE} deinstall reinstall''."; \
	fi
.if !defined(NO_MTREE)
	${_PKG_SILENT}${_PKG_DEBUG}if [ `${ID} -u` = 0 ]; then		\
		if [ ! -f ${MTREE_FILE} ]; then				\
			${ECHO_MSG} "Error: mtree file \"${MTREE_FILE}\" is missing."; \
			exit 1;						\
		else							\
			if [ ! -d ${PREFIX} ]; then			\
				${MKDIR} ${PREFIX};			\
			fi;						\
			${MTREE} ${MTREE_ARGS} ${PREFIX}/;		\
		fi;							\
	else								\
		${ECHO_MSG} "Warning: not superuser, can't run mtree."; \
		${ECHO_MSG} "Become root and try again to ensure correct permissions."; \
	fi
.endif # !NO_MTREE
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} pre-install-script
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} pre-install
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} do-install
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} post-install
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} post-install-script
.if !defined(USE_NEW_TEXINFO)
.  for f in ${INFO_FILES}
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO} "${INSTALL_INFO} --info-dir=${PREFIX}/info ${PREFIX}/info/${f}"; \
	${INSTALL_INFO} --remove --info-dir=${PREFIX}/info ${PREFIX}/info/${f}; \
	${INSTALL_INFO} --info-dir=${PREFIX}/info ${PREFIX}/info/${f}
.  endfor
.endif # !USE_NEW_TEXINFO
	@# PLIST must be generated at this late point (instead of
	@# depending on it somewhere earlier), as the
	@# pre/do/post-install aren't run then yet:
	@${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} ${PLIST}
	${_PKG_SILENT}${_PKG_DEBUG}newmanpages=`${EGREP} -h		\
		'^([^@/]*/)*man/([^/]*/)?(man[1-9ln]/.*\.[1-9ln]|cat[1-9ln]/.*\.0)(\.gz)?$$' \
		${PLIST} 2>/dev/null || ${TRUE}`;			\
	if [ X"${MANCOMPRESSED}" != X"" -a X"${MANZ}" = X"" ]; then	\
		${ECHO_MSG} "${_PKGSRC_IN}> [Automatic manual page handling]";	\
		${ECHO_MSG} "${_PKGSRC_IN}> Decompressing manual pages for ${PKGNAME}";	\
		for manpage in $$newmanpages; do			\
			manpage=`${ECHO} $$manpage | ${SED} -e 's|\.gz$$||'`; \
			if [ -h ${PREFIX}/$$manpage.gz ]; then		\
				set - `${FILE_CMD} ${PREFIX}/$$manpage.gz | ${SED} -e 's|\.gz$$||'`; \
				shift `expr $$# - 1`;			\
				${RM} -f ${PREFIX}/$$manpage;		\
				${LN} -s $${1} ${PREFIX}/$$manpage;	\
				${RM} ${PREFIX}/$$manpage.gz;		\
			else						\
				${GUNZIP_CMD} ${PREFIX}/$$manpage.gz;	\
			fi;						\
			if [ X"${PKG_VERBOSE}" != X"" ]; then		\
				${ECHO_MSG} "$$manpage";		\
			fi;						\
		done;							\
	fi;								\
	if [ X"${MANCOMPRESSED}" = X"" -a X"${MANZ}" != X"" ]; then	\
		${ECHO_MSG} "${_PKGSRC_IN}> [Automatic manual page handling]";	\
		${ECHO_MSG} "${_PKGSRC_IN}> Compressing manual pages for ${PKGNAME}"; \
		for manpage in $$newmanpages; do			\
			manpage=`${ECHO} $$manpage | ${SED} -e 's|\.gz$$||'`; \
			if [ -h ${PREFIX}/$$manpage ]; then		\
				set - `${FILE_CMD} ${PREFIX}/$$manpage`; \
				shift `expr $$# - 1`;			\
				${RM} -f ${PREFIX}/$$manpage.gz; 	\
				${LN} -s $${1}.gz ${PREFIX}/$$manpage.gz; \
				${RM} ${PREFIX}/$$manpage;		\
			else						\
				${GZIP_CMD} ${PREFIX}/$$manpage;	\
			fi;						\
			if [ X"${PKG_VERBOSE}" != X"" ]; then		\
				${ECHO_MSG} "$$manpage";		\
			fi;						\
		done;							\
	fi
.if ${_DO_SHLIB_CHECKS} == "yes"
	${_PKG_SILENT}${_PKG_DEBUG}\
	${MAKE} ${MAKEFLAGS} do-shlib-handling SHLIB_PLIST_MODE=0
.endif
.ifdef MESSAGE
	@${ECHO_MSG} "${_PKGSRC_IN}> Please note the following:"
	@${ECHO_MSG} ""
	@${CAT} ${MESSAGE}
	@${ECHO_MSG} ""
.endif
.if !defined(NO_PKG_REGISTER)
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} fake-pkg
.endif # !NO_PKG_REGISTER
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${INSTALL_COOKIE}
.if defined(PKG_DEVELOPER) && (${CHECK_SHLIBS} == "YES")
	@${MAKE} ${MAKEFLAGS} check-shlibs
.endif



# Do handling of shared libs for two cases:
#
# SHLIB_PLIST_MODE=1: when first called via the ${PLIST} target,
#                     update the PLIST to contain ELF symlink, run
#                     ldconfig on a.out,  etc. (used when called via
#                     the ${PLIST} target). Will update ${PLIST}.
# SHLIB_PLIST_MODE=0: when called via the real-su-install target,
#                     actually generate symlinks for ELF, run ldconfig
#                     for a.out, etc. Will not modify ${PLIST}.
#
# XXX This target could need some cleanup after it was ripped out of
#     real-su-install
#
.PHONY: do-shlib-handling
do-shlib-handling:
.if ${SHLIB_HANDLING} == "YES"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	sos=`${EGREP} -h -x '.*/lib[^/]+\.so\.[0-9]+(\.[0-9]+)+' ${PLIST} || ${TRUE}`; \
	if [ "$$sos" != "" ]; then					\
		shlib_type=`${MAKE} ${MAKEFLAGS} show-shlib-type`;	\
		if [ "${SHLIB_PLIST_MODE}" = "0" ]; then 		\
			${ECHO_MSG} "${_PKGSRC_IN}> [Automatic $$shlib_type shared object handling]"; \
		fi;  							\
		case "$$shlib_type" in					\
		ELF) 	;;						\
		"a.out") 						\
			${AWK} ' 					\
				BEGIN { linkc = 1 }			\
				/^@/ { lines[NR] = $$0; next }		\
				function libtool_release(lib) {		\
					if (gsub("-[^-]+\.so\.", "\.so\.", lib)) { \
						if (system("${TEST} -h ${PREFIX}/" lib) == 0) { \
							rels[NR] = lib; \
						}			\
					}				\
				}					\
				/.*\/lib[^\/]+\.so\.[0-9]+\.[0-9]+\.[0-9]+$$/ { \
					libtool_release($$0);		\
					lines[NR] = $$0;		\
					sub("\.[0-9]+$$", "");		\
					links[linkc++] = $$0;		\
					sub("\.[0-9]+$$", "");		\
					links[linkc++] = $$0;		\
					sub("\.[0-9]+$$", "");		\
					links[linkc++] = $$0;		\
					if (sub("-[^-]+\.so$$", "\.so")) { \
						links[linkc++] = $$0;	\
					}				\
					next				\
				}					\
				/.*\/lib[^\/]+\.so\.[0-9]+\.[0-9]+$$/ {	\
					libtool_release($$0);		\
					lines[NR] = $$0;		\
					sub("\.[0-9]+$$", "");		\
					links[linkc++] = $$0;		\
					sub("\.[0-9]+$$", "");		\
					links[linkc++] = $$0;		\
					if (sub("-[^-]+\.so$$", "\.so")) { \
						links[linkc++] = $$0;	\
					}				\
					next				\
				}					\
				{ lines[NR] = $$0 }			\
				END {					\
					for (i = 1 ; i <= linkc ; i++)	\
						for (j = 1 ; j < NR ; j++) \
							if (lines[j] == links[i]) \
								lines[j] = "@comment " lines[j]; \
					if (${SHLIB_PLIST_MODE}) 	\
						for (i = 1 ; i <= NR ; i++) { \
							print lines[i]; \
							if (rels[i] != "") \
								print rels[i]; \
						}			\
				}					\
			' <${PLIST} >${PLIST}.tmp ;			\
			if [ "${SHLIB_PLIST_MODE}" = "1" ]; then	\
				${MV} ${PLIST}.tmp ${PLIST};		\
			else 						\
				${RM} ${PLIST}.tmp ;			\
			fi ; 						\
			cnt=`${EGREP} -c -x '@exec[ 	]*${LDCONFIG}' ${PLIST} || ${TRUE}`; \
			if [ "${SHLIB_PLIST_MODE}" = "1" ]; then 	\
				if [ $$cnt -eq 0 ]; then		\
					${ECHO} "@exec ${LDCONFIG}" >> ${PLIST}; \
					${ECHO} "@unexec ${LDCONFIG}" >> ${PLIST}; \
				fi					\
			fi;						\
			if [ "${SHLIB_PLIST_MODE}" = "0" ]; then	\
				if [ "${PKG_VERBOSE}" != "" ]; then	\
					${ECHO_MSG} "$$sos";		\
					${ECHO_MSG} "Running ${LDCONFIG}"; \
				fi;					\
				${LDCONFIG} || ${TRUE};			\
			fi						\
			;;						\
		"dylib")						\
			${AWK} '					\
				/^@/ { lines[NR] = $$0; next }		\
		    		function libtool_release(lib) {		\
					if (gsub("\.so\.", "\.", lib) || gsub("\.so$$", "", lib)) { \
						lib = lib ".dylib"; \
						if (system("${TEST} -h ${PREFIX}/" lib) == 0) { \
							rels[NR] = lib; \
						}			\
					}				\
				}					\
				/.*\/lib[^\/]+\.so\.[0-9]+\.[0-9]+\.[0-9]+$$/ { \
					libtool_release($$0);		\
					lines[NR] = $$0;		\
					links[linkc++] = $$0;		\
					sub("\.[0-9]+$$", "");		\
					links[linkc++] = $$0;		\
					sub("\.[0-9]+$$", "");		\
					links[linkc++] = $$0;		\
					sub("\.[0-9]+$$", "");		\
					links[linkc++] = $$0;		\
					if (sub("-[^-]+\.so$$", "\.so")) { \
						links[linkc++] = $$0;	\
					}				\
					next				\
				}					\
				/.*\/lib[^\/]+\.so\.[0-9]+\.[0-9]+$$/ {	\
					libtool_release($$0);		\
					lines[NR] = $$0;		\
					links[linkc++] = $$0;		\
					sub("\.[0-9]+$$", "");		\
					links[linkc++] = $$0;		\
					sub("\.[0-9]+$$", "");		\
					links[linkc++] = $$0;		\
					if (sub("-[^-]+\.so$$", "\.so")) { \
						links[linkc++] = $$0;	\
					}				\
					next				\
				}					\
				/.*\/lib[^\/]+\.so\.[0-9]+$$/ {		\
					libtool_release($$0);		\
					lines[NR] = $$0;		\
					links[linkc++] = $$0;		\
					sub("\.[0-9]+$$", "");		\
					links[linkc++] = $$0;		\
					if (sub("-[^-]+\.so$$", "\.so")) { \
						links[linkc++] = $$0;	\
					}				\
					next				\
				}					\
				/.*\/lib[^\/]+\.so$$/ {			\
					libtool_release($$0);		\
					lines[NR] = $$0;		\
					links[linkc++] = $$0;		\
					if (sub("-[^-]+\.so$$", "\.so")) { \
						links[linkc++] = $$0;	\
					}				\
					next				\
				}					\
				{ lines[NR] = $$0 }			\
				END {					\
					for (i = 1 ; i <= linkc ; i++)	\
						for (j = 1 ; j <= NR ; j++) \
							if (lines[j] == links[i]) \
								lines[j] = "@comment " lines[j]; \
					if (${SHLIB_PLIST_MODE}) 	\
						for (i = 1 ; i <= NR ; i++) { \
							print lines[i]; \
							if (rels[i] != "") { \
								print rels[i]; \
								"${LS} -l ${PREFIX}/" rels[i] | getline tgt; \
								gsub(".* ", "", tgt); \
								if (tgts[tgt] == "") { \
									tgts[tgt] = tgt; \
				                                	if (index(tgt, "/") == 1) \
				                                		print tgt; \
				                                	else { \
				                                		prefix=""; \
				                                        	if (match(rels[i], ".*/") != 0) \
				                        				prefix=substr(rels[i],1,RLENGTH); \
						                        	print prefix tgt; \
				                        		} \
								}	\
							}		\
						}			\
				}					\
			' <${PLIST} >${PLIST}.tmp ;			\
			if [ "${SHLIB_PLIST_MODE}" = "1" ]; then	\
				${MV} ${PLIST}.tmp ${PLIST};		\
			else 						\
				${RM} ${PLIST}.tmp ;			\
			fi ; 						\
			;;						\
		"*")							\
			if [ "${SHLIB_PLIST_MODE}" = "0" ]; then 	\
				${ECHO_MSG} "No shared libraries for ${MACHINE_ARCH}"; \
			fi ; 						\
			if [ "${SHLIB_PLIST_MODE}" = "1" ]; then	\
				for so in $$sos; do			\
					if [ X"${PKG_VERBOSE}" != X"" ]; then \
						${ECHO_MSG} >&2 "Ignoring $$so"; \
					fi;				\
					${SED} -e "s;^$$so$$;@comment No shared objects - &;" \
						${PLIST} >${PLIST}.tmp && ${MV} ${PLIST}.tmp ${PLIST};	\
				done;					\
			fi ;						\
			;;						\
		esac;							\
	fi
.endif # SHLIB_HANDLING == "YES"


# Check if all binaries and shlibs find their needed libs
# Must be run after "make install", so that files are installed, and
# ${PLIST} exists.
#
.PHONY: check-shlibs
check-shlibs:
.if !defined(NO_PKG_REGISTER)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	bins=`${PKG_INFO} -qL ${PKGNAME} | { ${EGREP} -h '/(bin|sbin|libexec)/' || ${TRUE}; }`; \
	if [ "${OBJECT_FMT}" = "ELF" ]; then				\
		shlibs=`${PKG_INFO} -qL ${PKGNAME} | { ${EGREP} -h '/lib/lib.*.so' || ${TRUE}; }`; \
	else								\
		shlibs="";						\
	fi;								\
	if [ X${LDD} = X ]; then					\
		ldd=`${TYPE} ldd | ${AWK} '{ print $$NF }'`;		\
	else								\
		ldd="${LDD}";						\
	fi;								\
	for i in $${bins} $${shlibs}; do				\
		err=`{ $$ldd $$i 2>&1 || ${TRUE}; } | { ${GREP} "not found" || ${TRUE}; }`; \
		if [ "${PKG_VERBOSE}" != "" ]; then			\
			${ECHO} "$$ldd $$i";				\
		fi;							\
		if [ "$$err" != "" ]; then				\
			${ECHO} "$$i: $$err";				\
			error=1;					\
		fi;							\
	done;								\
	if [ "$$error" = 1 ]; then					\
		${ECHO} "*** The above programs/libs will not find the listed shared libraries"; \
		${ECHO} "    at runtime. Please fix the package (add -Wl,-R.../lib in the right places)!"; \
		${SHCOMMENT} Might not error-out for non-pkg-developers; \
		exit 1;							\
	fi
.endif # NO_PKG_REGISTER


.if !target(show-shlib-type)
# Show the shared lib type being built: one of ELF, a.out, dylib, or none
.PHONY: show-shlib-type
show-shlib-type:
.  if exists(/usr/lib/libc.dylib)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${ECHO} "dylib"
.  else
	${_PKG_SILENT}${_PKG_DEBUG}					\
	cd ${WRKDIR} &&							\
	sotype=none;							\
	if [ "X${MKPIC}" != "Xno" -a "X${NOPIC}" = "X" ]; then		\
		${ECHO} "int main() { exit(0); }" > a.$$$$.c;		\
		${CC} ${CFLAGS} a.$$$$.c -o a.$$$$.out;			\
		case `${FILE_CMD} a.$$$$.out` in			\
		*ELF*dynamically*)					\
			sotype=ELF ;;					\
		*shared*library*)					\
			sotype="a.out" ;;				\
		*dynamically*)						\
			sotype="a.out" ;;				\
		esac;							\
	fi;								\
	${ECHO} "$$sotype";						\
	${RM} -f a.$$$$.c a.$$$$.out
.  endif # libc.dylib
.endif

.PHONY: acquire-extract-lock acquire-patch-lock acquire-buildlink-lock
.PHONY: acquire-configure-lock acquire-build-lock
acquire-extract-lock:
	${_ACQUIRE_LOCK}
acquire-patch-lock:
	${_ACQUIRE_LOCK}
acquire-buildlink-lock:
	${_ACQUIRE_LOCK}
acquire-configure-lock:
	${_ACQUIRE_LOCK}
acquire-build-lock:
	${_ACQUIRE_LOCK}

.PHONY: release-extract-lock release-patch-lock release-buildlink-lock
.PHONY: release-configure-lock release-build-lock
release-extract-lock:
	${_RELEASE_LOCK}
release-patch-lock:
	${_RELEASE_LOCK}
release-buildlink-lock:
	${_RELEASE_LOCK}
release-configure-lock:
	${_RELEASE_LOCK}
release-build-lock:
	${_RELEASE_LOCK}

################################################################
# Skeleton targets start here
#
# You shouldn't have to change these.  Either add the pre-* or
# post-* targets/scripts or redefine the do-* targets.  These
# targets don't do anything other than checking for cookies and
# call the necessary targets/scripts.
################################################################

.PHONY: fetch
.if !target(fetch)
fetch:
	@cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-fetch
.endif

.PHONY: extract
.if !target(extract)
extract: checksum ${WRKDIR} acquire-extract-lock ${EXTRACT_COOKIE} release-extract-lock
.endif

.PHONY: patch
.if !target(patch)
patch: extract acquire-patch-lock ${PATCH_COOKIE} release-patch-lock
.endif

.PHONY: buildlink
.if !target(buildlink)
buildlink: patch acquire-buildlink-lock ${BUILDLINK_COOKIE} release-buildlink-lock
.endif

.PHONY: configure
.if !target(configure)
configure: buildlink acquire-configure-lock ${CONFIGURE_COOKIE} release-configure-lock
.endif

.PHONY: build
.if !target(build)
build: configure acquire-build-lock ${BUILD_COOKIE} release-build-lock
.endif

.PHONY: test
.if !target(test)
test: build ${TEST_COOKIE}
.endif

.PHONY: install
.if !target(install)
.  if ${PKGSRC_RUN_TEST} == "YES" || ${PKGSRC_RUN_TEST} == "yes"
install: uptodate-pkgtools build test ${INSTALL_COOKIE}
.  else
install: uptodate-pkgtools build ${INSTALL_COOKIE}
.  endif
.endif

.PHONY: package
.if !target(package)
package: uptodate-pkgtools install ${PACKAGE_COOKIE}
.endif

.PHONY: replace
.if !target(replace)
replace: uptodate-pkgtools build real-replace
.endif

.PHONY: undo-replace
.if !target(undo-replace)
undo-replace: uptodate-pkgtools real-undo-replace
.endif

${EXTRACT_COOKIE}:
.if ${INTERACTIVE_STAGE:Mextract} == "extract" && defined(BATCH)
	@${ECHO} "*** The extract stage of this package requires user interaction"
	@${ECHO} "*** Please extract manually with \"cd ${PKGDIR} && ${MAKE} extract\""
	@${TOUCH} ${INTERACTIVE_COOKIE}
	@${FALSE}
.else
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-extract DEPENDS_TARGET=${DEPENDS_TARGET}
.endif

${PATCH_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-patch

${BUILDLINK_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-buildlink

${CONFIGURE_COOKIE}:
.if ${INTERACTIVE_STAGE:Mconfigure} == "configure" && defined(BATCH)
	@${ECHO} "*** The configuration stage of this package requires user interaction"
	@${ECHO} "*** Please configure manually with \"cd ${PKGDIR} && ${MAKE} configure\""
	@${TOUCH} ${INTERACTIVE_COOKIE}
	@${FALSE}
.else
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-configure
.endif

${BUILD_COOKIE}:
.if ${INTERACTIVE_STAGE:Mbuild} == "build" && defined(BATCH)
	@${ECHO} "*** The build stage of this package requires user interaction"
	@${ECHO} "*** Please build manually with \"cd ${PKGDIR} && ${MAKE} build\""
	@${TOUCH} ${INTERACTIVE_COOKIE}
	@${FALSE}
.else
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-build
.endif

${TEST_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-test

${INSTALL_COOKIE}:
.if ${INTERACTIVE_STAGE:Minstall} == "install" && defined(BATCH)
	@${ECHO} "*** The installation stage of this package requires user interaction"
	@${ECHO} "*** Please install manually with \"cd ${PKGDIR} && ${MAKE} install\""
	@${TOUCH} ${INTERACTIVE_COOKIE}
	@${FALSE}
.else
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-install
.endif

${PACKAGE_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-package

.PHONY: extract-message patch-message buildlink-message configure-message
.PHONY: build-message test-message
extract-message:
	@${ECHO_MSG} "${_PKGSRC_IN}> Extracting for ${PKGNAME}"
patch-message:
	@${ECHO_MSG} "${_PKGSRC_IN}> Patching for ${PKGNAME}"
buildlink-message:
	@${ECHO_MSG} "${_PKGSRC_IN}> Buildlinking for ${PKGNAME}"
configure-message:
	@${ECHO_MSG} "${_PKGSRC_IN}> Configuring for ${PKGNAME}"
build-message:
	@${ECHO_MSG} "${_PKGSRC_IN}> Building for ${PKGNAME}"
test-message:
	@${ECHO_MSG} "${_PKGSRC_IN}> Testing for ${PKGNAME}"

.PHONY: extract-cookie patch-cookie buildlink-cookie configure-cookie
.PHONY: build-cookie test-cookie
extract-cookie:
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO} ${PKGNAME} >> ${EXTRACT_COOKIE}
patch-cookie:
	${_PKG_SILENT}${_PKG_DEBUG} ${TOUCH} ${TOUCH_FLAGS} ${PATCH_COOKIE}
buildlink-cookie:
	${_PKG_SILENT}${_PKG_DEBUG} ${TOUCH} ${TOUCH_FLAGS} ${BUILDLINK_COOKIE}
configure-cookie:
	${_PKG_SILENT}${_PKG_DEBUG} ${TOUCH} ${TOUCH_FLAGS} ${CONFIGURE_COOKIE}
build-cookie:
	${_PKG_SILENT}${_PKG_DEBUG} ${TOUCH} ${TOUCH_FLAGS} ${BUILD_COOKIE}
test-cookie:
	${_PKG_SILENT}${_PKG_DEBUG} ${TOUCH} ${TOUCH_FLAGS} ${TEST_COOKIE}

.ORDER: pre-fetch do-fetch post-fetch
.ORDER: extract-message install-depends pre-extract do-extract post-extract extract-cookie
.ORDER: patch-message pre-patch do-patch post-patch patch-cookie
.ORDER: buildlink-message pre-buildlink do-buildlink post-buildlink buildlink-cookie
.ORDER: configure-message pre-configure pre-configure-override do-configure post-configure configure-cookie
.ORDER: build-message pre-build do-build post-build build-cookie
.ORDER: test-message pre-test do-test post-test test-cookie

# Please note that the order of the following targets is important, and
# should not be modified (.ORDER is not recognised by make(1) in a serial
# make i.e. without -j n)
.PHONY: real-fetch real-extract real-patch real-buildlink real-configure
.PHONY: real-build real-test real-install real-package real-replace
.PHONY: real-undo-replace
real-fetch: pre-fetch do-fetch post-fetch
real-extract: extract-message install-depends pre-extract do-extract post-extract extract-cookie
real-patch: patch-message pre-patch do-patch post-patch patch-cookie
real-buildlink: buildlink-message pre-buildlink do-buildlink post-buildlink buildlink-cookie
real-configure: configure-message pre-configure pre-configure-override do-configure post-configure configure-cookie
real-build: build-message pre-build do-build post-build build-cookie
real-test: test-message pre-test do-test post-test test-cookie
real-install: do-su-install
real-package: do-su-package
real-replace: do-su-replace
real-undo-replace: do-su-undo-replace

_SU_TARGET=								\
	if [ `${ID} -u` = 0 ]; then					\
		${MAKE} ${MAKEFLAGS} $$realtarget;			\
	elif [ "X${BATCH}" != X"" ]; then				\
		${ECHO_MSG} "Warning: Batch mode, not superuser, can't run $$action for ${PKGNAME}."; \
		${ECHO_MSG} "Become root and try again to ensure correct permissions."; \
	else								\
		args="";						\
		if [ "X${FORCE_PKG_REGISTER}" != X"" ]; then		\
			args="FORCE_PKG_REGISTER=1";			\
		fi;							\
		if [ "X${PKG_DEBUG_LEVEL}" != X"" ]; then		\
			args="$$args PKG_DEBUG_LEVEL=${PKG_DEBUG_LEVEL}"; \
		fi;							\
		if [ "X${PRE_ROOT_CMD}" != "X${TRUE}" ]; then		\
			${ECHO} "*** WARNING *** Running: ${PRE_ROOT_CMD}"; \
			${PRE_ROOT_CMD};				\
		fi;                                             	\
		${ECHO_MSG} "${_PKGSRC_IN}> Becoming root@`${HOSTNAME_CMD}` to $$action ${PKGNAME}."; \
		${ECHO_MSG} -n "`${ECHO} ${SU_CMD} | ${AWK} '{ print $$1 }'` ";\
		${SU_CMD} "cd ${.CURDIR}; ${SETENV} PATH=$${PATH}:${SU_CMD_PATH_APPEND} ${MAKE} $$args ${MAKEFLAGS} $$realtarget $$realflags"; \
	fi

.PHONY: do-su-install
do-su-install:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	extractname=`${CAT} ${EXTRACT_COOKIE}`;				\
	case "$$extractname" in						\
	"")	${ECHO_MSG} "*** Warning: ${WRKDIR} may contain an older version of ${PKGBASE}" ;; \
	"${PKGNAME}")	;;						\
	*)	${ECHO_MSG} "*** Warning: Package version $$extractname in ${WRKDIR}"; \
		${ECHO_MSG} "*** Current version ${PKGNAME} in pkgsrc directory"; \
		${ECHO_MSG} "*** Cleaning and rebuilding the newer version of the package..."; \
		${MAKE} clean && ${MAKE} build ;;			\
	esac
	@${ECHO_MSG} "${_PKGSRC_IN}> Installing for ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	realtarget="real-su-install";					\
	action="install";						\
	${_SU_TARGET}

.PHONY: do-su-package
do-su-package:
	@${ECHO_MSG} "${_PKGSRC_IN}> Packaging ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	realtarget="real-su-package";					\
	action="package";						\
	${_SU_TARGET}

.PHONY: do-su-replace
do-su-replace:
	@${ECHO_MSG} "${_PKGSRC_IN}> Replacing ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	realtarget="real-su-replace";					\
	action="replace";						\
	${_SU_TARGET}

.PHONY: do-su-undo-replace
do-su-undo-replace:
	@${ECHO_MSG} "${_PKGSRC_IN}> Undoing Replacement of ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	realtarget="real-su-undo-replace";				\
	action="undo-replace";						\
	${_SU_TARGET}

# Empty pre-* and post-* targets

.for name in fetch extract patch buildlink configure build test install-script install package

.  if !target(pre-${name})
pre-${name}:
	@${DO_NADA}
.  endif

.  if !target(post-${name})
post-${name}:
	@${DO_NADA}
.  endif

.endfor

# Reinstall
#
# Special target to re-run install

.PHONY: reinstall
.if !target(reinstall)
reinstall:
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${INSTALL_COOKIE} ${PACKAGE_COOKIE} ${PLIST}
	${_PKG_SILENT}${_PKG_DEBUG}DEPENDS_TARGET=${DEPENDS_TARGET} ${MAKE} ${MAKEFLAGS} install
.endif

# Deinstall
#
# Special target to remove installation

.PHONY: deinstall do-su-deinstall
.if !target(deinstall)
deinstall: do-su-deinstall

do-su-deinstall: uptodate-pkgtools
	@${ECHO_MSG} "${_PKGSRC_IN}> Deinstalling for ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	realtarget="real-su-deinstall";					\
	realflags="DEINSTALLDEPENDS=${DEINSTALLDEPENDS}";		\
	action="deinstall";						\
	${_SU_TARGET}

.  if (${DEINSTALLDEPENDS} != "NO")
.    if (${DEINSTALLDEPENDS} != "ALL")
# used for removing stuff in bulk builds
real-su-deinstall-flags+=	-r -R
# used for "update" target
.    else
real-su-deinstall-flags+=	-r
.    endif
.  endif
.  ifdef PKG_VERBOSE
real-su-deinstall-flags+=	-v
.  endif

.PHONY: real-su-deinstall
real-su-deinstall:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	found="`${PKG_INFO} -e \"${PKGWILDCARD}\" || ${TRUE}`";		\
	if [ "$$found" != "" ]; then					\
		${ECHO} Running ${PKG_DELETE} ${real-su-deinstall-flags} $$found ; \
		${PKG_DELETE} ${real-su-deinstall-flags} $$found || ${TRUE} ; \
	fi
.  if (${DEINSTALLDEPENDS} != "NO") && (${DEINSTALLDEPENDS} != "ALL")
	@${SHCOMMENT} Also remove BUILD_DEPENDS:
.    for pkg in ${BUILD_DEPENDS:C/:.*$//}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	found="`${PKG_INFO} -e \"${pkg}\" || ${TRUE}`";			\
	if [ "$$found" != "" ]; then					\
		${ECHO} Running ${PKG_DELETE} $$found;			\
		${PKG_DELETE} ${real-su-deinstall-flags} $$found || ${TRUE}; \
	fi
.    endfor
.  endif # DEINSTALLDEPENDS
	@${RM} -f ${INSTALL_COOKIE} ${PACKAGE_COOKIE}
.endif						# target(deinstall)


################################################################
# Some more targets supplied for users' convenience
################################################################

# The 'update' target can be used to update a package and all
# currently installed packages that depend upon this package.

.PHONY: update
.if !target(update)
.if exists(${DDIR})
RESUMEUPDATE?=	YES
CLEAR_DIRLIST?=	NO

update:
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO_MSG}				\
		"${_PKGSRC_IN}> Resuming update for ${PKGNAME}"
.  if ${REINSTALL} != "NO" && ${UPDATE_TARGET} != "replace"
	${_PKG_SILENT}${_PKG_DEBUG}					\
		${MAKE} ${MAKEFLAGS} deinstall DEINSTALLDEPENDS=ALL
.  endif
.else
RESUMEUPDATE?=	NO
CLEAR_DIRLIST?=	YES

update:
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${MAKEFLAGS} ${DDIR}
.  if ${UPDATE_TARGET} != "replace"
	${_PKG_SILENT}${_PKG_DEBUG}if ${PKG_INFO} -qe ${PKGBASE}; then	\
		${MAKE} ${MAKEFLAGS} deinstall DEINSTALLDEPENDS=ALL	\
		|| (${RM} ${DDIR} && ${FALSE});				\
	fi
.  endif
.endif
	${_PKG_SILENT}${_PKG_DEBUG}					\
		${MAKE} ${MAKEFLAGS} ${UPDATE_TARGET} KEEP_WRKDIR=YES	\
			DEPENDS_TARGET=${DEPENDS_TARGET}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	[ ! -s ${DDIR} ] || for dep in `${CAT} ${DDIR}` ; do		\
		(if cd ../.. && cd "$${dep}" ; then			\
			${ECHO_MSG} "${_PKGSRC_IN}> Installing in $${dep}" && \
			if [ "(" "${RESUMEUPDATE}" = "NO" -o 		\
			     "${REINSTALL}" != "NO" ")" -a		\
			     "${UPDATE_TARGET}" != "replace" ] ; then	\
				${MAKE} ${MAKEFLAGS} deinstall;		\
			fi &&						\
			${MAKE} ${MAKEFLAGS} ${UPDATE_TARGET}		\
				DEPENDS_TARGET=${DEPENDS_TARGET} ;	\
		else							\
			${ECHO_MSG} "${_PKGSRC_IN}> Skipping removed directory $${dep}"; \
		fi) ;							\
	done
.if ${NOCLEAN} == "NO"
	${_PKG_SILENT}${_PKG_DEBUG}					\
		${MAKE} ${MAKEFLAGS} clean-update CLEAR_DIRLIST=YES
.endif


.PHONY: clean-update
clean-update:
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${MAKEFLAGS} ${DDIR}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -s ${DDIR} ] ; then					\
		for dep in `${CAT} ${DDIR}` ; do			\
			(if cd ../.. && cd "$${dep}" ; then		\
				${MAKE} ${MAKEFLAGS} clean ;		\
			else						\
				${ECHO_MSG} "${_PKGSRC_IN}> Skipping removed directory $${dep}";\
			fi) ;						\
		done ;							\
	fi
.if ${CLEAR_DIRLIST} != "NO"
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${MAKEFLAGS} clean
.else
	${_PKG_SILENT}${_PKG_DEBUG}					\
		${MAKE} ${MAKEFLAGS} clean update-dirlist		\
		DIRLIST="`${CAT} ${DDIR}`" PKGLIST="`${CAT} ${DLIST}`"
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO_MSG}				\
		"${_PKGSRC_IN}> Warning: preserved leftover directory list.  Your next";\
		${ECHO_MSG} "${_PKGSRC_IN}>          \`\`${MAKE} update'' may fail.  It is advised to use";\
		${ECHO_MSG} "${_PKGSRC_IN}>          \`\`${MAKE} update REINSTALL=YES'' instead!"
.endif

.endif	# !target(update)


.PHONY: update-dirlist
update-dirlist:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} -p ${WRKDIR}
.ifdef PKGLIST
.  for __tmp__ in ${PKGLIST}
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO} >>${DLIST} "${__tmp__}"
.  endfor
.endif
.ifdef DIRLIST
.  for __tmp__ in ${DIRLIST}
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO} >>${DDIR} "${__tmp__}"
.  endfor
.endif


${DDIR}: ${DLIST}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	ddir=`${SED} 's:-[^-]*$$::' ${DLIST}`;				\
	${ECHO} >${DDIR};						\
	for pkg in $${ddir} ; do					\
		if ${PKG_INFO} -b "$${pkg}" >/dev/null 2>&1 ; then	\
			${PKG_INFO} -b "$${pkg}" | ${SED}	-ne	\
			    's,\([^/]*/[^/]*\)/Makefile:.*,\1,p' | 	\
			    ${HEAD} -1 >>${DDIR};			\
		fi ;							\
	done

${DLIST}: ${WRKDIR}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	{ ${PKG_INFO} -qR "${PKGWILDCARD}" || ${TRUE}; } > ${DLIST}

# The 'info' target can be used to display information about a package.
.PHONY: info
info: uptodate-pkgtools
	${_PKG_SILENT}${_PKG_DEBUG}${PKG_INFO} "${PKGWILDCARD}"

# The 'check' target can be used to check an installed package.
.PHONY: check
check: uptodate-pkgtools
	${_PKG_SILENT}${_PKG_DEBUG}${PKG_ADMIN} check "${PKGWILDCARD}"

# The 'list' target can be used to list the files installed by a package.
.PHONY: list
list: uptodate-pkgtools
	${_PKG_SILENT}${_PKG_DEBUG}${PKG_INFO} -L "${PKGWILDCARD}"

# Run pkglint:
.PHONY: lint
lint:
	${_PKG_SILENT}${_PKG_DEBUG}${LOCALBASE}/bin/pkglint | ${GREP} -v ^OK

# Create a binary package from an install package using "pkg_tarup"
.PHONY: tarup
tarup:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${RM} -f ${PACKAGES}/All/${PKGNAME}${PKG_SUFX};			\
	${SETENV} PKG_DBDIR=${PKG_DBDIR} PKG_SUFX=${PKG_SUFX}		\
		PKGREPOSITORY=${PACKAGES}/All				\
		${LOCALBASE}/bin/pkg_tarup ${PKGNAME};			\
	for CATEGORY in ${CATEGORIES}; do				\
		${MKDIR} ${PACKAGES}/$$CATEGORY;			\
		cd ${PACKAGES}/$$CATEGORY;				\
		${RM} -f ${PKGNAME}${PKG_SUFX};				\
		${LN} -s ../All/${PKGNAME}${PKG_SUFX};			\
	done

# shared code for replace and undo-replace
_REPLACE=								\
	if [ -f ${PKG_DBDIR}/$$oldpkgname/+REQUIRED_BY ]; then		\
		${MV} ${PKG_DBDIR}/$$oldpkgname/+REQUIRED_BY ${WRKDIR}/.req; \
	fi;								\
	${MAKE} deinstall;						\
	$$replace_action;						\
	if [ -f ${WRKDIR}/.req ]; then					\
		${MV} ${WRKDIR}/.req ${PKG_DBDIR}/$$newpkgname/+REQUIRED_BY; \
		for pkg in `${CAT} ${PKG_DBDIR}/$$newpkgname/+REQUIRED_BY`; do \
			${SETENV} NEWPKGNAME=$$newpkgname		\
				${AWK} '/^@pkgdep '$$oldpkgname'/ { print "@pkgdep " ENVIRON["NEWPKGNAME"]; next } { print }' \
				< ${PKG_DBDIR}/$$pkg/+CONTENTS > ${PKG_DBDIR}/$$pkg/+CONTENTS.$$$$ && \
			${MV} ${PKG_DBDIR}/$$pkg/+CONTENTS.$$$$ ${PKG_DBDIR}/$$pkg/+CONTENTS; \
		done;							\
	fi

# replace a package in place - not for the faint-hearted
.PHONY: real-su-replace
real-su-replace:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${ECHO_MSG} "*** WARNING - experimental target - data loss may be experienced ***"; \
	if [ -x ${LOCALBASE}/bin/pkg_tarup ]; then			\
		${SETENV} PKGREPOSITORY=${WRKDIR} ${LOCALBASE}/bin/pkg_tarup ${PKGBASE}; \
	else								\
		${ECHO} "No ${LOCALBASE}/bin/pkg_tarup binary - can't pkg_tarup ${PKGBASE}"; \
		exit 1;							\
	fi
	${_PKG_SILENT}${_PKG_DEBUG}					\
	oldpkgname=`${PKG_INFO} -e "${PKGBASE}"`;			\
	newpkgname=${PKGNAME};						\
	${ECHO} "$$oldpkgname" > ${WRKDIR}/.replace;			\
	replace_action="${MAKE} install";				\
	${_REPLACE}

# undo the replacement of a package - not for the faint-hearted either
.PHONY: real-su-undo-replace
real-su-undo-replace:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ ! -f ${WRKDIR}/.replace ]; then				\
		${ECHO_MSG} "No replacement to undo";			\
		exit 1;							\
	fi
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${ECHO_MSG} "*** WARNING - experimental target - data loss may be experienced ***"; \
	oldpkgname=${PKGNAME};						\
	newpkgname=`${CAT} ${WRKDIR}/.replace`;				\
	replace_action="${SETENV} ${PKG_ADD} ${WRKDIR}/$$newpkgname${PKG_SUFX}"; \
	${_REPLACE};							\
	${RM} ${WRKDIR}/.replace

# This is for the use of sites which store distfiles which others may
# fetch - only fetch the distfile if it is allowed to be
# re-distributed freely
.PHONY: mirror-distfiles
mirror-distfiles:
.if !defined(NO_SRC_ON_FTP)
	@${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${MAKEFLAGS} fetch NO_SKIP=yes NO_CHECK_DEPENDS=yes
.endif


# Cleaning up

.PHONY: pre-clean
.if !target(pre-clean)
pre-clean:
	@${DO_NADA}
.endif

.PHONY: clean
.if !target(clean)
clean: pre-clean
.  if (${CLEANDEPENDS} != "NO") && (defined(BUILD_DEPENDS) || defined(DEPENDS))
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${MAKEFLAGS} clean-depends
.  endif
	@${ECHO_MSG} "${_PKGSRC_IN}> Cleaning for ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -d ${WRKDIR} ]; then					\
		if [ -w ${WRKDIR} ]; then				\
			${RM} -rf ${WRKDIR};				\
		else							\
			${ECHO_MSG} "${_PKGSRC_IN}> ${WRKDIR} not writable, skipping"; \
		fi;							\
	fi
.  ifdef WRKOBJDIR
	-${_PKG_SILENT}${_PKG_DEBUG}					\
	${RMDIR} ${BUILD_DIR} 2>/dev/null;				\
	${RM} -f ${WRKDIR_BASENAME}
.  endif
.endif


.PHONY: clean-depends
.if !target(clean-depends)
clean-depends:
.  if defined(BUILD_DEPENDS) || defined(DEPENDS)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for i in `${MAKE} ${MAKEFLAGS} CLEAN_DEPENDS_LIST_TOP=YES clean-depends-list | ${SED} -e 's;\.\./[^ ]*; ;g' | ${TR} -s "[:space:]" "\n" | ${SORT} -u` ;\
	do 								\
		cd ${.CURDIR}/../../$$i &&				\
		${MAKE} ${MAKEFLAGS} CLEANDEPENDS=NO clean;		\
	done
.  endif
.endif


# The clean-depends-list target will produce a list of all
# BUILD_DEPENDS and DEPENDS packages.
# As each *DEPENDS package is visited, it is added to the
# CLEAN_DEPENDS_LIST_SEEN variable.  Once a pkg is in the list
# it will not be visited again.  This prevents traversing the same
# part of the dependency tree multiple times.  Each depending package
# ends up in the list twice.  Once as the relative path from the depending
# package and once as the path from pkgsrc.  Eg, "../../foo/bar foo/bar"
# The "../../foo/bar" version is later removed from the list in the
# clean-depends target.  The remaining bit of redundancy is that some
# packages list their depends as "../bar" instead of "../../foo/bar"
# In this case its possible for a dependency to be visited twice.

.PHONY: clean-depends-list
.if !target(clean-depends-list)
clean-depends-list:
.  if defined(BUILD_DEPENDS) || defined(DEPENDS)
	@for dir in `${ECHO} ${BUILD_DEPENDS:C/^[^:]*://:C/:.*//}	\
			${DEPENDS:C/^[^:]*://:C/:.*//} |		\
			${TR} '\040' '\012' `; do			\
		case "$$CLEAN_DEPENDS_LIST_SEEN" in			\
		*" "$$dir" "*)  ;; 					\
		*) 							\
			CLEAN_DEPENDS_LIST_SEEN=" $$dir `cd ${.CURDIR} ; cd $$dir && ${MAKE} ${MAKEFLAGS} CLEAN_DEPENDS_LIST_SEEN="$$CLEAN_DEPENDS_LIST_SEEN" CLEAN_DEPENDS_LIST_TOP=NO clean-depends-list`";\
			;;						\
		esac							\
	done ;								\
	if [ "${CLEAN_DEPENDS_LIST_TOP}" != "YES" ]; then		\
		${ECHO} " ${PKGPATH} $$CLEAN_DEPENDS_LIST_SEEN";	\
	else								\
		${ECHO} " $$CLEAN_DEPENDS_LIST_SEEN";			\
	fi
.  else
	@if [ "${CLEAN_DEPENDS_LIST_TOP}" != "YES" ]; then		\
		${ECHO} " ${PKGPATH} $$CLEAN_DEPENDS_LIST_SEEN";	\
	else								\
		${ECHO} " $$CLEAN_DEPENDS_LIST_SEEN";			\
	fi
.  endif
.endif

.PHONY: pre-distclean
.if !target(pre-distclean)
pre-distclean:
	@${DO_NADA}
.endif


.PHONY: cleandir
.if !target(cleandir)
cleandir: clean
.endif


.PHONY: distclean
.if !target(distclean)
distclean: pre-distclean clean
	${_PKG_SILENT}${ECHO_MSG} "${_PKGSRC_IN}> Dist cleaning for ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}if [ -d ${_DISTDIR} ]; then		\
		cd ${_DISTDIR} &&					\
		${TEST} -z "${DISTFILES}" || ${RM} -f ${DISTFILES};	\
		${TEST} -z "${PATCHFILES}" || ${RM} -f ${PATCHFILES};	\
	fi
.  if defined(DIST_SUBDIR) && exists(DIST_SUBDIR)
	-${_PKG_SILENT}${_PKG_DEBUG}${RMDIR} ${_DISTDIR}
.  endif
	-${_PKG_SILENT}${_PKG_DEBUG}${RM} -f README.html
.endif

# Prints out a script to fetch all needed files (no checksumming).
.PHONY: fetch-list
.if !target(fetch-list)

fetch-list:
	@${ECHO} '#!/bin/sh'
	@${ECHO} '#'
	@${ECHO} '# This is an auto-generated script, the result of running'
	@${ECHO} '# `${MAKE} fetch-list'"'"' in directory "'"`${PWD_CMD}`"'"'
	@${ECHO} '# on host "'"`${UNAME} -n`"'" on "'"`date`"'".'
	@${ECHO} '#'
	@${MAKE} ${MAKEFLAGS} fetch-list-recursive
.endif # !target(fetch-list)

.PHONY: fetch-list-recursive
.if !target(fetch-list-recursive)

fetch-list-recursive:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for dir in `${MAKE} ${MAKEFLAGS} show-all-depends-dirs`; do	\
		(cd ../../$$dir &&					\
		${MAKE} ${MAKEFLAGS} fetch-list-one-pkg			\
		| ${AWK} '						\
		/^[^#]/ { FoundSomething = 1 }				\
		/^unsorted/ { gsub(/[[:space:]]+/, " \\\n\t") }		\
		/^echo/ { gsub(/;[[:space:]]+/, "\n") }			\
		{ block[line_c++] = $$0 }				\
		END { if (FoundSomething)				\
			for (line = 0; line < line_c; line++)		\
				print block[line] }			\
		')							\
	done
.endif # !target(fetch-list-recursive)

.PHONY: fetch-list-one-pkg
.if !target(fetch-list-one-pkg)

fetch-list-one-pkg:
.  if !empty(_ALLFILES)
	@${ECHO}
	@${ECHO} '#'
	@location=`${PWD_CMD} | ${AWK} -F / '{ print $$(NF-1) "/" $$NF }'`; \
		${ECHO} '# Need additional files for ${PKGNAME} ('$$location')...'
	@${ECHO} '#'
	@${MKDIR} ${_DISTDIR}
.    for fetchfile in ${_ALLFILES}
.      if defined(_FETCH_MESSAGE)
	@(cd ${_DISTDIR};						\
	if [ ! -f ${fetchfile:T} ]; then				\
		${ECHO};						\
		filesize=`${AWK} '					\
			/^Size/ && $$2 == "(${fetchfile})" { print $$4 } \
			' ${DISTINFO_FILE}` || true;			\
		${ECHO} '# Prompt user to get ${fetchfile} ('$${filesize-???}' bytes) manually:'; \
		${ECHO} '#';						\
		${ECHO} ${_FETCH_MESSAGE:Q};				\
	fi)
.      elif defined(DYNAMIC_MASTER_SITES)
	@(cd ${_DISTDIR};						\
	if [ ! -f ${fetchfile:T} ]; then				\
		${ECHO};						\
		filesize=`${AWK} '					\
			/^Size/ && $$2 == "(${fetchfile})" { print $$4 } \
			' ${DISTINFO_FILE}` || true;			\
		${ECHO} '# Fetch ${fetchfile} ('$${filesize-???}' bytes):'; \
		${ECHO} '#';						\
		${ECHO} '${SH} -s ${fetchfile:T} <<"EOF" |(';		\
		${CAT} ${FILESDIR}/getsite.sh;				\
		${ECHO} EOF;						\
		${ECHO} read unsorted_sites;				\
		${ECHO} 'unsorted_sites="$${unsorted_sites} ${_MASTER_SITE_BACKUP}"'; \
		${ECHO} sites='"'${ORDERED_SITES:Q}'"';			\
		${ECHO} "${MKDIR} ${_DISTDIR}";				\
		${ECHO} 'cd ${_DISTDIR} && [ -f ${fetchfile} -o -f ${fetchfile:T} ] ||'; \
		${ECHO}	'for site in $$sites; do';			\
		${ECHO} '	${FETCH_CMD} ${FETCH_BEFORE_ARGS} "$${site}${fetchfile:T}" ${FETCH_AFTER_ARGS} && break ||'; \
		${ECHO} '	${ECHO} ${fetchfile} not fetched';	\
		${ECHO}	done;						\
		${ECHO} ')';						\
	fi)
.      else
	@(cd ${_DISTDIR};						\
	if [ ! -f ${fetchfile:T} ]; then				\
		${ECHO};						\
		filesize=`${AWK} '					\
			/^Size/ && $$2 == "(${fetchfile})" { print $$4 } \
			' ${DISTINFO_FILE}` || true;			\
		${ECHO} '# Fetch ${fetchfile} ('$${filesize-???}' bytes):'; \
		${ECHO} '#';						\
		${ECHO} 'unsorted_sites="${SITES_${fetchfile:T:S/=/--/}} ${_MASTER_SITE_BACKUP}"'; \
		${ECHO} sites='"'${ORDERED_SITES:Q}'"';			\
		${ECHO} "${MKDIR} ${_DISTDIR}";				\
		${ECHO} 'cd ${_DISTDIR} && [ -f ${fetchfile} -o -f ${fetchfile:T} ] ||'; \
		${ECHO}	'for site in $$sites; do';			\
		${ECHO} '	${FETCH_CMD} ${FETCH_BEFORE_ARGS} "$${site}${fetchfile:T}" ${FETCH_AFTER_ARGS} && break ||'; \
		${ECHO} '	${ECHO} ${fetchfile} not fetched';	\
		${ECHO}	done;						\
	fi)
.      endif # defined(_FETCH_MESSAGE) || defined(DYNAMIC_MASTER_SITES)
.    endfor
.  endif # !empty(_ALLFILES)
.endif # !target(fetch-list-one-pkg)

# Checksumming utilities

.PHONY: makesum
.if !target(makesum)
makesum: fetch uptodate-digest
	${_PKG_SILENT}${_PKG_DEBUG}					\
	newfile=${DISTINFO_FILE}.$$$$;					\
	if [ -f ${DISTINFO_FILE} ]; then				\
		${GREP} '^.NetBSD' ${DISTINFO_FILE} > $$newfile ||	\
			(${ECHO} -n "$$" > $$newfile &&			\
			 ${ECHO} -n "NetBSD" >> $$newfile && 		\
			 ${ECHO} "$$" >> $$newfile)			\
	else								\
		${ECHO} -n "$$" > $$newfile;				\
		${ECHO} -n "NetBSD" >> $$newfile; 			\
		${ECHO} "$$" >> $$newfile;				\
	fi;								\
	${ECHO} "" >> $$newfile;					\
	cd ${DISTDIR};							\
	for sumfile in "" ${_CKSUMFILES}; do				\
		if [ "X$$sumfile" = "X" ]; then continue; fi;		\
		${DIGEST} ${DIGEST_ALGORITHM} $$sumfile >> $$newfile;	\
		${WC} -c $$sumfile | ${AWK} '{ print "Size (" $$2 ") = " $$1 " bytes" }' >> $$newfile; \
	done;								\
	for ignore in "" ${_IGNOREFILES}; do				\
		if [ "X$$ignore" = "X" ]; then continue; fi;		\
		${ECHO} "${DIGEST_ALGORITHM} ($$ignore) = IGNORE" >> $$newfile; \
	done;								\
	if [ -f ${DISTINFO_FILE} ]; then				\
		${AWK} '$$2 ~ /\(patch-[a-z0-9]+\)/ { print $$0 }' < ${DISTINFO_FILE} >> $$newfile; \
	fi;								\
	if ${CMP} -s $$newfile ${DISTINFO_FILE}; then			\
		${RM} -f $$newfile;					\
		${ECHO_MSG} "=> distinfo: distfiles part unchanged.";	\
	else								\
		${MV} $$newfile ${DISTINFO_FILE};			\
	fi
.endif

.if !target(makepatchsum)
makepatchsum mps: uptodate-digest
	${_PKG_SILENT}${_PKG_DEBUG}					\
	newfile=${DISTINFO_FILE}.$$$$;					\
	if [ -f ${DISTINFO_FILE} ]; then				\
		${AWK} '$$2 !~ /\(patch-[a-z0-9]+\)/ { print $$0 }' < ${DISTINFO_FILE} >> $$newfile; \
	else \
		${ECHO} -n "$$" > $$newfile;				\
		${ECHO} -n "NetBSD" >> $$newfile; 			\
		${ECHO} "$$" >> $$newfile;				\
		${ECHO} "" >> $$newfile;				\
	fi;								\
	if [ -d ${PATCHDIR} ]; then					\
		(cd ${PATCHDIR};					\
		for sumfile in "" patch-*; do				\
			if [ "X$$sumfile" = "X" ]; then continue; fi;	\
			if [ "X$$sumfile" = "Xpatch-*" ]; then break; fi; \
			case $$sumfile in				\
				patch-local-*) ;;			\
				*.orig|*.rej|*~) continue ;;		\
				*)	${ECHO} "${DIGEST_ALGORITHM} ($$sumfile) = `${SED} -e '/\$$NetBSD.*/d' $$sumfile | ${DIGEST} ${DIGEST_ALGORITHM}`" >> $$newfile;; \
			esac;						\
		done);							\
	fi;								\
	if ${CMP} -s $$newfile ${DISTINFO_FILE}; then			\
		${RM} -f $$newfile;					\
		${ECHO_MSG} "=> distinfo: patches part unchanged.";	\
	else								\
		${MV} $$newfile ${DISTINFO_FILE};			\
	fi
.endif

# This target is done by invoking a sub-make so that DISTINFO_FILE gets
# re-evaluated after the "makepatchsum" target is made. This can be
# made into:
#makedistinfo mdi: makepatchsum makesum
# once a combined distinfo file exists for all packages
.if !target(makedistinfo)
makedistinfo mdi distinfo: makepatchsum
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} makesum
.endif

.PHONY: checksum
.if !target(checksum)
checksum: fetch uptodate-digest
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ ! -f ${DISTINFO_FILE} ]; then				\
		${ECHO_MSG} "=> No checksum file.";			\
	else								\
		(cd ${DISTDIR}; OK="true";				\
		  for file in "" ${_CKSUMFILES}; do			\
		  	if [ "X$$file" = X"" ]; then continue; fi; 	\
			alg=`${AWK} 'NF == 4 && $$2 == "('$$file')" && $$3 == "=" {print $$1;}' ${DISTINFO_FILE}`; \
			if [ "X$$alg" = "X" ]; then			\
				${ECHO_MSG} "=> No checksum recorded for $$file."; \
				OK="false";				\
			else						\
				CKSUM=`${DIGEST} $$alg < $$file`;	\
				CKSUM2=`${AWK} '$$1 == "'$$alg'" && $$2 == "('$$file')"{print $$4;}' ${DISTINFO_FILE}`; \
				if [ "$$CKSUM2" = "IGNORE" ]; then	\
					${ECHO_MSG} "=> Checksum for $$file is set to IGNORE in checksum file even though"; \
					${ECHO_MSG} "   the file is not in the "'$$'"{IGNOREFILES} list."; \
					OK="false";			\
				elif [ "$$CKSUM" = "$$CKSUM2" ]; then	\
					${ECHO_MSG} "=> Checksum OK for $$file."; \
				else					\
					${ECHO_MSG} "=> Checksum mismatch for $$file."; \
					OK="false";			\
				fi;					\
			fi;						\
		  done;							\
		  for file in "" ${_IGNOREFILES}; do			\
		  	if [ "X$$file" = X"" ]; then continue; fi; 	\
			CKSUM2=`${AWK} 'NF == 4 && $$3 == "=" && $$2 == "('$$file')"{print $$4;}' ${DISTINFO_FILE}`; \
			if [ "$$CKSUM2" = "" ]; then			\
				${ECHO_MSG} "=> No checksum recorded for $$file, file is in "'$$'"{IGNOREFILES} list."; \
				OK="false";				\
			elif [ "$$CKSUM2" != "IGNORE" ]; then		\
				${ECHO_MSG} "=> Checksum for $$file is not set to IGNORE in checksum file even though"; \
				${ECHO_MSG} "   the file is in the "'$$'"{IGNOREFILES} list."; \
				OK="false";				\
			fi;						\
		  done;							\
		  if [ "$$OK" != "true" ]; then				\
			${ECHO_MSG} "Make sure the Makefile and checksum file (${DISTINFO_FILE})"; \
			${ECHO_MSG} "are up to date.  If you want to override this check, type"; \
			${ECHO_MSG} "\"${MAKE} NO_CHECKSUM=yes [other args]\"."; \
			exit 1;						\
		  fi) ;							\
	fi
.endif



# List of sites carrying binary pkgs. Variables "rel" and "arch" are
# replaced with OS release ("1.5", ...) and architecture ("mipsel", ...)
BINPKG_SITES?= \
	ftp://ftp.netbsd.org/pub/NetBSD/packages/$${rel}/$${arch}

# List of flags to pass to pkg_add(8) for bin-install:
BIN_INSTALL_FLAGS?= 	# -v

# Install binary pkg, without strict uptodate-check first
.PHONY: bin-install
bin-install:
	@found="`${PKG_INFO} -e \"${PKGWILDCARD}\" || ${TRUE}`";	\
	if [ "$$found" != "" ]; then					\
		${ECHO_MSG} "${_PKGSRC_IN}>  $$found is already installed - perhaps an older version?"; \
		${ECHO_MSG} "*** If so, you may wish to \`\`pkg_delete $$found'' and install"; \
		${ECHO_MSG} "*** this package again by \`\`${MAKE} bin-install'' to upgrade it properly."; \
		${SHCOMMENT} ${ECHO_MSG} "*** or use \`\`${MAKE} bin-update'' to upgrade it and all of its dependencies."; \
		exit 1;							\
	fi
	@if [ -f ${PKGFILE} ] ; then 					\
		${ECHO_MSG} "Installing from binary pkg ${PKGFILE}" ;	\
		${PKG_ADD} ${PKGFILE} ; 				\
	else 				 				\
		rel=`${UNAME} -r | ${SED} 's@\.\([0-9]*\)[\._].*@\.\1@'`; \
		arch=${MACHINE_ARCH}; 					\
		for site in ${BINPKG_SITES} ; do 			\
			${ECHO} Trying `eval ${ECHO} $$site`/All ; 	\
			${SHCOMMENT} ${ECHO} ${SETENV} PKG_PATH="`eval ${ECHO} $$site`/All" ${PKG_ADD} ${BIN_INSTALL_FLAGS} ${PKGNAME}${PKG_SUFX} ; \
			if ${SETENV} PKG_PATH="`eval ${ECHO} $$site`/All" ${PKG_ADD} ${BIN_INSTALL_FLAGS} ${PKGNAME}${PKG_SUFX} ; then \
				${ECHO} "${PKGNAME} successfully installed."; \
				break ; 				\
			fi ; 						\
		done ; 							\
		if ! ${PKG_INFO} -qe "${PKGNAME}" ; then 		\
			${SHCOMMENT} Cycle through some FTP server here ;\
			${ECHO_MSG} "Installing from source" ;		\
			${MAKE} ${MAKEFLAGS} package 			\
				DEPENDS_TARGET=${DEPENDS_TARGET} &&	\
			${MAKE} ${MAKEFLAGS} clean ;			\
		fi ; \
	fi


################################################################
# The special package-building targets
# You probably won't need to touch these
################################################################

# Set to "html" by the README.html target to generate HTML code,
# or to "svr4" to print SVR4 (Solaris, ...) short package names, from
# SVR4_PKGNAME variable.
# This variable is passed down via build-depends-list and run-depends-list
PACKAGE_NAME_TYPE?=	name

# Nobody should want to override this unless PKGNAME is simply bogus.
HTML_PKGNAME=<a href="../../${PKGPATH:S/&/\&amp;/g:S/>/\&gt;/g:S/</\&lt;/g}/README.html">${PKGNAME:S/&/\&amp;/g:S/>/\&gt;/g:S/</\&lt;/g}</A>

.PHONY: package-name
.if !target(package-name)
package-name:
.  if (${PACKAGE_NAME_TYPE} == "html")
	@${ECHO} '<a href="../../${PKGPATH:S/&/\&amp;/g:S/>/\&gt;/g:S/</\&lt;/g}/README.html">${PKGNAME:S/&/\&amp;/g:S/>/\&gt;/g:S/</\&lt;/g}</A>'
.  elif (${PACKAGE_NAME_TYPE} == "svr4")
	@${ECHO} ${SVR4_PKGNAME}
.  else
	@${ECHO} ${PKGNAME}
.  endif # PACKAGE_NAME_TYPE
.endif # !target(package-name)

.PHONY: make-readme-html-help
.if !target(make-readme-html-help)
make-readme-html-help:
	@${ECHO} '${PKGNAME:S/&/\&amp;/g:S/>/\&gt;/g:S/</\&lt;/g}</a>: <TD>'${COMMENT:S/&/\&amp;/g:S/>/\&gt;/g:S/</\&lt;/g:Q}
.endif # !target(make-readme-html-help)

# Show (recursively) all the packages this package depends on.
# If PACKAGE_DEPENDS_WITH_PATTERNS is set, print as pattern (if possible)
PACKAGE_DEPENDS_WITH_PATTERNS?=true
# To be used (-> true) ONLY if the pkg in question is known to be installed
# (i.e. when calling for pkg_create args, and for fake-pkg)
# Will probably not work with PACKAGE_DEPENDS_WITH_PATTERNS=false ...
PACKAGE_DEPENDS_QUICK?=false
.PHONY: run-depends-list
.if !target(run-depends-list)
run-depends-list:
.  for dep in ${DEPENDS}
	@pkg="${dep:C/:.*//}";						\
	dir="${dep:C/[^:]*://}";					\
	cd ${.CURDIR};							\
	if ${PACKAGE_DEPENDS_WITH_PATTERNS}; then			\
		${ECHO} "$$pkg";					\
	else								\
		if cd $$dir 2>/dev/null; then				\
			${MAKE} ${MAKEFLAGS} package-name PACKAGE_NAME_TYPE=${PACKAGE_NAME_TYPE}; \
		else 							\
			${ECHO_MSG} "Warning: \"$$dir\" non-existent -- @pkgdep registration incomplete" >&2; \
		fi;							\
	fi;								\
	if ${PACKAGE_DEPENDS_QUICK}; then 				\
		${PKG_INFO} -qf "$$pkg" | ${AWK} '/^@pkgdep/ {print $$2}'; \
	else 								\
		if cd $$dir 2>/dev/null; then				\
			${MAKE} ${MAKEFLAGS} run-depends-list PACKAGE_NAME_TYPE=${PACKAGE_NAME_TYPE} PACKAGE_DEPENDS_WITH_PATTERNS=${PACKAGE_DEPENDS_WITH_PATTERNS}; \
		else 							\
			${ECHO_MSG} "Warning: \"$$dir\" non-existent -- @pkgdep registration incomplete" >&2; \
		fi;							\
	fi
.  endfor
.endif # target(run-depends-list)

# Build a package but don't check the package cookie

.PHONY: repackage
.if !target(repackage)
repackage: pre-repackage package

.PHONY: pre-repackage
pre-repackage:
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${PACKAGE_COOKIE}
.endif

# Build a package but don't check the cookie for installation, also don't
# install package cookie

.PHONY: package-noinstall
.if !target(package-noinstall)
package-noinstall:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} PACKAGE_NOINSTALL=yes real-package
.endif

################################################################
# Dependency checking
################################################################

.PHONY: install-depends
.if !target(install-depends)
# Tells whether to halt execution if the object formats differ
FATAL_OBJECT_FMT_SKEW?= yes
WARN_NO_OBJECT_FMT?= yes

install-depends: uptodate-pkgtools
.  if defined(DEPENDS) || defined(BUILD_DEPENDS)
.    if defined(NO_DEPENDS)
	@${DO_NADA}
.    else	# !DEPENDS
.      for dep in ${DEPENDS} ${BUILD_DEPENDS}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	pkg="${dep:C/:.*//}";						\
	dir="${dep:C/[^:]*://:C/:.*$//}";				\
	found=`${PKG_INFO} -e "$$pkg" || ${TRUE}`;			\
	if [ "X$$REBUILD_DOWNLEVEL_DEPENDS" != "X" ]; then		\
		pkgname=`cd $$dir ; ${MAKE} ${MAKEFLAGS} show-var VARNAME=PKGNAME`; \
		if [ "X$$found" != "X" -a "X$$found" != "X$${pkgname}" ]; then \
			${ECHO_MSG} "ignoring old installed package \"$$found\""; \
			found="";					\
		fi;							\
	fi;								\
	if [ "$$found" != "" ]; then					\
		instobjfmt=`${PKG_INFO} -B "$$pkg" | ${AWK} -F'=[ \t]*' '/^OBJECT_FMT/ {print $$2; exit}'`; \
		if [ "$$instobjfmt" = "" ]; then			\
			if [ "X${WARN_NO_OBJECT_FMT}" != "Xno" ]; then	\
				${ECHO} "WARNING: Unknown object format for installed package $$pkg - continuing"; \
			fi;						\
		elif [ "$$instobjfmt" != "${OBJECT_FMT}" ]; then	\
			${ECHO} "Installed package $$pkg is an $$instobjfmt package."; \
			${ECHO} "You are building an ${OBJECT_FMT} package, which will not inter-operate."; \
			${ECHO} "Please update the $$pkg package to ${OBJECT_FMT}"; \
			if [ "X${FATAL_OBJECT_FMT_SKEW}" != "Xno" ]; then \
				exit 1;					\
			fi;						\
		fi;							\
		if [ `${ECHO} $$found | ${WC} -w` -gt 1 ]; then		\
			${ECHO} '***' "WARNING: Dependency on '$$pkg' expands to several installed packages " ; \
			${ECHO} "    (" `${ECHO} $$found` ")." ; 	\
			${ECHO} "    Please check if this is really intended!" ; \
		else 							\
			${ECHO_MSG} "${_PKGSRC_IN}> Required installed package $$pkg: $${found} found"; \
		fi ; 							\
	else								\
		${ECHO_MSG} "${_PKGSRC_IN}> Required package $$pkg: NOT found"; \
		target=${DEPENDS_TARGET};				\
		${ECHO_MSG} "${_PKGSRC_IN}> Verifying $$target for $$dir"; 	\
		if [ ! -d $$dir ]; then					\
			${ECHO_MSG} "=> No directory for $$dir.  Skipping.."; \
		else							\
			cd $$dir ;					\
			${MAKE} ${MAKEFLAGS} $$target _PKGSRC_DEPS=", ${PKGNAME}${_PKGSRC_DEPS}" PKGNAME_REQD=$$pkg; \
			${ECHO_MSG} "${_PKGSRC_IN}> Returning to build of ${PKGNAME}"; \
		fi;							\
	fi
.      endfor	# DEPENDS
.    endif	# !NO_DEPENDS
.  endif	# DEPENDS

.endif

.PHONY: build-depends-list
.if !target(build-depends-list)
build-depends-list:
	@for dir in `${MAKE} ${MAKEFLAGS} show-all-depends-dirs-excl`;	\
	do								\
		(cd ../../$$dir &&					\
		${MAKE} ${MAKEFLAGS} package-name)			\
	done
.endif

# If PACKAGES is set to the default (../../pkgsrc/packages), the current
# ${MACHINE_ARCH} and "release" (uname -r) will be used. Otherwise a directory
# structure of ...pkgsrc/packages/`uname -r`/${MACHINE_ARCH} is assumed.
# The PKG_URL is set from FTP_PKG_URL_* or CDROM_PKG_URL_*, depending on
# the target used to generate the README.html file.
.PHONY: binpkg-list
.if !target(binpkg-list)
binpkg-list:
	@if [ -e ${PACKAGES} ]; then					\
		cd ${PACKAGES};						\
		case ${.CURDIR} in					\
		*/pkgsrc/packages)					\
			for pkg in ${PKGREPOSITORYSUBDIR}/${PKGWILDCARD}${PKG_SUFX} ; \
			do 						\
				if [ -f "$$pkg" ] ; then		\
					pkgname=`${ECHO} $$pkg | ${SED} 's@.*/@@'`; \
					${ECHO} "<TR><TD>${MACHINE_ARCH}:<TD><a href=\"${PKG_URL}/$$pkg\">$$pkgname</a><TD>(${OPSYS} ${OS_VERSION})"; \
				fi ;					\
			done ; 						\
			;;						\
		*)							\
			cd ${PACKAGES}/../..;				\
			for i in [1-9].*/*; do  			\
				if cd ${PACKAGES}/../../$$i/${PKGREPOSITORYSUBDIR} 2>/dev/null; then \
					for j in ${PKGWILDCARD}${PKG_SUFX}; \
					do 				\
						if [ -f "$$j" ]; then	\
							${ECHO} $$i/$$j;\
						fi;			\
					done; 				\
				fi; 					\
			done | ${AWK} -F/ '				\
				{					\
					release = $$1;			\
					arch = $$2; 			\
					pkg = $$3;			\
					gsub("\.tgz","", pkg);		\
					if (arch != "m68k" && arch != "mipsel") { \
						if (arch in urls)	\
							urls[arch "/" pkg "/" release] = "<a href=\"${PKG_URL}/" release "/" arch "/${PKGREPOSITORYSUBDIR}/" pkg "${PKG_SUFX}\">" pkg "</a>, " urls[arch]; \
						else			\
							urls[arch "/" pkg "/" release] = "<a href=\"${PKG_URL}/" release "/" arch "/${PKGREPOSITORYSUBDIR}/" pkg "${PKG_SUFX}\">" pkg "</a> "; \
					}				\
				} 					\
				END { 					\
					for (av in urls) {		\
						split(av, ava, "/");	\
						arch=ava[1];		\
						pkg=ava[2];		\
						release=ava[3];		\
						print "<TR><TD>" arch ":<TD>" urls[av] "<TD>(${OPSYS} " release ")"; \
					}				\
				}' | ${SORT}				\
			;;						\
		esac;							\
	fi
.endif

################################################################
# Everything after here are internal targets and really
# shouldn't be touched by anybody but the release engineers.
################################################################

# This target generates an index entry suitable for aggregation into
# a large index.  Format is:
#
# distribution-name|package-path|installation-prefix|comment| \
#  description-file|maintainer|categories|build deps|run deps|for arch| \
#  not for opsys
#
.PHONY: describe
.if !target(describe)
describe:
	@${ECHO} -n "${PKGNAME}|${.CURDIR}|";				\
	${ECHO} -n "${PREFIX}|";					\
	${ECHO} -n ${COMMENT:Q};					\
	if [ -f ${DESCR_SRC} ]; then					\
		${ECHO} -n "|${DESCR_SRC}";				\
	else								\
		${ECHO} -n "|/dev/null";				\
	fi;								\
	${ECHO} -n "|${MAINTAINER}|${CATEGORIES}|";			\
	case "A${BUILD_DEPENDS}B${DEPENDS}C" in	\
		ABC) ;;							\
		*) cd ${.CURDIR} && ${ECHO} -n `${MAKE} ${MAKEFLAGS} build-depends-list | ${SORT} -u`;; \
	esac;								\
	${ECHO} -n "|";							\
	if [ "${DEPENDS}" != "" ]; then				\
		cd ${.CURDIR} && ${ECHO} -n `${MAKE} ${MAKEFLAGS} run-depends-list | ${SORT} -u`; \
	fi;								\
	${ECHO} -n "|";							\
	if [ "${ONLY_FOR_ARCHS}" = "" ]; then				\
		${ECHO} -n "any";					\
	else								\
		${ECHO} -n "${ONLY_FOR_ARCHS}";				\
	fi;								\
	${ECHO} -n "|";							\
	if [ "${NOT_FOR_OPSYS}" = "" ]; then				\
		${ECHO} -n "any";					\
	else								\
		${ECHO} -n "not ${NOT_FOR_OPSYS}";			\
	fi;								\
	${ECHO} ""
.endif

.PHONY: readmes
.if !target(readmes)
readmes:	readme
.endif

# This target is used to generate README.html files
.PHONY: readme
.if !target(readme)
FTP_PKG_URL_HOST?=	ftp://ftp.netbsd.org
FTP_PKG_URL_DIR?=	/pub/NetBSD/packages

readme:
	@cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} README.html PKG_URL=${FTP_PKG_URL_HOST}${FTP_PKG_URL_DIR}
.endif

# This target is used to generate README.html files, very like "readme"
# However, a different target was used for ease of use.
.PHONY: cdrom-readme
.if !target(cdrom-readme)
CDROM_PKG_URL_HOST?=	file://localhost
CDROM_PKG_URL_DIR?=	/usr/pkgsrc/packages

cdrom-readme:
	@cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} README.html PKG_URL=${CDROM_PKG_URL_HOST}${CDROM_PKG_URL_DIR}
.endif

README_NAME=	${TEMPLATES}/README.pkg

# set up the correct license information as a sed expression
.ifdef LICENSE
SED_LICENSE_EXPR=       -e 's|%%LICENSE%%|<p>Please note that this package has a ${LICENSE} license.</p>|'
.else
SED_LICENSE_EXPR=       -e 's|%%LICENSE%%||'
.endif

# set up the "more info URL" information as a sed expression
.ifdef HOMEPAGE
SED_HOMEPAGE_EXPR=       -e 's|%%HOMEPAGE%%|<p>This package has a home page at <a HREF="${HOMEPAGE}">${HOMEPAGE}</a>.</p>|'
.else
SED_HOMEPAGE_EXPR=       -e 's|%%HOMEPAGE%%||'
.endif

.PHONY: show-vulnerabilities-html
show-vulnerabilities-html:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -f ${PKGVULNDIR}/vulnerabilities ]; then			\
		${AWK} '/^${PKGBASE}[-<>=]+[0-9]/ { gsub("\<", "\\&lt;", $$1);	\
			 gsub("\>", "\\&gt;", $$1);			\
			 printf("<LI><STRONG>%s has a %s exploit (see <a href=\"%s\">%s</a> for more details)</STRONG></LI>\n", $$1, $$2, $$3, $$3) }' \
			${PKGVULNDIR}/vulnerabilities;			\
	fi


# If PACKAGES is set to the default (../../packages), the current
# ${MACHINE_ARCH} and "release" (uname -r) will be used. Otherwise a directory
# structure of ...pkgsrc/packages/`uname -r`/${MACHINE_ARCH} is assumed.
# The PKG_URL is set from FTP_PKG_URL_* or CDROM_PKG_URL_*, depending on
# the target used to generate the README.html file.
.PHONY: README.html
README.html: .PRECIOUS
	@${SETENV} AWK=${AWK} BMAKE=${MAKE} ../../mk/scripts/mkdatabase -f $@.tmp1
	@if [ -e ${PACKAGES} ]; then					\
		cd ${PACKAGES};						\
		case `${PWD_CMD}` in					\
			${_PKGSRCDIR}/packages)				\
				MULTIARCH=no;				\
				;;					\
			*)						\
				MULTIARCH=yes;				\
				;;					\
		esac;							\
		cd ${.CURDIR} ;						\
	fi;								\
	${AWK} -f ../../mk/scripts/genreadme.awk \
		builddependsfile=/dev/null \
		dependsfile=/dev/null \
		DISTDIR=${DISTDIR} \
		MACHINE_ARCH=${MACHINE_ARCH} \
		MULTIARCH=$$MULTIARCH \
		OPSYS=${OPSYS} \
		OS_VERSION=${OS_VERSION} \
		PACKAGES=${PACKAGES} \
		PKG_SUFX=${PKG_SUFX} \
		PKG_URL=${PKG_URL} \
		PKGREPOSITORYSUBDIR=${PKGREPOSITORYSUBDIR} \
		PKGSRCDIR=${.CURDIR:C|/[^/]*/[^/]*$||} \
		TMPDIR=${TMPDIR:U/tmp} \
		SINGLEPKG=${PKGPATH} \
		$@.tmp1
	@${RM} $@.tmp1

.PHONY: show-pkgtools-version
.if !target(show-pkgtools-version)
show-pkgtools-version:
	@${ECHO} ${PKGTOOLS_VERSION}
.endif

# convenience target, to display make variables from command line
# i.e. "make show-var VARNAME=var", will print var's value
.PHONY: show-var
show-var:
	@${ECHO} ${${VARNAME}:Q}

# enhanced version of target above, to display multiple variables
.PHONY: show-vars
show-vars:
.for VARNAME in ${VARNAMES}
	@${ECHO} ${${VARNAME}:Q}
.endfor

.PHONY: print-build-depends-list
.if !target(print-build-depends-list)
print-build-depends-list:
.  if defined(BUILD_DEPENDS) || defined(DEPENDS)
	@${ECHO} -n 'This package requires package(s) "'
	@${ECHO} -n `${MAKE} ${MAKEFLAGS} build-depends-list | ${SORT} -u`
	@${ECHO} '" to build.'
.  endif
.endif

.PHONY: print-run-depends-list
.if !target(print-run-depends-list)
print-run-depends-list:
.  if defined(DEPENDS)
	@${ECHO} -n 'This package requires package(s) "'
	@${ECHO} -n `${MAKE} ${MAKEFLAGS} run-depends-list | ${SORT} -u`
	@${ECHO} '" to run.'
.  endif
.endif

# This target is used by the mk/scripts/mkreadme script to generate
# README.html files
.PHONY: print-summary-data
.if !target(print-summary-data)
print-summary-data:
	@${ECHO} "depends ${PKGPATH} ${DEPENDS}"
	@${ECHO} "build_depends ${PKGPATH} ${BUILD_DEPENDS}"
	@${ECHO} "conflicts ${PKGPATH} ${CONFLICTS}"
	@${ECHO} "index ${PKGPATH} ${PKGNAME}"
	@${ECHO} htmlname ${PKGPATH} ${HTML_PKGNAME:Q}
	@${ECHO} homepage ${PKGPATH} ${HOMEPAGE:Q}
	@${ECHO} wildcard ${PKGPATH} ${PKGWILDCARD:Q}
	@${ECHO} comment ${PKGPATH} ${COMMENT:Q}
	@${ECHO} license ${PKGPATH} ${LICENSE:Q}
	@if [ "${ONLY_FOR_ARCHS}" = "" ]; then				\
		${ECHO} "onlyfor ${PKGPATH} any";			\
	else								\
		${ECHO} "onlyfor ${PKGPATH} ${ONLY_FOR_ARCHS}";		\
	fi;
	if [ "${NOT_FOR_OPSYS}" = "" ]; then				\
		${ECHO} "notfor ${PKGPATH} any";			\
	else								\
		${ECHO} "notfor ${PKGPATH} not ${NOT_FOR_OPSYS}";	\
	fi;
	@${ECHO} "maintainer ${PKGPATH} ${MAINTAINER}"
	@${ECHO} "categories ${PKGPATH} ${CATEGORIES}"
	@if [ -f ${DESCR_SRC} ]; then					\
		${ECHO}  "descr ${PKGPATH} ${DESCR_SRC}";		\
	else								\
		${ECHO}  "descr ${PKGPATH} /dev/null";			\
	fi
	@${ECHO} "prefix ${PKGPATH} ${PREFIX}"
.endif

.if !target(show-license)
show-license show-licence:
	@if [ "${LICENSE}" != "" ]; then				\
		if [ -e ${_PKGSRCDIR}/licenses/${LICENSE} ]; then	\
			${CAT} ${_PKGSRCDIR}/licenses/${LICENSE};	\
		else							\
			${ECHO} "Generic ${LICENSE} information not available"; \
			${ECHO} "See the package description (pkg_info -d ${PKGNAME}) for more information."; \
		fi							\
	fi
.endif

# Stat all the files of one pkg and sum the sizes up.
#
# XXX This is intended to be run before pkg_create is called, so the
# existence of ${PLIST} can be assumed.
.PHONY: print-pkg-size-this
print-pkg-size-this:
	@${SHCOMMENT} "This pkg's files" ;				\
	${AWK} 'BEGIN { base = "${PREFIX}/" }				\
		/^@cwd/ { base = $$2 "/" }				\
		/^@ignore/ { next }					\
		NF == 1 { print base $$1 }'				\
		<${PLIST} 						\
	| ${SORT} -u							\
	| ${SED} -e 's, ,\\ ,g'						\
	| ${XARGS} ${LS} -ld						\
	| ${AWK} 'BEGIN { print("0 "); }				\
		  { print($$5, " + "); }				\
		  END { print("p"); }'					\
	| ${DC}

# Sizes of required pkgs (only)
#
# XXX This is intended to be run before pkg_create is called, so the
# dependencies are all installed.
.PHONY: print-pkg-size-depends
print-pkg-size-depends:
	@${MAKE} ${MAKEFLAGS} run-depends-list PACKAGE_DEPENDS_QUICK=true \
	| ${XARGS} -n 1 ${SETENV} ${PKG_INFO} -e			\
	| ${SORT} -u							\
	| ${XARGS} -n 256 ${SETENV} ${PKG_INFO} -qs			\
	| ${AWK} -- 'BEGIN { print("0 "); }				\
		/^[0-9]+$$/ { print($$1, " + "); }			\
		END { print("p"); }'					\
	| ${DC}


###
### Automatic PLIST generation
###  - files & symlinks first
###  - @exec/@unexec calls are added for info files
###  - @dirrm statements last
###  - empty directories are handled properly
###  - dirs from mtree files are excluded
###
### Usage:
###  - make install
###  - make print-PLIST | brain >PLIST
###

# Common (system) directories not to generate @dirrm statements for
# Reads MTREE_FILE and extracts a list of sed commands that will
# sort out which directories NOT to include into the PLIST @dirrm list
SUBST_PLIST_REPLACEMENT=\
		-e  's@${OPSYS}@\$${OPSYS}@' 				\
		-e  's@${OS_VERSION:S/./\./g}@\$${OS_VERSION}@'		\
		-e  's@${MACHINE_GNU_PLATFORM}@\$${MACHINE_GNU_PLATFORM}@' \
		-e  's@${MACHINE_ARCH}@\$${MACHINE_ARCH}@' 		\
		-e  's@${MACHINE_GNU_ARCH}@\$${MACHINE_GNU_ARCH}@'	\
		-e  's@${LOWER_VENDOR}@\$${LOWER_VENDOR}@' 		\
		-e  's@${LOWER_OPSYS}@\$${LOWER_OPSYS}@' 		\
		-e  's@${LOWER_OS_VERSION:S/./\./g}@\$${LOWER_OS_VERSION}@' 	\
		-e  's@${PKGNAME:S/./\./g}@\$${PKGNAME}@' 			\
		-e  's@${PKGVERSION:S/./\./g}@\$${PKGVERSION}@'		\
		-e  's@${PKGLOCALEDIR}/locale@\$${PKGLOCALEDIR}/locale@' \

.if make(print-PLIST)
COMMON_DIRS!= 	${AWK} 'BEGIN  { 					\
			i=0; 						\
			stack[i]="${PREFIX}" ; 				\
			cwd=""; 					\
		} 							\
		! ( /^\// || /^\#/ || /^$$/ ) { 			\
			if ( $$1 == ".." ){ 				\
				i=i-1;					\
				cwd = stack[i];				\
			} else if ( $$1 == "." ){ 			\
			} else {					\
				stack[i] = cwd ;			\
				if ( i == 0 ){ 				\
					cwd = $$1 ; 			\
				} else {				\
					cwd = cwd "\\\\/" $$1 ; 	\
				} 					\
				print "-e \"/^" cwd "$$$$/d\"";		\
				i=i+1 ; 				\
			} 						\
		} 							\
	' <${MTREE_FILE}
.endif


# scan $PREFIX for any files/dirs modified since the package was extracted
# will emit "@exec mkdir"-statements for empty directories
# XXX will fail for data files that were copied using tar (e.g. emacs)!
# XXX should check $LOCALBASE and $X11BASE, and add @cwd statements

.PHONY: print-PLIST
.if !target(print-PLIST)
print-PLIST:
	${_PKG_SILENT}${_PKG_DEBUG}\
	${ECHO} '@comment $$'NetBSD'$$'
	${_PKG_SILENT}${_PKG_DEBUG}\
	shlib_type=`${MAKE} ${MAKEFLAGS} show-shlib-type`;		\
	case $$shlib_type in 						\
	"a.out")	genlinks=1 ;;					\
	*)		genlinks=0 ;;					\
	esac;								\
	${FIND} ${PREFIX}/. -xdev -newer ${EXTRACT_COOKIE} \! -type d	\
	 | ( ${GREP} -v emul/linux/proc || ${TRUE} )			\
	 | ${SORT}							\
	 | ${SED}							\
		-e  's@${PREFIX}/./@@' 					\
		${SUBST_PLIST_REPLACEMENT}				\
	 | ${AWK} '							\
		/^@/ { print $$0; next }				\
		/.*\/lib[^\/]+\.so\.[0-9]+\.[0-9]+\.[0-9]+$$/ { 	\
			print $$0;					\
			sub("\.[0-9]+$$", "");				\
			if ('$$genlinks') print $$0;			\
			sub("\.[0-9]+$$", "");				\
			if ('$$genlinks') print $$0;			\
			sub("\.[0-9]+$$", "");				\
			if ('$$genlinks') print $$0;			\
			next;						\
		}							\
		/.*\/lib[^\/]+\.so\.[0-9]+\.[0-9]+$$/ { 		\
			print $$0;					\
			sub("\.[0-9]+$$", "");				\
			if ('$$genlinks') print $$0;			\
			sub("\.[0-9]+$$", "");				\
			if ('$$genlinks') print $$0;			\
			next;						\
		}							\
		{ 							\
		  if (!/^info\/dir$$/) {				\
		    print $$0;						\
		  }							\
		}'
	${_PKG_SILENT}${_PKG_DEBUG}\
	for i in `${FIND} ${PREFIX}/. -xdev -newer ${EXTRACT_COOKIE} -type d	\
		        | ( ${GREP} -v emul/linux/proc || ${TRUE} )	\
			| ${SED}					\
				-e 's@${PREFIX}/./@@'			\
				-e '/^${PREFIX:S/\//\\\//g}\/.$$/d'	\
			| ${SORT} -r | ${SED} ${COMMON_DIRS}` ;		\
	do								\
		if [ `${LS} -la ${PREFIX}/$$i | ${WC} -l` = 3 ]; then	\
			${ECHO} @exec \$${MKDIR} %D/$$i ;		\
		fi ;							\
		${ECHO} @dirrm $$i ;					\
	done								\
	| ( ${GREP} -v emul/linux/proc || ${TRUE} )			\
	| ${SED}							\
		${SUBST_PLIST_REPLACEMENT}
.endif # target(print-PLIST)


# Fake installation of package so that user can pkg_delete it later.
# Also, make sure that an installed package is recognized correctly in
# accordance to the @pkgdep directive in the packing lists

.PHONY: fake-pkg
.if !target(fake-pkg)
fake-pkg: ${PLIST} ${DESCR} ${MESSAGE}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ ! -f ${PLIST} -o ! -f ${DESCR} ]; then			\
		${ECHO} "** Missing package files for ${PKGNAME} - installation not recorded."; \
		exit 1;							\
	fi
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ ! -d ${PKG_DBDIR} ]; then					\
		${RM} -f ${PKG_DBDIR};					\
		${MKDIR} ${PKG_DBDIR};					\
	fi
.  if defined(FORCE_PKG_REGISTER)
	${_PKG_SILENT}${_PKG_DEBUG}${PKG_DELETE} -O ${PKGNAME}
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -rf ${PKG_DBDIR}/${PKGNAME}
.  endif
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${BUILD_VERSION_FILE} ${BUILD_INFO_FILE}
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${SIZE_PKG_FILE} ${SIZE_ALL_FILE}
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${PRESERVE_FILE}
.  if defined(PKG_PRESERVE)
	${_PKG_SILENT}${_PKG_DEBUG}${DATE} > ${PRESERVE_FILE}
.  endif
	${_PKG_SILENT}${_PKG_DEBUG}					\
	files="";							\
	for f in ${.CURDIR}/Makefile ${FILESDIR}/* ${PKGDIR}/*; do	\
		if [ -f "$$f" ]; then					\
			files="$$files \"$$f\"";			\
		fi;							\
	done;								\
	if [ -f ${DISTINFO_FILE} ]; then				\
		for f in `${AWK} 'NF == 4 && $$3 == "=" { gsub("[()]", "", $$2); print $$2 }' < ${DISTINFO_FILE}`; do \
			if [ -f ${PATCHDIR}/$$f ]; then			\
				files="$$files \"${PATCHDIR}/$$f\"";	\
			fi;						\
		done;							\
	fi;								\
	if [ -d ${PATCHDIR} ]; then					\
		for f in ${PATCHDIR}/patch-*; do			\
			case $$f in					\
			*.orig|*.rej|*~) ;;				\
			${PATCHDIR}/patch-local-*)			\
				files="$$files \"$$f\"" ;;		\
			esac;						\
		done;							\
	fi;								\
	eval ${GREP} '\$$NetBSD' $$files | ${SED} -e 's|^${_PKGSRCDIR}/||' > ${BUILD_VERSION_FILE}
.  for def in ${BUILD_DEFS}
	@${ECHO} ${def}=${${def}:Q} | ${SED} -e 's|^PATH=[^ 	]*|PATH=...|' >> ${BUILD_INFO_FILE}
.  endfor
	@${ECHO} "CC=${CC}" >> ${BUILD_INFO_FILE}
	@if ${CC} -v 2>&1 | ${GREP} -q '^gcc'; then \
	  ${ECHO} "CC_VERSION=`${CC} -v 2>&1 | ${GREP} '^gcc'`" >> ${BUILD_INFO_FILE}; \
	elif ${CC} -V 2>&1 | ${GREP} -q '^cc'; then \
	  ${ECHO} "CC_VERSION=`${CC} -V 2>&1 | ${GREP} '^cc'`" >> ${BUILD_INFO_FILE}; \
	fi
.  if defined(USE_PERL5) && (${USE_PERL5} == "run")
	@${ECHO} "PERL=`${PERL5} --version 2>/dev/null | ${GREP} 'This is perl'`" >> ${BUILD_INFO_FILE}
.  endif
.  ifdef USE_GMAKE
	@${ECHO} "GMAKE=`${GMAKE} --version | ${GREP} Make`" >> ${BUILD_INFO_FILE}
.  endif
.  if ${CHECK_SHLIBS} == "YES"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	case "${OBJECT_FMT}" in						\
	ELF)	bins=`${SETENV} PREFIX=${PREFIX} ${AWK} '/^(bin|sbin|libexec)\// { print ENVIRON["PREFIX"] "/" $$0 }' ${PLIST} || ${TRUE}`; \
		libs=`${SETENV} PREFIX=${PREFIX} ${AWK} '/^lib\/lib.*\.so\.[0-9]+$$/ { print ENVIRON["PREFIX"] "/" $$0 }' ${PLIST} || ${TRUE}`; \
		for i in "" $$libs; do					\
			${TEST} "$$i" = "" && continue;			\
			${ECHO} "PROVIDES=$$i" >> ${BUILD_INFO_FILE};	\
		done;							\
		case "${LDD}" in					\
		"")	ldd=`${TYPE} ldd | ${AWK} '{ print $$NF }'`;;	\
		*)	ldd="${LDD}";					\
		esac;							\
		if ${TEST} "$$bins" != "" -o "$$libs" != ""; then 	\
			requires=`($$ldd $$bins $$libs 2>/dev/null || ${TRUE}) | ${AWK} 'NF == 3 { print $$3 }' | ${SORT} -u`; \
			for req in "" $$requires; do			\
				${TEST} "$$req" = "" && continue;	\
				${ECHO} "REQUIRES=$$req" >> ${BUILD_INFO_FILE};	\
			done;						\
		fi;							\
        	;;							\
	esac
.  endif
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${ECHO} "_PKGTOOLS_VER=${PKGTOOLS_VERSION}" >> ${BUILD_INFO_FILE}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	size_this=`${MAKE} ${MAKEFLAGS} print-pkg-size-this`;		\
	size_depends=`${MAKE} ${MAKEFLAGS} print-pkg-size-depends`;	\
	${ECHO} $$size_this >${SIZE_PKG_FILE};				\
	${ECHO} $$size_this $$size_depends + p | ${DC} >${SIZE_ALL_FILE}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ ! -d ${PKG_DBDIR}/${PKGNAME} ]; then			\
		${ECHO_MSG} "${_PKGSRC_IN}> Registering installation for ${PKGNAME}"; \
		${MKDIR} ${PKG_DBDIR}/${PKGNAME};			\
		${PKG_CREATE} ${PKG_ARGS_INSTALL} -O ${PKGFILE} > ${PKG_DBDIR}/${PKGNAME}/+CONTENTS; \
		${CP} ${DESCR} ${PKG_DBDIR}/${PKGNAME}/+DESC;		\
		${ECHO} ${COMMENT:Q} > ${PKG_DBDIR}/${PKGNAME}/+COMMENT; \
		${CP} ${BUILD_VERSION_FILE} ${PKG_DBDIR}/${PKGNAME}/+BUILD_VERSION; \
		${CP} ${BUILD_INFO_FILE} ${PKG_DBDIR}/${PKGNAME}/+BUILD_INFO; \
		if ${TEST} -e ${SIZE_PKG_FILE}; then 			\
			${CP} ${SIZE_PKG_FILE} ${PKG_DBDIR}/${PKGNAME}/+SIZE_PKG; \
		fi ; 							\
		if ${TEST} -e ${SIZE_ALL_FILE}; then 			\
			${CP} ${SIZE_ALL_FILE} ${PKG_DBDIR}/${PKGNAME}/+SIZE_ALL; \
		fi ; 							\
		if ${TEST} -e ${PRESERVE_FILE}; then 			\
			${CP} ${PRESERVE_FILE} ${PKG_DBDIR}/${PKGNAME}/+PRESERVE; \
		fi ; 							\
		if [ -n "${INSTALL_FILE}" ]; then			\
			if ${TEST} -e ${INSTALL_FILE}; then		\
				${CP} ${INSTALL_FILE} ${PKG_DBDIR}/${PKGNAME}/+INSTALL; \
			fi;						\
		fi;							\
		if [ -n "${DEINSTALL_FILE}" ]; then			\
			if ${TEST} -e ${DEINSTALL_FILE}; then		\
				${CP} ${DEINSTALL_FILE} ${PKG_DBDIR}/${PKGNAME}/+DEINSTALL; \
			fi;						\
		fi;							\
		if [ -n "${MESSAGE}" ]; then				\
			if ${TEST} -e ${MESSAGE}; then			\
				${CP} ${MESSAGE} ${PKG_DBDIR}/${PKGNAME}/+DISPLAY; \
			fi;						\
		fi;							\
		list="`${MAKE} ${MAKEFLAGS} run-depends-list PACKAGE_DEPENDS_QUICK=true ECHO_MSG=${TRUE} | ${SORT} -u`" ; \
		for dep in $$list; do \
			realdep="`${PKG_INFO} -e \"$$dep\" || ${TRUE}`" ; \
			if [ `${ECHO} $$realdep | ${WC} -w` -gt 1 ]; then \
				${ECHO} '***' "WARNING: '$$dep' expands to several installed packages " ; \
				${ECHO} "    (" `${ECHO} $$realdep` ")." ; \
				${ECHO} "    Please check if this is really intended!" ; \
				continue ; 				\
			fi ; 						\
		done ; 							\
		for realdep in `${ECHO} $$list | ${XARGS} -n 1 ${SETENV} ${PKG_INFO} -e | ${SORT} -u`; do \
			if ${TEST} -z "$$realdep"; then			\
				${ECHO} "$$dep not installed - dependency NOT registered" ; \
			elif [ -d ${PKG_DBDIR}/$$realdep ]; then	\
				if ${TEST} ! -e ${PKG_DBDIR}/$$realdep/+REQUIRED_BY; then \
					${TOUCH} ${PKG_DBDIR}/$$realdep/+REQUIRED_BY; \
				fi; 					\
				${AWK} 'BEGIN { found = 0; } 		\
					$$0 == "${PKGNAME}" { found = 1; } \
					{ print $$0; } 			\
					END { if (!found) { printf("%s\n", "${PKGNAME}"); }}' \
					< ${PKG_DBDIR}/$$realdep/+REQUIRED_BY > ${PKG_DBDIR}/$$realdep/reqby.$$$$; \
				${MV} ${PKG_DBDIR}/$$realdep/reqby.$$$$ ${PKG_DBDIR}/$$realdep/+REQUIRED_BY; \
				${ECHO} "${PKGNAME} requires installed package $$realdep"; \
			fi;						\
		done;							\
	fi
.endif

# Depend is generally meaningless for arbitrary packages, but if someone wants
# one they can override this.  This is just to catch people who've gotten into
# the habit of typing `${MAKE} depend all install' as a matter of course.
#
.PHONY: depend
.if !target(depend)
depend:
.endif

# Same goes for tags
.PHONY: tags
.if !target(tags)
tags:
.endif

# if automatic manual page compression is done by the package according
# to MANZ's value, set MANCOMPRESSED if MANZ is set
.if defined(MANCOMPRESSED_IF_MANZ) && defined(MANZ)
MANCOMPRESSED=	yes
MAKE_ENV+=	MANZ="${MANZ}"
.endif

# generate ${PLIST} from ${PLIST_SRC} by:
# - fixing list of man-pages according to MANCOMPRESSED/MANZ
#   (we don't take any notice of MANCOMPRESSED as many packages have .gz
#   pages in PLIST even when they install manpages without compressing them)
# - substituting by ${PLIST_SUBST}
# - adding files and appropriate rmdir statements for perl5 modules if
#   PERL5_PACKLIST is defined
# - adding symlinks for shared libs (ELF) or ldconfig calls (a.out).

.if ${_OPSYS_HAS_MANZ} == "yes"
.  ifdef MANZ
_MANZ_EXPRESSION= -e 's|\(^\([^@/]*/\)*man/\([^/]*/\)\{0,1\}man[1-9ln]/.*[1-9ln]$$\)|\1.gz|' \
		-e 's|\(^\([^@/]*/\)*man/\([^/]*/\)\{0,1\}cat[1-9ln]/.*0$$\)|\1.gz|'
.  else
_MANZ_EXPRESSION= -e 's|\(^\([^@/]*/\)*man/\([^/]*/\)\{0,1\}man[1-9ln]/.*[1-9ln]\)\.gz$$|\1|' \
		-e 's|\(^\([^@/]*/\)*man/\([^/]*/\)\{0,1\}cat[1-9ln]/.*0\)\.gz$$|\1|'
.  endif # MANZ
_MANZ_NAWK_CMD=
.else
_MANZ_EXPRESSION=
.  ifdef MANZ
_MANZ_NAWK_CMD=	${AWK} '/^([^\/]*\/)*man\/([^\/]*\/)?man[1-9ln]\/.*[1-9ln]\.gz$$/ { \
		$$0 = sprintf("%s.gz", $$0);				\
	}								\
	/^([^\/]*\/)*man\/([^\/]*\/)?cat[1-9ln]\/.*0\.gz$$/ {	\
		$$0 = sprintf("%s.gz", $$0);				\
	}								\
	{ print $$0; }' |
.  else
_MANZ_NAWK_CMD=	${AWK} '/^([^\/]*\/)*man\/([^\/]*\/)?man[1-9ln]\/.*[1-9ln]\.gz$$/ { \
		$$0 = substr($$0, 1, length($$0) - 3);			\
	}								\
	/^([^\/]*\/)*man\/([^\/]*\/)?cat[1-9ln]\/.*0\.gz$$/ {	\
		$$0 = substr($$0, 1, length($$0) - 3);			\
	}								\
	{ print $$0; }' |
.  endif # MANZ
.endif

.if defined(MANINSTALL)
_MANINSTALL_CMD= ${AWK} 'BEGIN{						\
		start="^([^\/]*\/)*man\/([^\/]*\/)?";			\
		end="[1-9ln]"; }					\
		{ if (!"${MANINSTALL:Mmaninstall}" && 			\
				match($$0, start "man" end)) {next;}	\
		if (!"${MANINSTALL:Mcatinstall}" && 			\
				match($$0, start "cat" end)) {next;}	\
		print $$0; }' |
.else
_MANINSTALL_CMD=
.endif

.if defined(USE_IMAKE) && ${_PREFORMATTED_MAN_DIR} == "man"
_IMAKE_MAN_CMD=	${AWK} '/^([^\/]*\/)*man\/([^\/]*\/)?cat[1-9ln]\/.*0(\.gz)?$$/ { \
	sect = $$0; n = match(sect, "/cat[1-9ln]");			\
	sect = sprintf(".%s", substr(sect, n + 4, 1));			\
	s = $$0; sub("/cat", "/man", s); sub("\.0(\.gz)?$$", sect, s);	\
	if (match($$0, "\.gz$$") > 0) { ext = ".gz";} else { ext = "";} \
	$$0 = sprintf("%s%s", s, ext);					\
	} { print $$0; }' |
.  else
_IMAKE_MAN_CMD=
.endif # USE_IMAKE

.if !defined(PERL5_GENERATE_PLIST)
.  if defined(PERL5_PACKLIST)
PERL5_COMMENT=		( ${ECHO} "@comment The following lines are automatically generated"; \
	${ECHO} "@comment from the installed .packlist files." )
PERL5_PACKLIST_FILES=	( ${CAT} ${PERL5_PACKLIST}; for f in ${PERL5_PACKLIST}; do [ ! -f $$f ] || ${ECHO} $$f; done ) \
	| ${SED} -e "s,[ 	].*,," -e "s,/\./,/,g" -e "s,/*${PREFIX}/,," \
	| ${SORT} -u
PERL5_PACKLIST_DIRS=	( ${CAT} ${PERL5_PACKLIST}; for f in ${PERL5_PACKLIST}; do [ ! -f $$f ] || ${ECHO} $$f; done ) \
	| ${SED} -e "s,[ 	].*,," -e "s,/\./,/,g" -e "s,/*${PREFIX}/,," \
		-e "s,^,@unexec \${RMDIR} -p %D/," \
		-e "s,/[^/]*$$, 2>/dev/null || \${TRUE}," \
	| ${SORT} -ur
PERL5_GENERATE_PLIST=	${PERL5_COMMENT}; \
			${PERL5_PACKLIST_FILES}; \
			${PERL5_PACKLIST_DIRS}
GENERATE_PLIST+=	${PERL5_GENERATE_PLIST};
.  endif
.endif

.PHONY: message
message: ${MESSAGE}
.ifdef MESSAGE
${MESSAGE}: ${MESSAGE_SRC}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -z "${MESSAGE_SRC}" ]; then				\
		${ECHO} "${MESSAGE_SRC} not found.";			\
		${ECHO} "Please set MESSAGE_SRC correctly.";		\
	else								\
		${CAT} ${MESSAGE_SRC} |					\
			${SED} ${MESSAGE_SUBST_SED}			\
			> ${MESSAGE};					\
	fi
.endif

# GENERATE_PLIST is a sequence of commands, terminating in a semicolon,
#	that outputs contents for a PLIST to stdout and is appended to
#	the contents of ${PLIST_SRC}.
#
GENERATE_PLIST?=	${TRUE};
_GENERATE_PLIST=	${CAT} ${PLIST_SRC}; ${GENERATE_PLIST}

.PHONY: plist
plist: ${PLIST}
${PLIST}: ${PLIST_SRC}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	{ ${_GENERATE_PLIST} } | 					\
		${_MANINSTALL_CMD}					\
		${_MANZ_NAWK_CMD} 					\
		${_IMAKE_MAN_CMD} 					\
		${SED} 	${PLIST_SUBST:S/=/}!/:S/$/!g/:S/^/ -e s!\\\${/}	\
			${_MANZ_EXPRESSION}				\
		> ${PLIST}; 						\
	  ${MAKE} ${MAKEFLAGS} do-shlib-handling			\
		SHLIB_PLIST_MODE=1 ;					\

# generate ${DESCR} from ${DESCR_SRC} by:
# - Appending the homepage URL, if any

.PHONY: descr
descr: ${DESCR}
${DESCR}: ${DESCR_SRC}
	@${CAT} ${DESCR_SRC} 	 >${DESCR}
.if defined(HOMEPAGE)
	@\
	${ECHO}			>>${DESCR} ; \
	${ECHO} "Homepage:"	>>${DESCR} ; \
	${ECHO} '${HOMEPAGE}'	>>${DESCR}	
.endif

#
# For bulk build targets (bulk-install, bulk-package), the
# BATCH variable must be set in /etc/mk.conf:
#
.if defined(BATCH)
.  include "../../mk/bulk/bsd.bulk-pkg.mk"
.endif
