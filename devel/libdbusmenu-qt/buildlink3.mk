# $NetBSD: buildlink3.mk,v 1.1.1.1 2011/05/13 21:21:24 markd Exp $

BUILDLINK_TREE+=	libdbusmenu-qt

.if !defined(LIBDBUSMENU_QT_BUILDLINK3_MK)
LIBDBUSMENU_QT_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.libdbusmenu-qt+=	libdbusmenu-qt>=0.8.2
BUILDLINK_PKGSRCDIR.libdbusmenu-qt?=	../../devel/libdbusmenu-qt

.include "../../x11/qt4-libs/buildlink3.mk"
.include "../../x11/qt4-qdbus/buildlink3.mk"
.endif	# LIBDBUSMENU_QT_BUILDLINK3_MK

BUILDLINK_TREE+=	-libdbusmenu-qt
