# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/21 23:00:23 jlam Exp $

.if !defined(MHASH_BUILDLINK2_MK)
MHASH_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		mhash
BUILDLINK_DEPENDS.mhash?=	mhash>=0.8.3
BUILDLINK_PKGSRCDIR.mhash?=	../../security/mhash

EVAL_PREFIX+=			BUILDLINK_PREFIX.mhash=mhash
BUILDLINK_PREFIX.mhash_DEFAULT=	${LOCALBASE}
BUILDLINK_FILES.mhash=		include/mhash.h
BUILDLINK_FILES.mhash+=		lib/libmhash.*

BUILDLINK_TARGETS+=	mhash-buildlink

mhash-buildlink: _BUILDLINK_USE

.endif	# MHASH_BUILDLINK2_MK
