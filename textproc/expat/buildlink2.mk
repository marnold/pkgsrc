# $NetBSD: buildlink2.mk,v 1.1.2.2 2002/06/06 06:54:51 jlam Exp $
#
# This Makefile fragment is included by packages that use expat.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.expat to the dependency pattern
#     for the version of expat desired.
# (2) Include this Makefile fragment in the package Makefile.

.if !defined(EXPAT_BUILDLINK2_MK)
EXPAT_BUILDLINK2_MK=	# defined

.include "../../mk/bsd.buildlink2.mk"

BUILDLINK_DEPENDS.expat?=	expat>=1.95.2
DEPENDS+=	${BUILDLINK_DEPENDS.expat}:../../textproc/expat

EVAL_PREFIX+=	BUILDLINK_PREFIX.expat=expat
BUILDLINK_PREFIX.expat_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.expat=		include/expat.h
BUILDLINK_FILES.expat+=		lib/libexpat.*

BUILDLINK_TARGETS+=	expat-buildlink

expat-buildlink: _BUILDLINK_USE

.endif	# EXPAT_BUILDLINK2_MK
