# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/23 23:04:49 jlam Exp $

.if !defined(GNOMEMM_BUILDLINK2_MK)
GNOMEMM_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		gnomemm
BUILDLINK_DEPENDS.gnomemm?=	gnome-->=1.1.19
BUILDLINK_PKGSRCDIR.gnomemm?=	../../x11/gnome--

EVAL_PREFIX+=				BUILDLINK_PREFIX.gnomemm=gnome--
BUILDLINK_PREFIX.gnomemm_DEFAULT=	${X11PREFIX}

BUILDLINK_FILES.gnomemm=	include/gnome--/private/*
BUILDLINK_FILES.gnomemm+=	include/gnome--/*
BUILDLINK_FILES.gnomemm+=	include/gnome--.h
BUILDLINK_FILES.gnomemm+=	lib/libgnomemm-1.1.*
BUILDLINK_FILES.gnomemm+=	lib/libgnomemm.*

.include "../../devel/libsigc++/buildlink2.mk"
.include "../../x11/gnome-libs/buildlink2.mk"
.include "../../x11/gtk--/buildlink2.mk"

BUILDLINK_TARGETS+=	gnomemm-buildlink

gnomemm-buildlink: _BUILDLINK_USE

.endif	# GNOMEMM_BUILDLINK2_MK
