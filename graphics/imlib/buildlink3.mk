# $NetBSD: buildlink3.mk,v 1.4.6.1 2004/12/13 18:03:27 salo Exp $

BUILDLINK_DEPTH:=	${BUILDLINK_DEPTH}+
IMLIB_BUILDLINK3_MK:=	${IMLIB_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	imlib
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:Nimlib}
BUILDLINK_PACKAGES+=	imlib

.if !empty(IMLIB_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.imlib+=	imlib>=1.9.14nb5
BUILDLINK_RECOMMENDED.imlib+=	imlib>=1.9.15nb1
BUILDLINK_PKGSRCDIR.imlib?=	../../graphics/imlib
.endif	# IMLIB_BUILDLINK3_MK

.include "../../devel/gettext-lib/buildlink3.mk"
.include "../../graphics/jpeg/buildlink3.mk"
.include "../../graphics/libungif/buildlink3.mk"
.include "../../graphics/netpbm/buildlink3.mk"
.include "../../graphics/png/buildlink3.mk"
.include "../../graphics/tiff/buildlink3.mk"
.include "../../x11/gtk/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
