# $NetBSD: buildlink2.mk,v 1.1.1.1 2002/09/07 03:04:06 rh Exp $

.if !defined(GNOME_VFS2_BUILDLINK2_MK)
GNOME_VFS2_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		gnome-vfs2
BUILDLINK_DEPENDS.gnome-vfs2?=	gnome-vfs2>=2.0.4
BUILDLINK_PKGSRCDIR.gnome-vfs2?=	../../sysutils/gnome-vfs2

EVAL_PREFIX+=				BUILDLINK_PREFIX.gnome-vfs2=gnome-vfs2
BUILDLINK_PREFIX.gnome-vfs2_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.gnome-vfs2=	include/gnome-vfs-2.0/libgnomevfs/*
BUILDLINK_FILES.gnome-vfs2+=	include/gnome-vfs-module-2.0/libgnomevfs/*
BUILDLINK_FILES.gnome-vfs2+=	lib/gnome-vfs-2.0/include/gnome-vfs-file-size.h
BUILDLINK_FILES.gnome-vfs2+=	lib/libgnomevfs-2.*
BUILDLINK_FILES.gnome-vfs2+=	lib/pkgconfig/gnome-vfs-2.0.pc
BUILDLINK_FILES.gnome-vfs2+=	lib/pkgconfig/gnome-vfs-module-2.0.pc

.include "../../databases/gnome-mime-data/buildlink2.mk"
.include "../../devel/gettext-lib/buildlink2.mk"
.include "../../devel/GConf2/buildlink2.mk"
.include "../../devel/libbonobo/buildlink2.mk"
.include "../../devel/ptl2/buildlink2.mk"
.include "../../sysutils/fam/buildlink2.mk"

BUILDLINK_TARGETS+=	gnome-vfs2-buildlink

gnome-vfs2-buildlink: _BUILDLINK_USE

.endif	# GNOME_VFS2_BUILDLINK2_MK
