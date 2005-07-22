# $NetBSD: buildlink3.mk,v 1.1.1.1 2005/07/22 22:05:31 adam Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
LIBGNOMEUIMM_BUILDLINK3_MK:=	${LIBGNOMEUIMM_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	libgnomeuimm
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nlibgnomeuimm}
BUILDLINK_PACKAGES+=	libgnomeuimm

.if !empty(LIBGNOMEUIMM_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.libgnomeuimm+=	libgnomeuimm>=2.10.0
BUILDLINK_PKGSRCDIR.libgnomeuimm?=	../../devel/libgnomeuimm
.endif	# LIBGNOMEUIMM_BUILDLINK3_MK

.include "../../devel/gconfmm/buildlink3.mk"
.include "../../devel/libglademm/buildlink3.mk"
.include "../../devel/libgnomemm/buildlink3.mk"
.include "../../devel/libgnomeui/buildlink3.mk"
.include "../../graphics/libgnomecanvasmm/buildlink3.mk"
.include "../../sysutils/gnome-vfsmm/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
