# $NetBSD: buildlink3.mk,v 1.8 2009/03/20 19:25:14 joerg Exp $

BUILDLINK_TREE+=	ijs

.if !defined(IJS_BUILDLINK3_MK)
IJS_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.ijs+=	ijs>=0.34
BUILDLINK_ABI_DEPENDS.ijs+=	ijs>=0.34nb2
BUILDLINK_PKGSRCDIR.ijs?=	../../print/ijs
.endif # IJS_BUILDLINK3_MK

BUILDLINK_TREE+=	-ijs