# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/23 23:04:48 jlam Exp $

.if !defined(CONTROLCENTER_BUILDLINK2_MK)
CONTROLCENTER_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			controlcenter
BUILDLINK_DEPENDS.controlcenter?=	control-center>=1.4.0.4
BUILDLINK_PKGSRCDIR.controlcenter?=	../../x11/controlcenter
DEPENDS+=	${BUILDLINK_DEPENDS.controlcenter}:../../x11/controlcenter

EVAL_PREFIX+=			BUILDLINK_PREFIX.controlcenter=controlcenter
BUILDLINK_PREFIX.controlcenter_DEFAULTS=	${X11PREFIX}
BUILDLINK_FILES.controlcenter=	include/libcapplet1/*
BUILDLINK_FILES.controlcenter+=	lib/libcapplet.*

BUILDLINK_TRANSFORM.controlcenter= \
	-e "s|/include/libcapplet1/|/include/|g

.include "../../graphics/gdk-pixbuf/buildlink2.mk"
.include "../../devel/gettext-lib/buildlink2.mk"
.include "../../sysutils/gnome-vfs/buildlink2.mk"
.include "../../x11/gnome-libs/buildlink2.mk"

BUILDLINK_TARGETS+=	controlcenter-buildlink

controlcenter-buildlink: _BUILDLINK_USE

.endif	# CONTROLCENTER_BUILDLINK2_MK
