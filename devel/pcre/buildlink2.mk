# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/05/11 02:09:05 jlam Exp $
#
# This Makefile fragment is included by packages that use pcre.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.pcre to the dependency pattern
#     for the version of pcre desired.
# (2) Include this Makefile fragment in the package Makefile.

.if !defined(PCRE_BUILDLINK2_MK)
PCRE_BUILDLINK2_MK=	# defined

.include "../../mk/bsd.buildlink2.mk"

BUILDLINK_DEPENDS.pcre?=	pcre>=3.4
DEPENDS+=	${BUILDLINK_DEPENDS.pcre}:../../devel/pcre

BUILDLINK_PREFIX.pcre=	${LOCALBASE}
BUILDLINK_FILES.pcre=	include/pcre.h
BUILDLINK_FILES.pcre+=	include/pcreposix.h
BUILDLINK_FILES.pcre+=	lib/libpcre.*
BUILDLINK_FILES.pcre+=	lib/libpcreposix.*

BUILDLINK_TARGETS+=	pcre-buildlink

pcre-buildlink: _BUILDLINK_USE

.endif	# PCRE_BUILDLINK2_MK
