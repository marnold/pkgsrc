# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/23 23:04:51 jlam Exp $

.if !defined(GTK2_BUILDLINK2_MK)
GTK2_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		gtk2
BUILDLINK_DEPENDS.gtk2?=	gtk2+>=2.0.0
BUILDLINK_PKGSRCDIR.gtk2?=	../../x11/gtk2

EVAL_PREFIX+=		BUILDLINK_PREFIX.gtk2=gtk2
BUILDLINK_PREFIX.gtk2_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.gtk2=	include/gtk-2.0/*/*
BUILDLINK_FILES.gtk2+=	include/gtk-2.0/*
BUILDLINK_FILES.gtk2+=	lib/gtk-2.0/*/*/*
BUILDLINK_FILES.gtk2+=	lib/gtk-2.0/*/*
BUILDLINK_FILES.gtk2+=	lib/gtk-2.0/*
BUILDLINK_FILES.gtk2+=	lib/libgdk*-2.0.*
BUILDLINK_FILES.gtk2+=	lib/libgtk*-2.0.*

.include "../../devel/atk/buildlink2.mk"
.include "../../devel/gettext-lib/buildlink2.mk"
.include "../../devel/glib2/buildlink2.mk"
.include "../../devel/pango/buildlink2.mk"
.include "../../devel/pkgconfig/buildlink2.mk"
.include "../../graphics/freetype2/buildlink2.mk"
.include "../../graphics/jpeg/buildlink2.mk"
.include "../../graphics/png/buildlink2.mk"
.include "../../graphics/tiff/buildlink2.mk"

BUILDLINK_TARGETS+=	gtk2-buildlink

gtk2-buildlink: _BUILDLINK_USE

.endif	# GTK2_BUILDLINK2_MK
