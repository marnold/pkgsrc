# $NetBSD: pthread.buildlink.mk,v 1.4.2.3 2002/08/21 22:01:35 jlam Exp $
#
# The pthreads strategy for pkgsrc is to "bless" a particular pthread
# package as the Official Pthread Replacement (OPR).  A package that uses
# pthreads may do one of the following:
#
#   (1) Simply include pthread.buildlink.mk.  This will make the package
#	use the native pthread library if it's available, or else the OPR
#	package.  The value of PTHREAD_TYPE may be checked to be either
#	"native", or the name of the OPR package, or "none", e.g.
#
#	#
#	# package Makefile stuff...
#	#
#	.include "../../mk/pthread.buildlink.mk"
#
#	.if defined(PTHREAD_TYPE) && (${PTHREAD_TYPE} == "none")
#	CONFIGURE_ARGS+=	--without-pthreads
#	.endif
#
#	.include "../../mk/bsd.pkg.mk"
#
#	Note that it's only safe to check and use the value of PTHREAD_TYPE
#	after all other buildlink.mk files have been included.
#
#   (2) Add "native" to PTHREAD_OPTS prior to including
#	pthread.buildlink.mk.  This is like case (1), but we only check for
#	the native pthread library, e.g.,
#
#	PTHREAD_OPTS+=	native
#	#
#	# package Makefile stuff...
#	#
#	.include "../../mk/pthread.buildlink.mk"
#
#	.if defined(PTHREAD_TYPE) && (${PTHREAD_TYPE} == "none")
#	CONFIGURE_ARGS+=	--without-pthreads
#	.endif
#
#	.include "../../mk/bsd.pkg.mk"
#
#   (3)	Add "require" to PTHREAD_OPTS prior to including
#	pthread.buildlink.mk.  This will make the package use the native
#	pthread library or else use the OPR package, and will otherwise set
#	IGNORE if neither can be used, e.g.,
#
#	PTHREAD_OPTS+=	require
#	#
#	# package Makefile stuff...
#	#
#	.include "../../mk/pthread.buildlink.mk"
#	.include "../../mk/bsd.pkg.mk"
#
#   (4) Add both "require" and "native" to PTHREAD_OPTS prior to including
#	pthread.buildlink.mk.  This is like case (3), but we only check for
#	the native pthread library, e.g.,
#
#	PTHREAD_OPTS+=	require native
#	#
#	# more package Makefile stuff...
#	#
#	.include "../../mk/pthread.buildlink.mk"
#	.include "../../mk/bsd.pkg.mk"
#
# The case where a package must use either the native pthread library or
# some pthread package aside from the OPR is a special case of (2), e.g.,
# if the required pthread package is "ptl2", then:
#
#	PTHREAD_OPTS+=	native
#	#
#	# more package Makefile stuff...
#	#
#	.include "../../mk/pthread.buildlink.mk"
#
#	.if defined(PTHREAD_TYPE) && (${PTHREAD_TYPE} == "none")
#	.  include "../../devel/ptl2/buildlink.mk"
#	.endif
#
#	.include "../../mk/bsd.pkg.mk"
#
# A package Makefile may add the word "optional" to PTHREAD_OPTS, which
# will override the effects of any instance of the word "require".  This
# should _only_ be used by those packages that can be built with or
# without pthreads _independently_ of whether any of its dependencies need
# pthreads.  Currently, this only only www/mozilla, which uses its own
# threading library if native pthreads is unavailable, despite that it
# uses GTK+, which _does_ need pthreads.
#
###########################################################################
#
# PTHREAD_OPTS represents whether this package requires pthreads, and also
#	whether it needs to be native.  It may include the word "require"
#	to denote that a pthreads implementation is required, and may also
#	include the word "native" to denote that only native pthreads are
#	acceptable.
#
# _PKG_PTHREAD is the fall-back package pthread implementation use by
#	pthread.buildlink.mk.
#
# _PKG_PTHREAD_COMPAT_PATTERNS matches the ONLY_FOR_PLATFORMS from the
#	Makefile for ${_PKG_PTHREAD}.  It's used to see if ${_PKG_PTHREADS}
#	can actually be used to replace a native pthreads.
#
_PKG_PTHREAD?=			pth
_PKG_PTHREAD_DEPENDS?=		pth>=1.4.1nb2
_PKG_PTHREAD_PKGSRCDIR?=	../../devel/${_PKG_PTHREAD}
_PKG_PTHREAD_BUILDLINK_MK?=	${_PKG_PTHREAD_PKGSRCDIR}/buildlink.mk
_PKG_PTHREAD_COMPAT_PATTERNS=	*-*-*

.include "../../mk/bsd.prefs.mk"

PTHREAD_OPTS?=	# empty
#
# We check for a native pthreads implementation by checking for the presence
# of /usr/include/pthread.h (we might want to make this check stricter).
#
.undef PTHREAD_TYPE
PREFER_NATIVE_PTHREADS?=	YES
.if exists(/usr/include/pthread.h) && (${PREFER_NATIVE_PTHREADS} == "YES")
PTHREAD_TYPE=	native
.else
.  if !empty(PTHREAD_OPTS:Mnative)
PTHREAD_TYPE=	none
.    if !empty(PTHREAD_OPTS:Mrequire) && empty(PTHREAD_OPTS:Moptional)
IGNORE=		"${PKGNAME} requires a native pthreads implementation."
.    endif
.  else
PTHREAD_TYPE=	none
.    for _pattern_ in ${_PKG_PTHREAD_COMPAT_PATTERNS}
.      if !empty(MACHINE_PLATFORM:M${_pattern_})
PTHREAD_TYPE=	${_PKG_PTHREAD}
.      endif
.    endfor
.    if (${PTHREAD_TYPE} == "none") && \
	!empty(PTHREAD_OPTS:Mrequire) && empty(PTHREAD_OPTS:Moptional)
IGNORE=		"${PKGNAME} requires a working pthreads implementation."
.    endif
.  endif
.endif

.if !defined(PTHREAD_BUILDLINK_MK)
PTHREAD_BUILDLINK_MK=	# defined

.if ${PTHREAD_TYPE} == "native"
#
# Link the native pthread libraries and headers into ${BUILDLINK_DIR}.  
#
.  include "../../mk/bsd.buildlink.mk"

BUILDLINK_PREFIX.pthread=	/usr
BUILDLINK_FILES.pthread=	include/pthread.h
BUILDLINK_FILES.pthread+=	lib/libpthread.*

BUILDLINK_TARGETS+=		pthread-buildlink

pre-configure: pthread-buildlink
pthread-buildlink: _BUILDLINK_USE

.elif ${PTHREAD_TYPE} == "${_PKG_PTHREAD}"
.  if exists(${_PKG_PTHREAD_BUILDLINK_MK})
.    if !empty(_PKG_PTHREAD_DEPENDS)
DEPENDS+=	${_PKG_PTHREAD_DEPENDS}:${_PKG_PTHREAD_PKGSRCDIR}
.    endif
.    include "${_PKG_PTHREAD_BUILDLINK_MK}"
.  else
IGNORE=		"${PKGNAME} needs pthreads, but ${_PKG_PTHREAD_BUILDLINK_MK} is missing."
.  endif
.endif

.endif	# PTHREAD_BUILDLINK_MK
