# $NetBSD: buildlink2.mk,v 1.1.2.1 2002/06/23 23:03:54 jlam Exp $

.if !defined(LAME_BUILDLINK2_MK)
LAME_BUILDLINK2_MK=	# defined

BUILDLINK_PACKAGES+=		lame
BUILDLINK_DEPENDS.lame?=	lame>=3.89
BUILDLINK_PKGSRCDIR.lame?=	../../audio/lame

EVAL_PREFIX+=		BUILDLINK_PREFIX.lame=lame
BUILDLINK_PREFIX.lame=	${LOCALBASE}
BUILDLINK_FILES.lame=	include/lame/lame.h

BUILDLINK_TARGETS+=	lame-buildlink

lame-buildlink: _BUILDLINK_USE

.endif	# LAME_BUILDLINK2_MK
