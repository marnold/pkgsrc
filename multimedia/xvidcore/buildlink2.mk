# $NetBSD: buildlink2.mk,v 1.1.1.1 2004/01/26 12:38:26 jmmv Exp $
#
# This Makefile fragment is included by packages that use xvidcore.
#
# This file was created automatically using createbuildlink 2.5.
#

.if !defined(XVIDCORE_BUILDLINK2_MK)
XVIDCORE_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			xvidcore
BUILDLINK_DEPENDS.xvidcore?=		xvidcore>=0.9.1
BUILDLINK_PKGSRCDIR.xvidcore?=		../../multimedia/xvidcore

EVAL_PREFIX+=	BUILDLINK_PREFIX.xvidcore=xvidcore
BUILDLINK_PREFIX.xvidcore_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.xvidcore+=	include/xvid.h
BUILDLINK_FILES.xvidcore+=	lib/libxvidcore.*

BUILDLINK_TARGETS+=	xvidcore-buildlink

xvidcore-buildlink: _BUILDLINK_USE

.endif	# XVIDCORE_BUILDLINK2_MK
