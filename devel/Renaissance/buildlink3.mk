# $NetBSD: buildlink3.mk,v 1.1.1.1 2004/04/11 01:09:14 rh Exp $

BUILDLINK_DEPTH:=		${BUILDLINK_DEPTH}+
RENAISSANCE_BUILDLINK3_MK:=	${RENAISSANCE_BUILDLINK3_MK}+

.if !empty(BUILDLINK_DEPTH:M+)
BUILDLINK_DEPENDS+=	Renaissance
.endif

BUILDLINK_PACKAGES:=	${BUILDLINK_PACKAGES:NRenaissance}
BUILDLINK_PACKAGES+=	Renaissance

.if !empty(RENAISSANCE_BUILDLINK3_MK:M+)
BUILDLINK_DEPENDS.Renaissance+=		Renaissance>=0.7.0
BUILDLINK_PKGSRCDIR.Renaissance?=	../../devel/Renaissance
.endif	# RENAISSANCE_BUILDLINK3_MK

.include "../../x11/gnustep-back/buildlink3.mk"

BUILDLINK_DEPTH:=     ${BUILDLINK_DEPTH:S/+$//}
