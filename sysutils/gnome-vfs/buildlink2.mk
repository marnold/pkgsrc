# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/23 23:04:41 jlam Exp $

.if !defined(GNOME_VFS_BUILDLINK2_MK)
GNOME_VFS_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		gnome-vfs
BUILDLINK_DEPENDS.gnome-vfs?=	gnome-vfs>=1.0.2nb1
BUILDLINK_PKGSRCDIR.gnome-vfs?=	../../sysutils/gnome-vfs

EVAL_PREFIX+=			BUILDLINK_PREFIX.gnome-vfs=gnome-vfs
BUILDLINK_PREFIX.gnome-vfs_DEFAULT=	${X11PREFIX}
BUILDLINK_FILES.gnome-vfs=	include/gnome-vfs-1.0/*/*
BUILDLINK_FILES.gnome-vfs+=	lib/gnome-vfs-1.0/include/*
BUILDLINK_FILES.gnome-vfs+=	lib/libgnomevfs-pthread.*
BUILDLINK_FILES.gnome-vfs+=	lib/libgnomevfs.*
BUILDLINK_FILES.gnome-vfs+=	lib/vfsConf.sh

.include "../../devel/GConf/buildlink2.mk"
.include "../../devel/gettext-lib/buildlink2.mk"

BUILDLINK_TARGETS+=	gnome-vfs-buildlink

gnome-vfs-buildlink: _BUILDLINK_USE

.endif	# GNOME_VFS_BUILDLINK2_MK
