# $NetBSD: buildlink2.mk,v 1.1.2.2 2002/08/22 21:04:19 jlam Exp $

.if !defined(ATK_BUILDLINK2_MK)
ATK_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		atk
BUILDLINK_DEPENDS.atk?=		atk>=1.0.2
BUILDLINK_PKGSRCDIR.atk?=	../../devel/atk

EVAL_PREFIX+=		BUILDLINK_PREFIX.atk=atk
BUILDLINK_PREFIX.atk_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.atk=	include/atk-1.0/*/*
BUILDLINK_FILES.atk+=	include/atk-1.0/*
BUILDLINK_FILES.atk+=	lib/libatk-1.0.*

.include "../../devel/pkgconfig/buildlink2.mk"

BUILDLINK_TARGETS+=	atk-buildlink

atk-buildlink: _BUILDLINK_USE

.endif	# ATK_BUILDLINK2_MK
