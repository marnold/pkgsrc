# $NetBSD: buildlink3.mk,v 1.3.2.1 2004/07/14 11:17:19 agc Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBXFCE4GUI_BUILDLINK3_MK:=	${LIBXFCE4GUI_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libxfce4gui
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibxfce4gui}
BUILDLINK_PACKAGES+=	libxfce4gui

.if !empty(LIBXFCE4GUI_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libxfce4gui+=		libxfce4gui>=4.0.6
BUILDLINK_PKGSRCDIR.libxfce4gui?=	../../x11/libxfce4gui
.endif	# LIBXFCE4GUI_BUILDLINK3_MK

.include "../../x11/libxfce4util/buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
