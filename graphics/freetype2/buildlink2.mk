# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/05/11 02:09:10 jlam Exp $
#
# This Makefile fragment is included by packages that use freetype2.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.freetype2 to the dependency pattern
#     for the version of freetype2 desired.
# (2) Include this Makefile fragment in the package Makefile.

.if !defined(FREETYPE2_BUILDLINK2_MK)
FREETYPE2_BUILDLINK2_MK=	# defined

.include "../../mk/bsd.prefs.mk"
.include "../../mk/bsd.buildlink2.mk"

BUILDLINK_DEPENDS.freetype2?=	freetype2>=2.0.1

# Check if we got FreeType2 distributed with XFree86 4.x or if we need to
# depend on the freetype2 package.
#
.if exists(${X11BASE}/include/freetype2/freetype/freetype.h)
_IS_BUILTIN_FREETYPE2!=	${EGREP} -c BuildFreetype2Library ${X11BASE}/lib/X11/config/X11.tmpl || ${TRUE}
.else
_IS_BUILTIN_FREETYPE2=	0
.endif
.if ${_IS_BUILTIN_FREETYPE2} == "0"
_NEED_FREETYPE2=	YES
.else
_NEED_FREETYPE2=	NO
.endif

.if ${_NEED_FREETYPE2} == "YES"
DEPENDS+=	${BUILDLINK_DEPENDS.freetype2}:../../graphics/freetype2
EVAL_PREFIX+=	BUILDLINK_PREFIX.freetype2=freetype2
BUILDLINK_PREFIX.freetype2_DEFAULT=	${LOCALBASE}
.else
BUILDLINK_PREFIX.freetype2=	${X11BASE}
.endif

BUILDLINK_FILES.freetype2=	include/ft2build.h
BUILDLINK_FILES.freetype2+=	include/freetype2/ft2build.h
BUILDLINK_FILES.freetype2+=	include/freetype2/freetype/*
BUILDLINK_FILES.freetype2+=	include/freetype2/freetype/cache/*
BUILDLINK_FILES.freetype2+=	include/freetype2/freetype/config/*
BUILDLINK_FILES.freetype2+=	include/freetype2/freetype/internal/*
BUILDLINK_FILES.freetype2+=	lib/libfreetype.*

BUILDLINK_TARGETS+=		freetype2-buildlink
BUILDLINK_TARGETS+=		freetype2-buildlink-config

_FREETYPE2_CONFIG= \
	${BUILDLINK_PREFIX.freetype2}/bin/freetype-config
_FREETYPE2_BUILDLINK_CONFIG= \
	${BUILDLINK_DIR}/bin/freetype-config

freetype2-buildlink: _BUILDLINK_USE

freetype2-buildlink-config:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ ! -f ${_FREETYPE2_CONFIG} ] &&				\
	   [ ! -f ${_FREETYPE2_BUILDLINK_CONFIG} ]; then		\
		${ECHO_BUILDLINK_MSG} "Creating config script ${_FREETYPE_BUILDLINK_CONFIG}."; \
		${MKDIR} ${_FREETYPE2_BUILDLINK_CONFIG:H};		\
		${SED}	-e "s|@AWK@|${AWK}|g"				\
			-e "s|@SED@|${SED}|g"				\
			-e "s|@X11BASE@|${X11BASE}|g"			\
			${.CURDIR}/../../graphics/freetype2/buildlink-freetype-config.in \
			> ${_FREETYPE2_BUILDLINK_CONFIG};		\
		${CHMOD} +x ${_FREETYPE2_BUILDLINK_CONFIG};		\
	fi

.endif	# FREETYPE2_BUILDLINK2_MK
