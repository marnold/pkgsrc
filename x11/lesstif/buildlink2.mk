# $NetBSD: buildlink2.mk,v 1.1.2.3 2002/06/21 23:00:42 jlam Exp $

.if !defined(LESSTIF_BUILDLINK2_MK)
LESSTIF_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		lesstif
BUILDLINK_DEPENDS.lesstif?=	lesstif>=0.91.4
BUILDLINK_PKGSRCDIR.lesstif?=	../../x11/lesstif

EVAL_PREFIX+=	BUILDLINK_PREFIX.lesstif=lesstif
BUILDLINK_PREFIX.lesstif_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.lesstif=	include/Mrm/*
BUILDLINK_FILES.lesstif+=	include/Xm/*
BUILDLINK_FILES.lesstif+=	include/uil/*
BUILDLINK_FILES.lesstif+=	lib/libMrm.*
BUILDLINK_FILES.lesstif+=	lib/libUil.*
BUILDLINK_FILES.lesstif+=	lib/libXm.*

BUILDLINK_TARGETS+=		lesstif-buildlink

lesstif-buildlink: _BUILDLINK_USE

.endif	# LESSTIF_BUILDLINK2_MK
