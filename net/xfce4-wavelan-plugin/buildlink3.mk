# $NetBSD: buildlink3.mk,v 1.1.1.1.2.2 2004/07/14 12:49:18 agc Exp $

BUILDLINK_DEPTH:=			${BUILDLINK_DEPTH}+
XFCE4_WAVELAN_PLUGIN_BUILDLINK3_MK:=	${XFCE4_WAVELAN_PLUGIN_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	xfce4-wavelan-plugin
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nxfce4-wavelan-plugin}
BUILDLINK_PACKAGES+=	xfce4-wavelan-plugin

.if !empty(XFCE4_WAVELAN_PLUGIN_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.xfce4-wavelan-plugin+=	xfce4-wavelan-plugin>=0.3.2
BUILDLINK_PKGSRCDIR.xfce4-wavelan-plugin?=	../../net/xfce4-wavelan-plugin
.endif	# XFCE4_WAVELAN_PLUGIN_BUILDLINK3_MK

.include "../../x11/xfce4-panel/buildlink3.mk"
.include "../../devel/glib2/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
