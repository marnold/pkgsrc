# $NetBSD: buildlink2.mk,v 1.1.1.1 2002/11/04 08:28:00 rh Exp $
#
# This Makefile fragment is included by packages that use gnome-panel.
#
# This file was created automatically using createbuildlink 2.2.
#

.if !defined(GNOME_PANEL_BUILDLINK2_MK)
GNOME_PANEL_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=			gnome-panel
BUILDLINK_DEPENDS.gnome-panel?=		gnome-panel>=2.0.10
BUILDLINK_PKGSRCDIR.gnome-panel?=		../../x11/gnome-panel

EVAL_PREFIX+=	BUILDLINK_PREFIX.gnome-panel=gnome-panel
BUILDLINK_PREFIX.gnome-panel_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.gnome-panel+=	include/panel-2.0/*.h
BUILDLINK_FILES.gnome-panel+=	lib/bonobo/servers/GNOME_FishApplet_Factory.server
BUILDLINK_FILES.gnome-panel+=	lib/bonobo/servers/GNOME_GenUtilApplet_Factory.server
BUILDLINK_FILES.gnome-panel+=	lib/bonobo/servers/GNOME_Panel.server
BUILDLINK_FILES.gnome-panel+=	lib/libgen_util_applet-2.*
BUILDLINK_FILES.gnome-panel+=	lib/libpanel-applet-2.*
BUILDLINK_FILES.gnome-panel+=	lib/pkgconfig/libpanelapplet-2.0.pc

.include "../../devel/GConf2/buildlink2.mk"
.include "../../devel/libwnck/buildlink2.mk"
.include "../../devel/libglade2/buildlink2.mk"
.include "../../devel/libgnomeui/buildlink2.mk"
.include "../../devel/gettext-lib/buildlink2.mk"
.include "../../sysutils/gnome-vfs2/buildlink2.mk"
.include "../../textproc/scrollkeeper/buildlink2.mk"
.include "../../textproc/intltool/buildlink2.mk"
.include "../../textproc/gtk-doc/buildlink2.mk"
.include "../../x11/gnome-desktop/buildlink2.mk"
.include "../../x11/gnome2-control-center/buildlink2.mk"

BUILDLINK_TARGETS+=	gnome-panel-buildlink

gnome-panel-buildlink: _BUILDLINK_USE

.endif	# GNOME_PANEL_BUILDLINK2_MK
