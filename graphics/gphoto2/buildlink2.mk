# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/23 23:04:25 jlam Exp $

.if !defined(GPHOTO2_BUILDLINK2_MK)
GPHOTO2_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		gphoto2
BUILDLINK_DEPENDS.gphoto2?=	gphoto>=2.0
BUILDLINK_PKGSRCDIR.gphoto2?=	../../graphics/gphoto2

EVAL_PREFIX+=		BUILDLINK_PREFIX.gphoto2=gphoto2
BUILDLINK_PREFIX.gphoto2=	${LOCALBASE}
BUILDLINK_FILES.gphoto2=	include/gphoto2/*.h
BUILDLINK_FILES.gphoto2+=	lib/libgphoto2.*
BUILDLINK_FILES.gphoto2+=	lib/libgphoto2_port.*

BUILDLINK_TARGETS+=	gphoto2-buildlink

gphoto2-buildlink: _BUILDLINK_USE

.endif	# GPHOTO2_BUILDLINK2_MK
