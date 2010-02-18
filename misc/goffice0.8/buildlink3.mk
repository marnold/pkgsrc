# $NetBSD: buildlink3.mk,v 1.1.1.1 2010/02/18 20:48:56 drochner Exp $

BUILDLINK_TREE+=	goffice0.6

.if !defined(GOFFICE0.6_BUILDLINK3_MK)
GOFFICE0.6_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.goffice0.6+=	goffice0.8>=0.8.0
BUILDLINK_ABI_DEPENDS.goffice0.6?=	goffice0.8>=0.8.0
BUILDLINK_PKGSRCDIR.goffice0.6?=	../../misc/goffice0.8

#.include "../../converters/libiconv/buildlink3.mk"
.include "../../devel/GConf/buildlink3.mk"
#.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"
.include "../../devel/libgsf/buildlink3.mk"
.include "../../devel/libgsf-gnome/buildlink3.mk"
.include "../../devel/pango/buildlink3.mk"
.include "../../graphics/cairo/buildlink3.mk"
.include "../../graphics/libart/buildlink3.mk"
.include "../../textproc/libxml2/buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"
.endif # GOFFICE0.6_BUILDLINK3_MK

BUILDLINK_TREE+=	-goffice0.6
