# $NetBSD: buildlink3.mk,v 1.18 2014/04/10 06:21:20 obache Exp $

BUILDLINK_TREE+=	kactivities

.if !defined(KACTIVITIES_BUILDLINK3_MK)
KACTIVITIES_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.kactivities+=	kactivities>=4.7.95
BUILDLINK_ABI_DEPENDS.kactivities+=	kactivities>=4.11.5nb3
BUILDLINK_PKGSRCDIR.kactivities?=	../../x11/kactivities

.include "../../x11/kdelibs4/buildlink3.mk"
.endif # KACTIVITIES_BUILDLINK3_MK

BUILDLINK_TREE+=	-kactivities
