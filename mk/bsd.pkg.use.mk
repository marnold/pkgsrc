#	$NetBSD: bsd.pkg.use.mk,v 1.1.2.1 2004/11/22 22:48:05 tv Exp $
#
# Turn USE_* macros into proper depedency logic.  Included near the top of
# bsd.pkg.mk, after bsd.prefs.mk.

############################################################################
# ${PREFIX} selection
############################################################################

.if defined(USE_IMAKE)
INSTALL_TARGET+=	${NO_INSTALL_MANPAGES:D:Uinstall.man}
PREPEND_PATH+=		${X11BASE}/bin
USE_X11BASE?=		implied
PLIST_SUBST+=		IMAKE_MAN_SOURCE_PATH=${IMAKE_MAN_SOURCE_PATH}
PLIST_SUBST+=		IMAKE_MAN_DIR=${IMAKE_MAN_DIR}
PLIST_SUBST+=		IMAKE_LIBMAN_DIR=${IMAKE_LIBMAN_DIR}
PLIST_SUBST+=		IMAKE_KERNMAN_DIR=${IMAKE_KERNMAN_DIR}
PLIST_SUBST+=		IMAKE_FILEMAN_DIR=${IMAKE_FILEMAN_DIR}
PLIST_SUBST+=		IMAKE_MISCMAN_DIR=${IMAKE_MISCMAN_DIR}
PLIST_SUBST+=		IMAKE_MAN_SUFFIX=${IMAKE_MAN_SUFFIX}
PLIST_SUBST+=		IMAKE_LIBMAN_SUFFIX=${IMAKE_LIBMAN_SUFFIX}
PLIST_SUBST+=		IMAKE_KERNMAN_SUFFIX=${IMAKE_KERNMAN_SUFFIX}
PLIST_SUBST+=		IMAKE_FILEMAN_SUFFIX=${IMAKE_FILEMAN_SUFFIX}
PLIST_SUBST+=		IMAKE_MISCMAN_SUFFIX=${IMAKE_MISCMAN_SUFFIX}
PLIST_SUBST+=		IMAKE_MANNEWSUFFIX=${IMAKE_MANNEWSUFFIX}
.  if !empty(USE_BUILDLINK3:M[yY][eE][sS])
MAKE_FLAGS+=		CC="${CC}" CXX="${CXX}"
.  endif
.endif

.if defined(USE_X11BASE)
MTREE_FILE?=		${PKGSRCDIR}/mk/${OPSYS}.x11.dist
USE_X11?=		implied
.endif

.if ${PKG_INSTALLATION_TYPE} == "pkgviews"
PREFIX=			${DEPOTBASE}/${PKGNAME}
NO_MTREE=		yes
.elif ${PKG_INSTALLATION_TYPE} == "overwrite"
.  if defined(INSTALLATION_PREFIX)
PREFIX=			${INSTALLATION_PREFIX}
.  elif defined(USE_X11BASE)
PREFIX=			${X11PREFIX}
.  elif defined(USE_CROSSBASE)
PREFIX=			${CROSSBASE}
NO_MTREE=		yes
.  else
PREFIX=			${LOCALBASE}
.  endif
.endif

.if (${PKG_INSTALLATION_TYPE} == "pkgviews") && defined(INSTALLATION_PREFIX)
PKG_SKIP_REASON=	"INSTALLATION_PREFIX can't be used in a pkgviews package"
.endif

############################################################################
# General settings
############################################################################

### BUILD_USES_MSGFMT

.if defined(BUILD_USES_MSGFMT) && \
    (!exists(/usr/bin/msgfmt) || ${_USE_GNU_GETTEXT} == "yes")
BUILD_DEPENDS+=		gettext>=0.10.35nb1:../../devel/gettext
.endif

### PKG_USE_KERBEROS

.if defined(PKG_USE_KERBEROS)
CRYPTO?=		uses Kerberos encryption code
BUILD_DEFS+=		KERBEROS
.endif

### USE_DIRS

USE_DIRS?=		# empty
.if !empty(USE_DIRS) && ${PKG_INSTALLATION_TYPE} == "overwrite"
.  include "../../mk/dirs.mk"
.endif

### USE_FORTRAN

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
.    if !empty(USE_BUILDLINK3:M[yY][eE][sS])
.      include "../../lang/f2c/buildlink3.mk"
.    else
DEPENDS+=	f2c>=20001205nb3:../../lang/f2c
.    endif
.  endif
FC=             ${PKG_FC}
F77=            ${PKG_FC}
CONFIGURE_ENV+=	F77="${F77}"
CONFIGURE_ENV+=	FFLAGS="${FFLAGS:M*}"
MAKE_ENV+=	F77="${F77}"
MAKE_ENV+=	FC="${FC}"
.endif

### USE_LIBTOOL, PKG_[SH]LIBTOOL

#
# PKG_LIBTOOL is the path to the libtool script installed by libtool-base.
# _LIBTOOL is the path the libtool used by the build, which could be the
#	path to a libtool wrapper script.
# LIBTOOL is the publicly-readable variable that should be used by
#	Makefiles to invoke the proper libtool.
#
PKG_LIBTOOL?=		${LOCALBASE}/bin/libtool
PKG_SHLIBTOOL?=		${LOCALBASE}/bin/shlibtool
_LIBTOOL?=		${PKG_LIBTOOL}
_SHLIBTOOL?=		${PKG_SHLIBTOOL}
LIBTOOL?=		${PKG_LIBTOOL}
SHLIBTOOL?=		${PKG_SHLIBTOOL}
.if defined(USE_LIBTOOL)
BUILD_DEPENDS+=		libtool-base>=${_OPSYS_LIBTOOL_REQD:U1.5.10nb1}:../../devel/libtool-base
CONFIGURE_ENV+=		LIBTOOL="${LIBTOOL} ${LIBTOOL_FLAGS}"
MAKE_ENV+=		LIBTOOL="${LIBTOOL} ${LIBTOOL_FLAGS}"
LIBTOOL_OVERRIDE?=	libtool */libtool */*/libtool
.endif

### USE_MAKEINFO, INFO_FILES

INFO_FILES?=		# empty
USE_MAKEINFO?=		no

.if !empty(INFO_FILES) || empty(USE_MAKEINFO:M[nN][oO])
.  include "../../mk/texinfo.mk"
.endif

### USE_PERL5, PERL5_REQD

# Distill the PERL5_REQD list into a single _PERL5_REQD value that is the
# highest version of Perl required.
#
PERL5_REQD+=		5.0
PERL5_REQD+=		${_OPSYS_PERL_REQD}

_PERL5_STRICTEST_REQD?=	none
.for _version_ in ${PERL5_REQD}
.  for _pkg_ in perl-${_version_}
.    if ${_PERL5_STRICTEST_REQD} == "none"
_PERL5_PKG_SATISFIES_DEP=	YES
.      for _vers_ in ${PERL5_REQD}
.        if !empty(_PERL5_PKG_SATISFIES_DEP:M[yY][eE][sS])
_PERL5_PKG_SATISFIES_DEP!=	\
	if ${PKG_ADMIN} pmatch 'perl>=${_vers_}' ${_pkg_} 2>/dev/null; then \
		${ECHO} "YES";						\
	else								\
		${ECHO} "NO";						\
	fi
.        endif
.      endfor
.      if !empty(_PERL5_PKG_SATISFIES_DEP:M[yY][eE][sS])
_PERL5_STRICTEST_REQD=	${_version_}
.      endif
.    endif
.  endfor
.endfor
_PERL5_REQD=	${_PERL5_STRICTEST_REQD}

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
_PERL5_DEPENDS=		{perl>=${_PERL5_REQD},perl-thread>=${_PERL5_REQD}}
#
# On platforms that have native pthreads, default to installing the
# threaded perl.  This can be overridden by explicitly setting
# PERL5_USE_THREADS.
#
.  if exists(/usr/include/pthread.h) && \
      !empty(PREFER_NATIVE_PTHREADS:M[yY][eE][sS])
PERL5_PKGSRCDIR?=	../../lang/perl58-thread
.  else
PERL5_PKGSRCDIR?=	../../lang/perl58
.  endif
.  if !defined(BUILDLINK_DEPENDS.perl)
${_PERL5_DEPMETHOD}+=	${_PERL5_DEPENDS}:${PERL5_PKGSRCDIR}
.  endif
.endif

.if defined(USE_PERL5) && (${USE_PERL5} == "run")
.  if !defined(PERL5_SITELIB) || !defined(PERL5_SITEARCH) || !defined(PERL5_ARCHLIB)
.    if exists(${PERL5})
.      if exists(${LOCALBASE}/share/mk/bsd.perl.mk)
.        include "${LOCALBASE}/share/mk/bsd.perl.mk"
.      else
PERL5_SITELIB!=		eval `${PERL5} -V:installsitelib 2>/dev/null`; \
			${ECHO} $${installsitelib}
PERL5_SITEARCH!=	eval `${PERL5} -V:installsitearch 2>/dev/null`; \
			${ECHO} $${installsitearch}
PERL5_ARCHLIB!=		eval `${PERL5} -V:installarchlib 2>/dev/null`; \
			${ECHO} $${installarchlib}
.      endif # !exists(bsd.perl.mk)
.      if ${PKG_INSTALLATION_TYPE} == "overwrite"
_PERL5_PREFIX!=		eval `${PERL5} -V:prefix 2>/dev/null`; \
			${ECHO} $${prefix}
PERL5_SITELIB:=		${PERL5_SITELIB:S/^${_PERL5_PREFIX}/${LOCALBASE}/}
PERL5_SITEARCH:=	${PERL5_SITEARCH:S/^${_PERL5_PREFIX}/${LOCALBASE}/}
PERL5_ARCHLIB:=		${PERL5_ARCHLIB:S/^${_PERL5_PREFIX}/${LOCALBASE}/}
MAKEFLAGS+=		PERL5_SITELIB=${PERL5_SITELIB:Q}
MAKEFLAGS+=		PERL5_SITEARCH=${PERL5_SITEARCH:Q}
MAKEFLAGS+=		PERL5_ARCHLIB=${PERL5_ARCHLIB:Q}
.      endif # PKG_INSTALLATION_TYPE == "overwrite"
.    endif   # exists($PERL5)
.  endif     # !defined(PERL5_*)
.endif       # USE_PERL5 == run

.if defined(PERL5_SITELIB)
PLIST_SUBST+=	PERL5_SITELIB=${PERL5_SITELIB:S/^${LOCALBASE}\///}
.endif
.if defined(PERL5_SITEARCH)
PLIST_SUBST+=	PERL5_SITEARCH=${PERL5_SITEARCH:S/^${LOCALBASE}\///}
.endif
.if defined(PERL5_ARCHLIB)
PLIST_SUBST+=	PERL5_ARCHLIB=${PERL5_ARCHLIB:S/^${LOCALBASE}\///}
.endif

### USE_RMAN

# Check if we got "rman" with XFree86, for packages that need "rman".
.if defined(USE_RMAN)
.  if !exists(${X11BASE}/bin/rman)
DEPENDS+=		rman-3.0.9:../../textproc/rman
RMAN?=			${LOCALBASE}/bin/rman
.  else
RMAN?=			${X11BASE}/bin/rman
.  endif
.endif

### USE_X11

.if defined(USE_X11)
X11_LDFLAGS+=		${COMPILER_RPATH_FLAG}${X11BASE}/lib${LIBABISUFFIX}
X11_LDFLAGS+=		-L${X11BASE}/lib${LIBABISUFFIX}
.  if !empty(USE_BUILDLINK3:M[nN][oO])
LDFLAGS+=		${X11_LDFLAGS}
.  endif
.endif

### USE_XPKGWEDGE

.if defined(USE_X11BASE) && !empty(USE_XPKGWEDGE:M[yY][eE][sS])
BUILD_DEPENDS+=		xpkgwedge>=${_XPKGWEDGE_REQD:U1.5}:../../pkgtools/xpkgwedge
.endif
