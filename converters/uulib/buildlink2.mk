# $NetBSD: buildlink2.mk,v 1.3.6.1 2004/04/27 08:30:49 agc Exp $

.if !defined(UULIB_BUILDLINK2_MK)
UULIB_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		uulib
BUILDLINK_DEPENDS.uulib?=	uulib>=0.5.20
BUILDLINK_PKGSRCDIR.uulib?=	../../converters/uulib

EVAL_PREFIX+=		BUILDLINK_PREFIX.uulib=uulib
BUILDLINK_PREFIX.uulib_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.uulib=	include/uu.h
BUILDLINK_FILES.uulib+=	lib/libuu.*

BUILDLINK_TARGETS+=	uulib-buildlink

uulib-buildlink: _BUILDLINK_USE

.endif	# UULIB_BUILDLINK2_MK
